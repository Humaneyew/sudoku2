import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import '../models.dart';
import 'combo_theme.dart';
import 'combo_toast.dart';

abstract class ComboHost {
  BuildContext get context;
  TickerProvider get vsync;
  double get fontScale;
}

enum _ToastType { combo, streak, speed }

class ComboController implements ComboEventSink {
  ComboController({required this.host});

  static const _comboIcon = 'assets/icons/combos/combo.svg';
  static const _streakIcon = 'assets/icons/combos/streak.svg';
  static const _speedIcon = 'assets/icons/combos/speed.svg';

  final ComboHost host;

  bool _enabled = true;
  bool _hapticsEnabled = true;

  final Queue<_ToastRequest> _queue = Queue<_ToastRequest>();
  final List<DateTime> _recentShows = <DateTime>[];
  _ToastRequest? _activeToast;
  OverlayEntry? _overlayEntry;
  AnimationController? _controller;
  Timer? _dismissTimer;
  Timer? _throttleTimer;
  Timer? _pendingMoveTimer;
  bool _showing = false;
  DateTime? _lastShowStarted;
  final math.Random _random = math.Random();

  int? _pendingMoveTimestampMs;
  final List<_PendingMoveToast> _pendingMoveToasts = <_PendingMoveToast>[];

  int _comboCount = 0;
  int _maxComboShown = 0;
  DateTime? _lastComboTs;
  Difficulty? _currentDifficulty;

  int _noHintChain = 0;
  int _lastStreakShown = 0;

  @override
  void updateSettings({required bool enabled, required bool hapticsEnabled}) {
    _enabled = enabled;
    _hapticsEnabled = hapticsEnabled;
    if (!_enabled) {
      reset();
    }
  }

  @override
  void onCellFilled({
    required bool correct,
    required int timestampMs,
    Difficulty? difficulty,
  }) {
    _currentDifficulty = difficulty;
    _startMoveAggregation(timestampMs);
    final ts = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    if (!correct) {
      _comboCount = 0;
      _lastComboTs = ts;
      _maxComboShown = 0;
      _noHintChain = 0;
      _lastStreakShown = 0;
      return;
    }
    final window = Duration(milliseconds: _comboWindowMs(difficulty));
    if (_lastComboTs != null && ts.difference(_lastComboTs!) <= window) {
      _comboCount++;
    } else {
      _comboCount = 1;
      _maxComboShown = 1;
    }
    _lastComboTs = ts;

    if (_comboCount >= 2) {
      final l10n = AppLocalizations.of(host.context);
      if (l10n == null) {
        return;
      }
      final label = l10n.comboX(_comboCount);
      _collectMoveToast(
        _ToastRequest(
          type: _ToastType.combo,
          label: label,
          iconAsset: _comboIcon,
          level: _comboCount,
          difficulty: difficulty,
        ),
        allowUpgrade: true,
      );
      if (_comboCount > _maxComboShown) {
        _maxComboShown = _comboCount;
        _maybeHaptic();
      }
    }
  }

  @override
  void onNoHintStep(Difficulty? difficulty) {
    _currentDifficulty = difficulty;
    _noHintChain++;
    final milestones = const [5, 10, 20];
    for (final milestone in milestones) {
      if (_noHintChain == milestone && _lastStreakShown < milestone) {
        _lastStreakShown = milestone;
        final l10n = AppLocalizations.of(host.context);
        if (l10n == null) {
          return;
        }
        final label = l10n.streakN(milestone);
        _collectMoveToast(
          _ToastRequest(
            type: _ToastType.streak,
            label: label,
            iconAsset: _streakIcon,
            level: milestone,
            difficulty: difficulty,
          ),
        );
        break;
      }
    }
  }

  @override
  void onHintUsed() {
    _noHintChain = 0;
    _lastStreakShown = 0;
  }

  @override
  void onLevelFinished({
    required Difficulty? difficulty,
    required int durationMs,
  }) {
    _currentDifficulty = difficulty;
    if (difficulty == null) {
      return;
    }
    final threshold = _speedThresholdMs[difficulty];
    if (threshold == null || durationMs > threshold) {
      return;
    }
    final l10n = AppLocalizations.of(host.context);
    if (l10n == null) {
      return;
    }
    final seconds = (durationMs / 1000).round();
    final label = l10n.speedBonus(secondsFormat(seconds));
    Future.delayed(const Duration(milliseconds: 250), () {
      _enqueueToast(
        _ToastRequest(
          type: _ToastType.speed,
          label: label,
          iconAsset: _speedIcon,
          level: 0,
          difficulty: difficulty,
        ),
      );
    });
  }

  @override
  void reset() {
    _comboCount = 0;
    _maxComboShown = 0;
    _lastComboTs = null;
    _noHintChain = 0;
    _lastStreakShown = 0;
    _pendingMoveTimestampMs = null;
    _pendingMoveToasts.clear();
    _pendingMoveTimer?.cancel();
    _pendingMoveTimer = null;
    _queue.clear();
    _dismissActive(immediate: true);
  }

