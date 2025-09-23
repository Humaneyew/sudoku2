import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

class LifeAdController extends ChangeNotifier {
  LifeAdController({
    bool? integrationEnabled,
    Duration adDuration = const Duration(seconds: 12),
  })  : _integrationEnabled =
            integrationEnabled ?? const bool.fromEnvironment('enableLifeAd'),
        _adDuration = adDuration;

  final bool _integrationEnabled;
  final Duration _adDuration;
  bool _adAvailable = true;
  bool _showingAd = false;
  Future<bool>? _pendingAd;

  bool get useAdFlow => kReleaseMode && _integrationEnabled;

  bool get isAdAvailable => !useAdFlow ? true : _adAvailable && !_showingAd;

  Future<bool> showAd(BuildContext context) {
    if (!useAdFlow) {
      return Future.value(true);
    }
    if (_pendingAd != null) {
      return _pendingAd!;
    }
    if (!isAdAvailable) {
      return Future.value(false);
    }

    final future = _performShowAd(context);
    _pendingAd = future;
    future.whenComplete(() {
      _pendingAd = null;
    });
    return future;
  }

  Future<bool> _performShowAd(BuildContext context) async {
    _adAvailable = false;
    _showingAd = true;
    notifyListeners();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return _LifeAdDialog(
          duration: _adDuration,
          title: l10n.lifeAdTitle,
          description: l10n.lifeAdDescription,
          countdownBuilder: l10n.lifeAdCountdown,
        );
      },
    );

    if (!context.mounted) {
      _showingAd = false;
      _adAvailable = true;
      notifyListeners();
      return false;
    }

    _showingAd = false;
    _adAvailable = true;
    notifyListeners();

    return true;
  }

  void updateAvailability(bool available) {
    if (!useAdFlow) {
      return;
    }
    if (_adAvailable == available) {
      return;
    }
    _adAvailable = available;
    notifyListeners();
  }
}

class _LifeAdDialog extends StatefulWidget {
  const _LifeAdDialog({
    required this.duration,
    required this.title,
    required this.description,
    required this.countdownBuilder,
  });

  final Duration duration;
  final String title;
  final String description;
  final String Function(int seconds) countdownBuilder;

  @override
  State<_LifeAdDialog> createState() => _LifeAdDialogState();
}

class _LifeAdDialogState extends State<_LifeAdDialog> {
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
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
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
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                value: progress,
                minHeight: 12,
                backgroundColor: cs.surfaceVariant,
                color: primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.countdownBuilder(seconds),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
