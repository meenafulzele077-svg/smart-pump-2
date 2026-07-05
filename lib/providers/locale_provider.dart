import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final box = Hive.box(AppConstants.settingsBox);
    final saved = box.get(AppConstants.keyLocale, defaultValue: 'en') as String;
    return Locale(saved);
  }

  void setLocale(String languageCode) {
    state = Locale(languageCode);
    Hive.box(AppConstants.settingsBox).put(AppConstants.keyLocale, languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
