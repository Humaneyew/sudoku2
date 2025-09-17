#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import OrderedDict
from pathlib import Path
from typing import Dict, List, Tuple

ARB_DIR = Path('lib/l10n')
OUTPUT_FILE = Path('lib/flutter_gen/gen_l10n/app_localizations.dart')

TYPE_MAP = {
    'int': 'int',
    'String': 'String',
    'num': 'num',
}

PLURAL_CATEGORIES = ['zero', 'one', 'two', 'few', 'many', 'other']


def load_arb(path: Path) -> OrderedDict[str, object]:
    with path.open('r', encoding='utf-8') as f:
        return json.load(f, object_pairs_hook=OrderedDict)


def ordered_placeholder_names(value: str, placeholders: Dict[str, object]) -> List[str]:
    indices: List[Tuple[int, str]] = []
    for name in placeholders:
        marker = '{' + name
        try:
            index = value.index(marker)
        except ValueError:
            index = len(value)
        indices.append((index, name))
    indices.sort()
    return [name for _, name in indices]


def parse_plural(value: str, placeholder: str) -> Tuple[str, Dict[str, str], str]:
    token = '{' + placeholder + ', plural,'
    start = value.index(token)
    prefix = value[:start]
    depth = 0
    end = start
    for idx in range(start, len(value)):
        char = value[idx]
        if char == '{':
            depth += 1
        elif char == '}':
            depth -= 1
            if depth == 0:
                end = idx
                break
    block = value[start:end + 1]
    suffix = value[end + 1:]

    inner = block[len(token):-1]
    cases: Dict[str, str] = OrderedDict()
    rest = inner
    while rest.strip():
        rest = rest.lstrip()
        matched = False
        for category in PLURAL_CATEGORIES:
            prefix_token = category + ' '
            if rest.startswith(prefix_token):
                matched = True
                rest = rest[len(prefix_token):]
                if not rest.startswith('{'):
                    raise ValueError(f'Expected "{{" after plural category {category}')
                depth = 0
                for idx, ch in enumerate(rest):
                    if ch == '{':
                        depth += 1
                    elif ch == '}':
                        depth -= 1
                        if depth == 0:
                            text = rest[1:idx]
                            cases[category] = text
                            rest = rest[idx + 1:]
                            break
                else:
                    raise ValueError('Unclosed plural case for ' + category)
                break
        if not matched:
            raise ValueError('Could not parse plural cases from: ' + rest)
    return prefix, cases, suffix


def escape_dart_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def locale_constructor(locale: str) -> str:
    parts = locale.replace('-', '_').split('_')
    if len(parts) == 1:
        return f"Locale('{parts[0]}')"
    if len(parts) == 2:
        return f"Locale('{parts[0]}', '{parts[1]}')"
    if len(parts) == 3:
        return (
            "Locale.fromSubtags(languageCode: '{lang}', scriptCode: '{script}', "
            "countryCode: '{country}')"
        ).format(lang=parts[0], script=parts[1], country=parts[2])
    raise ValueError(f'Unsupported locale format: {locale}')


def locale_name(locale: str) -> str:
    normalized = locale.replace('-', '_')
    parts = normalized.split('_')
    return ''.join(part.capitalize() for part in parts)


def build_signature(entry: Dict[str, object]) -> List[str]:
    key = entry['key']
    placeholders: Dict[str, object] = entry['placeholders']
    placeholder_order: List[str] = entry['placeholder_order']
    if not placeholders:
        return [f'String get {key};']
    if entry['is_plural']:
        name = entry['plural_placeholder']
        type_name = TYPE_MAP[placeholders[name]['type']]
        return [f'String {key}({type_name} {name});']
    params = []
    for name in placeholder_order:
        placeholder = placeholders[name]
        type_name = TYPE_MAP[placeholder['type']]
        params.append(f'{type_name} {name}')
    param_str = ', '.join(params)
    return [f'String {key}({param_str});']


