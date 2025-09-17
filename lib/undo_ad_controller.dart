import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

class UndoAdController extends ChangeNotifier {
  UndoAdController({
    bool? integrationEnabled,
    Duration adDuration = const Duration(seconds: 5),
  })  : _integrationEnabled =
            integrationEnabled ?? const bool.fromEnvironment('enableUndoAd'),
        _adDuration = adDuration;

  final bool _integrationEnabled;
  final Duration _adDuration;
  bool _adAvailable = true;
  bool _showingAd = false;

  bool get useAdFlow => kReleaseMode && _integrationEnabled;

  bool get isAdAvailable => !useAdFlow ? true : _adAvailable && !_showingAd;

  Future<bool> showAd(BuildContext context) async {
    if (!useAdFlow) {
      return true;
    }
    if (!isAdAvailable) {
      return false;
    }

    _adAvailable = false;
    _showingAd = true;
    notifyListeners();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return _UndoAdDialog(
          duration: _adDuration,
          title: l10n.undoAdTitle,
          description: l10n.undoAdDescription,
          countdownBuilder: l10n.undoAdCountdown,
        );
      },
    );

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

class _UndoAdDialog extends StatefulWidget {
  const _UndoAdDialog({
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
  State<_UndoAdDialog> createState() => _UndoAdDialogState();
}

class _UndoAdDialogState extends State<_UndoAdDialog> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.duration.inSeconds;
    if (_secondsLeft <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
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
        Navigator.of(context).pop();
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
    final primary = theme.colorScheme.primary;

    final total = widget.duration.inSeconds;
    final seconds = (_secondsLeft.clamp(0, total)).toInt();
    final progress = total == 0 ? 1.0 : (total - seconds) / total;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
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
              borderRadius: BorderRadius.circular(12),
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