  @override
  void dispose() {
    _dismissActive(immediate: true);
    _throttleTimer?.cancel();
    _pendingMoveTimestampMs = null;
    _pendingMoveToasts.clear();
    _pendingMoveTimer?.cancel();
    _pendingMoveTimer = null;
  }

  void _startMoveAggregation(int timestampMs) {
    _pendingMoveTimestampMs = timestampMs;
    _pendingMoveToasts.clear();
    _pendingMoveTimer?.cancel();
    _pendingMoveTimer = Timer(Duration.zero, () {
      _finalizeMoveToasts(timestampMs);
    });
  }

  void _collectMoveToast(
    _ToastRequest request, {
    bool allowUpgrade = false,
  }) {
    if (_pendingMoveTimestampMs == null) {
      _enqueueToast(request, allowUpgrade: allowUpgrade);
      return;
    }
    if (allowUpgrade) {
      final index = _pendingMoveToasts.indexWhere(
        (entry) => entry.request.type == request.type,
      );
      if (index != -1) {
        final existing = _pendingMoveToasts[index];
        if (request.level >= existing.request.level) {
          _pendingMoveToasts[index] =
              _PendingMoveToast(request, allowUpgrade: allowUpgrade);
        }
        return;
      }
    }
    _pendingMoveToasts
        .add(_PendingMoveToast(request, allowUpgrade: allowUpgrade));
  }

  void _finalizeMoveToasts(int timestampMs) {
    if (_pendingMoveTimestampMs != timestampMs) {
      return;
    }
    final pending = List<_PendingMoveToast>.from(_pendingMoveToasts);
    _pendingMoveTimestampMs = null;
    _pendingMoveToasts.clear();
    _pendingMoveTimer?.cancel();
    _pendingMoveTimer = null;
    if (pending.isEmpty) {
      return;
    }
    final triggeredTypes = pending.map((entry) => entry.request.type).toSet();
    _PendingMoveToast? selected;
    if (triggeredTypes.length >= 2) {
      final comboEntries = pending
          .where((entry) => entry.request.type == _ToastType.combo)
          .toList();
      final streakEntries = pending
          .where((entry) => entry.request.type == _ToastType.streak)
          .toList();
      final hasCombo = comboEntries.isNotEmpty;
      final hasStreak = streakEntries.isNotEmpty;
      if (hasCombo && hasStreak) {
        selected = _random.nextBool()
            ? comboEntries.last
            : streakEntries.last;
      } else if (hasCombo) {
        selected = comboEntries.last;
      } else if (hasStreak) {
        selected = streakEntries.last;
      } else {
        selected = pending[_random.nextInt(pending.length)];
      }
    } else {
      selected = pending.last;
    }
    selected ??= pending.last;
    _enqueueToast(selected.request, allowUpgrade: selected.allowUpgrade);
  }

  void _enqueueToast(
    _ToastRequest request, {
    bool allowUpgrade = false,
  }) {
    if (!_enabled) {
      return;
    }
    final theme = Theme.of(host.context);
    final comboTheme = theme.extension<ComboTheme>() ?? _fallbackTheme;
    if (_activeToast != null &&
        allowUpgrade &&
        _activeToast!.type == request.type &&
        request.level >= _activeToast!.level) {
      _activeToast = request;
      _overlayEntry?.markNeedsBuild();
      _extendActiveDisplay();
      return;
    }
    if (_queue.length >= comboTheme.maxQueue) {
      if (_queue.isNotEmpty && _queue.last.type == request.type) {
        _queue.removeLast();
      } else {
        _queue.removeFirst();
      }
    }
    _queue.add(request);
    _scheduleShow();
  }

