import 'package:flutter/material.dart';
import 'translations.dart';

/// A lightweight, hand-rolled localization system.
///
/// We intentionally avoid the `flutter gen-l10n` build step so this project
/// compiles without a `flutter pub get` + codegen pass having been run first.
/// For a larger production app, swap this for ARB + `gen-l10n` and keep the
/// same `context.l10n.t('key')` call sites — only this file would change.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  static const localeNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'mr': 'मराठी',
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Translate [key]. Falls back to English, then to the key itself.
  String t(String key) {
    final table = kTranslations[locale.languageCode] ?? kTranslations['en']!;
    return table[key] ?? kTranslations['en']![key] ?? key;
  }

  static const delegate = _AppLocalizationsDelegate();
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.map((l) => l.languageCode).contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
