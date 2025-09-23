import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';
import 'layout/layout_scale.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final scale = context.layoutScale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSectionTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8 * scale),
        children: [
          ...AppLanguage.values.map(
            (lang) => RadioListTile<AppLanguage>(
              key: ValueKey('lang-${lang.name}'),
              title: Text(lang.displayName(l10n)),
              value: lang,
              groupValue: app.lang,
              onChanged: (value) {
                if (value != null) {
                  unawaited(app.setLang(value));
                }
              },
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16 * scale),
            ),
          ),
        ],
      ),
    );
  }
}