  void _scheduleShow() {
    if (_showing) {
      return;
    }
    if (_activeToast != null) {
      return;
    }
    if (_queue.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final throttleMs = _effectiveThrottleMs();
    if (_lastShowStarted != null) {
      final elapsed = now.difference(_lastShowStarted!);
      if (elapsed < Duration(milliseconds: throttleMs)) {
        final delay = Duration(milliseconds: throttleMs) - elapsed;
        _throttleTimer?.cancel();
        _throttleTimer = Timer(delay, _scheduleShow);
        return;
      }
    }
    final canShow = _canShowNow(now);
    if (!canShow) {
      if (_recentShows.isNotEmpty) {
        final earliest = _recentShows.first;
        final retryAt = earliest.add(const Duration(seconds: 10));
        final wait = retryAt.difference(now);
        if (!wait.isNegative) {
          _throttleTimer?.cancel();
          _throttleTimer = Timer(wait, _scheduleShow);
        }
      }
      return;
    }
    final request = _queue.removeFirst();
    _showToast(request);
  }

  bool _canShowNow(DateTime now) {
    _recentShows.removeWhere(
      (date) => now.difference(date) > const Duration(seconds: 10),
    );
    if (_recentShows.length >= 6) {
      return false;
    }
    return true;
  }

  Future<void> _showToast(_ToastRequest request) async {
    final overlay = Navigator.of(host.context, rootNavigator: true).overlay ??
        Overlay.of(host.context);
    if (overlay == null) {
      return;
    }
    final theme = Theme.of(host.context);
    final comboTheme = theme.extension<ComboTheme>() ?? _fallbackTheme;
    _showing = true;
    _activeToast = request;
    _lastShowStarted = DateTime.now();
    _recentShows.add(_lastShowStarted!);

    final media = MediaQuery.of(host.context);
    final reduceMotion =
        media.disableAnimations || media.accessibleNavigation;

    _controller?.dispose();
    _controller = AnimationController(
      duration: reduceMotion
          ? const Duration(milliseconds: 120)
          : Duration(milliseconds: comboTheme.inMs),
      reverseDuration: reduceMotion
          ? const Duration(milliseconds: 120)
          : Duration(milliseconds: comboTheme.outMs),
      vsync: host.vsync,
    );

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          final payload = _activeToast;
          if (payload == null) {
            return const SizedBox.shrink();
          }
          final animation = CurvedAnimation(
            parent: _controller!,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final fade = animation;
          final scaleTween = reduceMotion
              ? const AlwaysStoppedAnimation<double>(1.0)
              : Tween<double>(begin: 0.9, end: 1.0).animate(animation);
          final offsetTween = reduceMotion
              ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
              : Tween<Offset>(
                  begin: Offset(0, comboTheme.offsetY / -56.0),
                  end: Offset.zero,
                ).animate(animation);
          final maxWidth = math.min(media.size.width * 0.9, 360.0);
          return Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: offsetTween,
                    child: ScaleTransition(
                      scale: scaleTween,
                      child: ComboToast(
                        message: payload.label,
                        iconAsset: payload.iconAsset,
                        fontScale: host.fontScale,
                        maxWidth: maxWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      overlay.insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }

    await _controller!.forward(from: 0);

    _dismissTimer?.cancel();
    _dismissTimer = Timer(
      Duration(milliseconds: comboTheme.displayMs),
      () => _dismissActive(),
    );
    _showing = false;
  }

  void _extendActiveDisplay({int extraMs = 450}) {
    if (_dismissTimer != null) {
      _dismissTimer!.cancel();
      final theme = Theme.of(host.context);
      final comboTheme = theme.extension<ComboTheme>() ?? _fallbackTheme;
      final extend = Duration(milliseconds: extraMs);
      _dismissTimer = Timer(
        Duration(milliseconds: comboTheme.displayMs) + extend,
        () => _dismissActive(),
      );
    }
  }

  Future<void> _hideActive({bool immediate = false}) async {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_controller == null || _overlayEntry == null) {
      _activeToast = null;
      _scheduleShow();
      return;
    }
    if (immediate) {
      _controller!.stop();
      _controller!.dispose();
      _controller = null;
      _overlayEntry!.remove();
      _overlayEntry = null;
      _activeToast = null;
      _scheduleShow();
      return;
    }
    try {
      await _controller!.reverse();
    } catch (_) {}
    _controller!.dispose();
    _controller = null;
    _overlayEntry!.remove();
    _overlayEntry = null;
    _activeToast = null;
    _scheduleShow();
  }

  void _dismissActive({bool immediate = false}) {
    unawaited(_hideActive(immediate: immediate));
  }

  int _comboWindowMs(Difficulty? difficulty) {
    if (difficulty == null) {
      return 1200;
    }
    switch (difficulty) {
      case Difficulty.high:
        return 1100;
      case Difficulty.expert:
      case Difficulty.master:
        return 1000;
      default:
        return 1200;
    }
  }

  int _effectiveThrottleMs() {
    final theme = Theme.of(host.context);
    final comboTheme = theme.extension<ComboTheme>() ?? _fallbackTheme;
    final difficulty = _currentDifficulty;
    if (difficulty == Difficulty.expert || difficulty == Difficulty.master) {
      return comboTheme.throttleMs + 120;
    }
    if (difficulty == Difficulty.high) {
      return comboTheme.throttleMs + 60;
    }
    return comboTheme.throttleMs;
  }

  void _maybeHaptic() {
    if (!_hapticsEnabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  static const _fallbackTheme = ComboTheme(
    tintStrength: 0.1,
    maxQueue: 5,
    throttleMs: 800,
    inMs: 200,
    outMs: 200,
    offsetY: 10,
    baseHeight: 56,
    displayMs: 1000,
    elevation: 2,
    containerOpacity: 0.84,
    outlineOpacity: 0.20,
  );

  static const Map<Difficulty, int> _speedThresholdMs = {
    Difficulty.novice: 8 * 60 * 1000,
    Difficulty.medium: 7 * 60 * 1000,
    Difficulty.high: 6 * 60 * 1000,
    Difficulty.expert: 5 * 60 * 1000,
    Difficulty.master: 4 * 60 * 1000,
  };

  String secondsFormat(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _ToastRequest {
  final _ToastType type;
  final String label;
  final String iconAsset;
  final int level;
  final Difficulty? difficulty;

  const _ToastRequest({
    required this.type,
    required this.label,
    required this.iconAsset,
    this.level = 0,
    this.difficulty,
  });
}

class _PendingMoveToast {
  final _ToastRequest request;
  final bool allowUpgrade;

  const _PendingMoveToast(this.request, {this.allowUpgrade = false});
}
