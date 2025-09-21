import 'package:flutter/material.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'flags.dart';

Future<String?> showFlagPicker(
  BuildContext context, {
  String? selectedFlag,
}) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: _FlagPickerContent(
            title: l10n.selectPlayerFlag,
            selectedFlag: selectedFlag,
          ),
        ),
      );
    },
  );
}

class _FlagPickerContent extends StatefulWidget {
  final String title;
  final String? selectedFlag;

  const _FlagPickerContent({required this.title, this.selectedFlag});

  @override
  State<_FlagPickerContent> createState() => _FlagPickerContentState();
}

class _FlagPickerContentState extends State<_FlagPickerContent> {
  String? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedFlag;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 72).floor().clamp(4, 8);
              return GridView.builder(
                shrinkWrap: true,
                itemCount: kWorldFlags.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final flag = kWorldFlags[index];
                  final selected = flag == _current;
                  return _FlagTile(
                    flag: flag,
                    selected: selected,
                    onTap: () {
                      setState(() => _current = flag);
                      Navigator.pop(context, flag);
                    },
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ),
      ],
    );
  }
}

class _FlagTile extends StatelessWidget {
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _FlagTile({
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final borderColor = selected ? cs.primary : cs.outlineVariant;
    final background = selected
        ? cs.primary.withOpacity(0.15)
        : cs.surfaceVariant.withOpacity(0.4);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            flag,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
