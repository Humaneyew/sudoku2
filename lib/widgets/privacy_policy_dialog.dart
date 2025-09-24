import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../flutter_gen/gen_l10n/app_localizations.dart';
import '../layout/layout_scale.dart';

const _privacyPolicyUrl =
    'https://github.com/UzorPlay/privacy-policy/blob/main/privacy-policy.md';

Future<void> openPrivacyPolicyLink(BuildContext context) async {
  final uri = Uri.parse(_privacyPolicyUrl);
  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      _showLaunchError(context);
    }
  } catch (_) {
    _showLaunchError(context);
  }
}

Future<bool> showPrivacyPolicyDialog(
  BuildContext context, {
  required bool requireAcceptance,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: !requireAcceptance,
    builder: (dialogContext) {
      return _PrivacyPolicyDialog(requireAcceptance: requireAcceptance);
    },
  );
  return result ?? false;
}

void _showLaunchError(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final message = l10n?.failed ?? 'Failed';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class _PrivacyPolicyDialog extends StatelessWidget {
  final bool requireAcceptance;

  const _PrivacyPolicyDialog({required this.requireAcceptance});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scale = context.layoutScale;
    final textTheme = theme.textTheme;

    final titleStyle = textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final promptStyle = textTheme.bodyLarge?.copyWith(
      height: 1.4,
      fontWeight: FontWeight.w500,
    );
    final linkStyle = textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return WillPopScope(
      onWillPop: () async => !requireAcceptance,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 24 * scale,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.privacyPolicyTitle,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                SizedBox(height: 24 * scale),
                Text(
                  l10n.privacyPolicyPrompt,
                  textAlign: TextAlign.center,
                  style: promptStyle,
                ),
                SizedBox(height: 16 * scale),
                Center(
                  child: InkWell(
                    onTap: () => openPrivacyPolicyLink(context),
                    borderRadius: BorderRadius.circular(12 * scale),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 8 * scale,
                      ),
                      child: Text(
                        l10n.privacyPolicyLearnMore,
                        style: linkStyle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          if (requireAcceptance && !kIsWeb) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              switch (defaultTargetPlatform) {
                                case TargetPlatform.android:
                                case TargetPlatform.iOS:
                                  SystemNavigator.pop();
                                  break;
                                default:
                                  break;
                              }
                            });
                          }
                        },
                        child: Text(l10n.privacyPolicyDecline),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.privacyPolicyAccept),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