def build_placeholder_method(entry: Dict[str, object], translation: str) -> List[str]:
    placeholders: Dict[str, object] = entry['placeholders']
    placeholder_order: List[str] = entry['placeholder_order']
    params = []
    for name in placeholder_order:
        placeholder = placeholders[name]
        type_name = TYPE_MAP[placeholder['type']]
        params.append(f'{type_name} {name}')
    param_str = ', '.join(params)
    body = translation
    for name in placeholder_order:
        body = body.replace('{' + name + '}', '${' + name + '}')
    body_literal = escape_dart_string(body)
    method_name = entry['key']
    return [
        f'String {method_name}({param_str}) {{',
        f'  return {body_literal};',
        '}',
    ]


def build_plural_method(entry: Dict[str, object], translation: str) -> List[str]:
    placeholders: Dict[str, object] = entry['placeholders']
    name = entry['plural_placeholder']
    placeholder = placeholders[name]
    type_name = TYPE_MAP[placeholder['type']]
    prefix, cases, suffix = parse_plural(translation, name)
    case_lines = []
    for category in PLURAL_CATEGORIES:
        if category not in cases:
            continue
        text = cases[category].replace('#', '${' + name + '}')
        case_lines.append(f'    {category}: {escape_dart_string(text)},')
    lines = [
        f'String {entry["key"]}({type_name} {name}) {{',
        '  final value = intl.Intl.pluralLogic(',
        f'    {name},',
        '    locale: localeName,',
    ]
    lines.extend(case_lines)
    lines.append('  );')
    parts = []
    if prefix:
        parts.append(escape_dart_string(prefix))
    parts.append('value')
    if suffix:
        parts.append(escape_dart_string(suffix))
    if len(parts) == 1:
        return_line = f'  return {parts[0]};'
    else:
        return_line = '  return ' + ' + '.join(parts) + ';'
    lines.append(return_line)
    lines.append('}')
    return lines


def generate_locale_class(
    locale: str, entries: List[Dict[str, object]], translations: OrderedDict[str, str]
) -> List[str]:
    class_name = f'AppLocalizations{locale_name(locale)}'
    lines: List[str] = []
    lines.append(f'class {class_name} extends AppLocalizations {{')
    lines.append(f'  {class_name}() : super({escape_dart_string(locale)});')
    lines.append('')
    for entry in entries:
        key = entry['key']
        translation = translations[key]
        placeholders: Dict[str, object] = entry['placeholders']
        lines.append('  @override')
        if not placeholders:
            value = escape_dart_string(translation)
            lines.append(f'  String get {key} => {value};')
            lines.append('')
            continue
        if entry['is_plural']:
            method_lines = build_plural_method(entry, translation)
        else:
            method_lines = build_placeholder_method(entry, translation)
        lines.extend(['  ' + line for line in method_lines])
        lines.append('')
    if lines[-1] == '':
        lines.pop()
    lines.append('}')
    return lines


