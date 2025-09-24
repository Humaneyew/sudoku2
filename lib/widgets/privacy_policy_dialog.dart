import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../flutter_gen/gen_l10n/app_localizations.dart';
import '../layout/layout_scale.dart';

final _privacyPolicyUri = Uri.parse(
  'https://github.com/UzorPlay/privacy-policy/blob/main/privacy-policy.md',
);

Future<bool> showPrivacyPolicyDialog(
  BuildContext context, {
  bool barrierDismissible = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return _PrivacyPolicyDialog(barrierDismissible: barrierDismissible);
    },
  );
  return result ?? false;
}

class _PrivacyPolicyDialog extends StatefulWidget {
  final bool barrierDismissible;

  const _PrivacyPolicyDialog({required this.barrierDismissible});

  @override
  State<_PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<_PrivacyPolicyDialog> {
  late final TapGestureRecognizer _linkRecognizer;

  @override
  void initState() {
    super.initState();
    _linkRecognizer = TapGestureRecognizer()
      ..onTap = () {
        unawaited(
          launchUrl(
            _privacyPolicyUri,
            mode: LaunchMode.externalApplication,
          ),
        );
      };
  }

  @override
  void dispose() {
    _linkRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scale = context.layoutScale;
    final colors = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async => widget.barrierDismissible,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 24 * scale,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.privacyPolicyTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  Text(
                    l10n.privacyPolicyBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(text: '${l10n.privacyPolicyFullPolicyLabel} '),
                        TextSpan(
                          text: l10n.privacyPolicyLinkText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _linkRecognizer,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24 * scale),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l10n.privacyPolicyAccept),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
