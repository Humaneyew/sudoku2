import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Тема приложения"),
          RadioListTile<AppTheme>(
            title: const Text("Системная"),
            value: AppTheme.system,
            groupValue: app.theme,
            onChanged: (v) {
              if (v != null) {
                app.setTheme(v);
              }
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text("Светлая"),
            value: AppTheme.light,
            groupValue: app.theme,
            onChanged: (v) {
              if (v != null) {
                app.setTheme(v);
              }
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text("Тёмная"),
            value: AppTheme.dark,
            groupValue: app.theme,
            onChanged: (v) {
              if (v != null) {
                app.setTheme(v);
              }
            },
          ),
          const Divider(height: 32),

          _sectionTitle("Язык"),
          ...AppLanguage.values.map(
                (lang) => RadioListTile<AppLanguage>(
              title: Text(lang.nameLocal),
              value: lang,
              groupValue: app.lang,
              onChanged: (v) {
                if (v != null) {
                  app.setLang(v);
                }
              },
            ),
          ),
          const Divider(height: 32),

          _sectionTitle("Звуки и музыка"),
          SwitchListTile(
            title: const Text("Звуковые эффекты"),
            value: app.soundsEnabled,
            onChanged: (v) => app.toggleSounds(v),
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: const Text("Фоновая музыка"),
            value: app.musicEnabled,
            onChanged: (v) => app.toggleMusic(v),
            secondary: const Icon(Icons.music_note),
          ),
          const Divider(height: 32),

          _sectionTitle("Разное"),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("О приложении"),
            subtitle: const Text("Версия 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Sudoku Deluxe",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2025 Sudoku Inc.",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
