import 'package:flutter/material.dart';

import '../flutter_gen/gen_l10n/app_localizations.dart';
import '../layout/layout_scale.dart';

const _privacyPolicyAsset = 'assets/privacy_policy/privacy-policy.md';

Future<bool> showPrivacyPolicyDialog(
  BuildContext context, {
  required bool requireAcceptance,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: !requireAcceptance,
    builder: (context) {
      return _PrivacyPolicyDialog(requireAcceptance: requireAcceptance);
    },
  );
  return result ?? false;
}

class _PrivacyPolicyDialog extends StatelessWidget {
  final bool requireAcceptance;

  const _PrivacyPolicyDialog({required this.requireAcceptance});

  Future<String> _loadPolicy(BuildContext context) {
    return DefaultAssetBundle.of(context).loadString(_privacyPolicyAsset);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scale = context.layoutScale;
    final colors = theme.colorScheme;
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.4);
    final contentHeight = (360 * scale).clamp(280.0, 520.0) as double;

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
                SizedBox(height: 16 * scale),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * scale),
                    color: colors.surfaceVariant.withOpacity(
                      theme.brightness == Brightness.dark ? 0.2 : 0.4,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12 * scale),
                    child: SizedBox(
                      height: contentHeight,
                      child: FutureBuilder<String>(
                        future: _loadPolicy(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16 * scale),
                                child: Text(
                                  l10n.privacyPolicyLoadError,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            );
                          }
                          final policy = snapshot.data ?? '';
                          return Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(16 * scale),
                              child: SelectableText(
                                policy,
                                style: bodyStyle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context)
                        .pop(requireAcceptance),
                    child: Text(
                      requireAcceptance
                          ? l10n.privacyPolicyAccept
                          : l10n.privacyPolicyClose,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
