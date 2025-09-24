import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

class UndoRewardController extends ChangeNotifier {
  UndoRewardController({
    bool enabled = true,
    Duration placeholderDuration = const Duration(seconds: 5),
  })  : _enabled = enabled,
        _placeholderDuration = placeholderDuration;

  final bool _enabled;
  final Duration _placeholderDuration;
  bool _rewardAvailable = true;
  bool _showingReward = false;
  Future<bool>? _pendingRequest;

  bool get isRewardEnabled => _enabled;

  bool get isRewardAvailable =>
      !_enabled ? true : _rewardAvailable && !_showingReward;

  Future<bool> showReward(BuildContext context) {
    if (!_enabled) {
      return Future.value(true);
    }
    if (_pendingRequest != null) {
      return _pendingRequest!;
    }
    if (!isRewardAvailable) {
      return Future.value(false);
    }

    final future = _performShowReward(context);
    _pendingRequest = future;
    future.whenComplete(() {
      _pendingRequest = null;
    });
    return future;
  }

  Future<bool> _performShowReward(BuildContext context) async {
    _rewardAvailable = false;
    _showingReward = true;
    notifyListeners();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return _UndoRewardDialog(
          duration: _placeholderDuration,
          title: l10n.undoAdTitle,
          description: l10n.undoAdDescription,
          countdownBuilder: l10n.undoAdCountdown,
          cancelLabel: l10n.cancelAction,
        );
      },
    );

    final rewarded = result ?? false;

    _showingReward = false;
    _rewardAvailable = true;
    notifyListeners();

    return rewarded;
  }

  void updateAvailability(bool available) {
    if (!_enabled) {
      return;
    }
    if (_rewardAvailable == available) {
      return;
    }
    _rewardAvailable = available;
    notifyListeners();
  }
}

class _UndoRewardDialog extends StatefulWidget {
  const _UndoRewardDialog({
    required this.duration,
    required this.title,
    required this.description,
    required this.countdownBuilder,
    required this.cancelLabel,
  });

  final Duration duration;
  final String title;
  final String description;
  final String Function(int seconds) countdownBuilder;
  final String cancelLabel;

  @override
  State<_UndoRewardDialog> createState() => _UndoRewardDialogState();
}

class _UndoRewardDialogState extends State<_UndoRewardDialog> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.duration.inSeconds;
    if (_secondsLeft <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).maybePop(true);
      });
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = widget.duration.inSeconds - timer.tick;
      setState(() {
        _secondsLeft = remaining;
      });

      if (remaining <= 0) {
        timer.cancel();
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).maybePop(true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleClose() {
    _timer?.cancel();
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final primary = cs.primary;

    final total = widget.duration.inSeconds;
    final seconds = (_secondsLeft.clamp(0, total)).toInt();
    final progress = total == 0 ? 1.0 : (total - seconds) / total;

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.ondemand_video, color: primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _handleClose,
                  tooltip: widget.cancelLabel,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.countdownBuilder(seconds),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