def generate() -> None:
    template_path = ARB_DIR / 'app_en.arb'
    template_data = load_arb(template_path)

    entries = []
    for key, value in template_data.items():
        if key.startswith('@') or key == '@@locale':
            continue
        metadata = template_data.get(f'@{key}', {})
        placeholders = metadata.get('placeholders', {})
        placeholders = OrderedDict(placeholders)
        placeholder_order = ordered_placeholder_names(value, placeholders)
        is_plural = False
        plural_placeholder = None
        for name in placeholder_order:
            marker = '{' + name + ', plural,'
            if marker in value:
                is_plural = True
                plural_placeholder = name
                break
        entries.append(
            {
                'key': key,
                'value': value,
                'placeholders': placeholders,
                'placeholder_order': placeholder_order,
                'is_plural': is_plural,
                'plural_placeholder': plural_placeholder,
            }
        )

    locales: List[str] = []
    locale_translations: Dict[str, OrderedDict[str, str]] = {}
    for arb_path in sorted(ARB_DIR.glob('app_*.arb')):
        data = load_arb(arb_path)
        locale = data.get('@@locale')
        if not isinstance(locale, str):
            raise ValueError(f'Locale missing in {arb_path}')
        locales.append(locale)
        translations = OrderedDict()
        for entry in entries:
            key = entry['key']
            if key not in data:
                raise KeyError(f'Missing key {key} in {arb_path}')
            translations[key] = data[key]
        locale_translations[locale] = translations

    lines: List[str] = []
    lines.append('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    lines.append('// ignore_for_file: type=lint, unused_import')
    lines.append("import 'package:flutter/foundation.dart';")
    lines.append("import 'package:flutter/widgets.dart';")
    lines.append("import 'package:intl/intl.dart' as intl;")
    lines.append('')
    lines.append('abstract class AppLocalizations {')
    lines.append('  AppLocalizations(String locale)')
    lines.append('      : localeName = intl.Intl.canonicalizedLocale(locale);')
    lines.append('')
    lines.append('  final String localeName;')
    lines.append('')
    lines.append('  static AppLocalizations? of(BuildContext context) {')
    lines.append('    return Localizations.of<AppLocalizations>(context, AppLocalizations);')
    lines.append('  }')
    lines.append('')
    lines.append('  static const LocalizationsDelegate<AppLocalizations> delegate =')
    lines.append('      _AppLocalizationsDelegate();')
    lines.append('')
    supported_locales = '\n'.join(
        f"    {locale_constructor(locale)}," for locale in locales
    )
    lines.append('  static const List<Locale> supportedLocales = <Locale>[\n' + supported_locales + '\n  ];')
    lines.append('')
    supported_names = '\n'.join(
        f"    {escape_dart_string(locale)}," for locale in locales
    )
    lines.append('  static const List<String> _supportedLocaleNames = <String>[\n' + supported_names + '\n  ];')
    lines.append('')
    lines.append('  static bool _isSupported(Locale locale) {')
    lines.append('    return _supportedLocaleNames.contains(locale.toString()) ||')
    lines.append('        _supportedLocaleNames.contains(locale.languageCode);')
    lines.append('  }')
    lines.append('')
    for entry in entries:
        signature = build_signature(entry)
        for line in signature:
            lines.append('  ' + line)
        lines.append('')
    if lines[-1] == '':
        lines.pop()
    lines.append('}')
    lines.append('')
    lines.append('class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {')
    lines.append('  const _AppLocalizationsDelegate();')
    lines.append('')
    lines.append('  @override')
    lines.append('  bool isSupported(Locale locale) => AppLocalizations._isSupported(locale);')
    lines.append('')
    lines.append('  @override')
    lines.append('  Future<AppLocalizations> load(Locale locale) {')
    lines.append('    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));')
    lines.append('  }')
    lines.append('')
    lines.append('  @override')
    lines.append('  bool shouldReload(_AppLocalizationsDelegate old) => false;')
    lines.append('}')
    lines.append('')
    lines.append('AppLocalizations lookupAppLocalizations(Locale locale) {')
    lines.append('  if (!AppLocalizations._isSupported(locale)) {')
    lines.append('    throw FlutterError(')
    lines.append("        'AppLocalizations.delegate failed to load unsupported locale "
                 "\"' + locale.toString() + '\".');")
    lines.append('  }')
    lines.append('  switch (locale.toString()) {')
    for locale in locales:
        lines.append(f'    case {escape_dart_string(locale)}:')
        lines.append(f'      return AppLocalizations{locale_name(locale)}();')
    lines.append('  }')
    lines.append('  switch (locale.languageCode) {')
    for locale in locales:
        lang = locale.split('_')[0]
        lines.append(f'    case {escape_dart_string(lang)}:')
        lines.append(f'      return AppLocalizations{locale_name(locale)}();')
    lines.append('  }')
    lines.append('  throw FlutterError(')
    lines.append("      'AppLocalizations.delegate failed to load unsupported locale '" +
                 ' + locale.toString() + ".");')
    lines.append('}')
    lines.append('')
    for locale in locales:
        class_lines = generate_locale_class(locale, entries, locale_translations[locale])
        lines.extend(class_lines)
        lines.append('')
    if lines[-1] == '':
        lines.pop()

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT_FILE.open('w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    generate()
