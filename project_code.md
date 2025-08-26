# test_tab_move
## Project Structure

```
test_tab_move/
├── lib/
    ├── core/
    │   ├── const/
    │   │   ├── enum_debounce_key.dart
    │   │   └── enum_hive_key.dart
    │   ├── localization/
    │   │   ├── l10n/
    │   │   │   ├── intl_en.arb
    │   │   │   └── intl_ko.arb
    │   │   └── provider/
    │   │   │   ├── language_provider.dart
    │   │   │   └── locale_state_provider.dart
    │   ├── theme/
    │   │   ├── foundation/
    │   │   │   ├── app_color.dart
    │   │   │   ├── app_font.dart
    │   │   │   ├── app_mode.dart
    │   │   │   └── app_theme.dart
    │   │   ├── provider/
    │   │   │   └── theme_provider.dart
    │   │   ├── resources/
    │   │   │   ├── dark_palette.dart
    │   │   │   ├── font.dart
    │   │   │   └── light_palette.dart
    │   │   ├── dark_theme.dart
    │   │   └── light_theme.dart
    │   ├── ui/
    │   │   ├── title_bar/
    │   │   │   ├── provider/
    │   │   │   │   └── is_window_maximized_provider.dart
    │   │   │   └── app_title_bar.dart
    │   │   ├── app_button.dart
    │   │   └── app_icon_button.dart
    │   └── util/
    │   │   ├── debounce/
    │   │       ├── debounce_operation.dart
    │   │       └── debounce_service.dart
    │   │   └── svg/
    │   │       ├── enum/
    │   │           └── color_target.dart
    │   │       ├── model/
    │   │           └── enum_svg_asset.dart
    │   │       ├── widget/
    │   │           └── svg_icon.dart
    │   │       └── svg_util.dart
    ├── features/
    │   ├── split_workspace/
    │   │   ├── extension/
    │   │   │   └── drop_zone_type_extension.dart
    │   │   ├── models/
    │   │   │   └── split_panel_model.dart
    │   │   ├── providers/
    │   │   │   ├── drop_zone_provider.dart
    │   │   │   ├── global_drag_provider.dart
    │   │   │   ├── group_drag_provider.dart
    │   │   │   ├── split_workspace_provider.dart
    │   │   │   └── workspace_computed_providers.dart
    │   │   ├── services/
    │   │   │   ├── split_service.dart
    │   │   │   ├── tab_service.dart
    │   │   │   └── workspace_helpers.dart
    │   │   └── widgets/
    │   │   │   ├── group_content.dart
    │   │   │   ├── group_tab_bar.dart
    │   │   │   ├── resizable_splitter.dart
    │   │   │   ├── split_container.dart
    │   │   │   ├── split_preview_overlay.dart
    │   │   │   └── tab_group.dart
    │   └── tab_system/
    │   │   ├── models/
    │   │       └── tab_model.dart
    │   │   ├── screens/
    │   │       └── tab_workspace_screen.dart
    │   │   └── widgets/
    │   │       └── tab_item.dart
    └── main.dart
└── pubspec.yaml
```

## lib/core/const/enum_debounce_key.dart
```dart
enum DebounceKey {
  locale('locale'),
  theme('theme'),
  ;

  final String key;
  const DebounceKey(this.key);
}

```
## lib/core/const/enum_hive_key.dart
```dart
enum HiveKey {
  boxSettings('init_box_settings'),
  locale('locale'),
  theme('theme'),
  ;

  final String key;

  const HiveKey(this.key);
}

```
## lib/core/localization/l10n/intl_en.arb
```arb
{
  "appTitle": "Flutter Snippets",
  "themeMode": "Theme Mode",
  "language": "Language",
  "lightTheme": "Light",
  "darkTheme": "Dark",
  "systemTheme": "System",
  "english": "English",
  "korean": "Korean",
  "welcomeMessage": "Welcome to Flutter Snippets App!",
  "description": "This is an example page with theme and language switching."
}
```
## lib/core/localization/l10n/intl_ko.arb
```arb
{
  "appTitle": "플러터 스니펫",
  "themeMode": "테마 모드",
  "language": "언어",
  "lightTheme": "라이트",
  "darkTheme": "다크",
  "systemTheme": "시스템",
  "english": "영어",
  "korean": "한국어",
  "welcomeMessage": "플러터 스니펫 앱에 오신 것을 환영합니다!",
  "description": "테마와 언어 전환이 가능한 예제 페이지입니다."
}
```
## lib/core/localization/provider/language_provider.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../generated/l10n.dart';
import 'locale_state_provider.dart';

part 'language_provider.g.dart';

@Riverpod(dependencies: [LocaleState])
S language(Ref ref) {
  ref.watch(localeStateProvider);
  return S.current;
}

```
## lib/core/localization/provider/locale_state_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../const/enum_debounce_key.dart';
import '../../const/enum_hive_key.dart';
import '../../util/debounce/debounce_service.dart';

part 'locale_state_provider.g.dart';

@Riverpod(dependencies: [], keepAlive: true)
class LocaleState extends _$LocaleState {
  Box<String>? _box;

  @override
  Locale build() {
    try {
      final box = Hive.box<String>(HiveKey.boxSettings.key);
      final savedLocale = box.get(HiveKey.locale.key);

      if (savedLocale != null) {
        return Locale(savedLocale);
      }
    } catch (e) {
      // 에러시 기본값
    }

    return const Locale('ko');
  }

  /// supported locale list
  static const supportedLocales = [
    Locale('ko'),
    Locale('en'),
  ];

  /// 로케일 변경
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> setLocale(Locale locale) async {
    // 1. UI 즉시 업데이트 (언어 변경은 즉시 반영되어야 함)
    state = locale;

    // 2. 저장은 debounce로 처리
    _scheduleLocaleSave(locale);
  }

  /// 로케일 토글 (한국어 ↔ 영어)
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> toggleLocale() async {
    final newLocale =
        state.languageCode == 'ko' ? const Locale('en') : const Locale('ko');

    // 1. UI 즉시 업데이트
    state = newLocale;

    // 2. 저장은 debounce로 처리
    _scheduleLocaleSave(newLocale);
  }

  /// 저장된 로케일 불러오기 (앱 시작 시 한 번만 호출)
  Future<void> loadSavedLocale() async {
    _box ??= await _openBox();
    final savedLocale = _box!.get(HiveKey.locale.key);
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  /// 현재 대기 중인 로케일 저장 작업을 즉시 실행
  ///
  /// 앱 종료 시나 긴급히 저장이 필요한 경우 사용
  /// 반환값: 저장 작업이 있었으면 true, 없었으면 false
  Future<bool> flushLocaleSave() async {
    return await DebounceService.instance
        .executeImmediately(DebounceKey.locale.key);
  }

  /// Provider 정리 시 대기 중인 저장 작업 완료
  ///
  /// 이 메서드는 Provider가 dispose될 때 자동으로 호출되지 않으므로
  /// 필요한 경우 수동으로 호출해야 함
  Future<void> dispose() async {
    await flushLocaleSave();
  }

  /// 로케일 저장 작업을 debounce 서비스에 스케줄링
  void _scheduleLocaleSave(Locale locale) {
    DebounceService.instance.schedule(
      key: DebounceKey.locale.key,
      operation: () => _saveLocale(locale),
      delay: const Duration(seconds: 1), // 로케일은 기본 500ms
    );
  }

  /// 로케일 저장 (실제 저장 로직)
  Future<void> _saveLocale(Locale locale) async {
    try {
      _box ??= await _openBox();
      await _box!.put(HiveKey.locale.key, locale.languageCode);
    } catch (e) {
      // 저장 실패 시 로그 (에러를 던지지 않음으로써 UI 동작은 계속됨)
    }
  }

  Future<Box<String>> _openBox() async {
    if (!Hive.isBoxOpen(HiveKey.boxSettings.key)) {
      return await Hive.openBox(HiveKey.boxSettings.key);
    }
    return Hive.box(HiveKey.boxSettings.key);
  }
}

```
## lib/core/theme/dark_theme.dart
```dart
import 'package:flutter/material.dart';

import 'foundation/app_theme.dart';
import 'resources/dark_palette.dart';
import 'resources/font.dart';

class DarkTheme implements AppTheme {
  static final DarkTheme _instance = DarkTheme._internal();

  factory DarkTheme() => _instance;

  late final AppColor _color;
  late final AppFont _font;

  DarkTheme._internal() {
    _color = const AppColor(
      primary: DarkPalette.primary,
      primarySoft: DarkPalette.primarySoft,
      primaryVariant: DarkPalette.primaryVariant,
      primaryHover: DarkPalette.primaryHover,
      primarySplash: DarkPalette.primarySplash,
      primaryHighlight: DarkPalette.primaryHighlight,
      secondary: DarkPalette.secondary,
      secondaryVariant: DarkPalette.secondaryVariant,
      background: DarkPalette.background,
      surface: DarkPalette.surface,
      surfaceVariant: DarkPalette.surfaceVariant,
      surfaceVariantSoft: DarkPalette.surfaceVariantSoft,
      terminalBackground: DarkPalette.terminalBackground,
      terminalSurface: DarkPalette.terminalSurface,
      terminalBorder: DarkPalette.terminalBorder,
      onPrimary: DarkPalette.onPrimary,
      onSecondary: DarkPalette.onSecondary,
      onBackground: DarkPalette.onBackground,
      onBackgroundSoft: DarkPalette.onBackgroundSoft,
      onSurface: DarkPalette.onSurface,
      onSurfaceVariant: DarkPalette.onSurfaceVariant,
      terminalText: DarkPalette.terminalText,
      terminalPrompt: DarkPalette.terminalPrompt,
      terminalCommand: DarkPalette.terminalCommand,
      terminalOutput: DarkPalette.terminalOutput,
      success: DarkPalette.success,
      successVariant: DarkPalette.successVariant,
      error: DarkPalette.error,
      errorVariant: DarkPalette.errorVariant,
      warning: DarkPalette.warning,
      info: DarkPalette.info,
      connected: DarkPalette.connected,
      disconnected: DarkPalette.disconnected,
      connecting: DarkPalette.connecting,
      hover: DarkPalette.hover,
      splash: DarkPalette.splash,
      highlight: DarkPalette.highlight,
      pressed: DarkPalette.pressed,
      disabled: DarkPalette.disabled,
      border: DarkPalette.border,
      divider: DarkPalette.divider,
      outline: DarkPalette.outline,
      neonPurple: DarkPalette.neonPurple,
      neonGreen: DarkPalette.neonGreen,
      neonPink: DarkPalette.neonPink,
      neonBlue: DarkPalette.neonBlue,
      gamingHighlight: DarkPalette.gamingHighlight,
      gamingShadow: DarkPalette.gamingShadow,
      powerGlow: DarkPalette.powerGlow,
      neonTrail: DarkPalette.neonTrail,
      energyCore: DarkPalette.energyCore,
    );

    _font = AppFont(
      font: const Pretendard(),
      monoFont: const SpaceMono(),
      textColor: _color.onBackground,
      hintColor: _color.onSurfaceVariant,
    );
  }

  @override
  AppColor get color => _color;

  @override
  AppFont get font => _font;

  @override
  AppMode get mode => AppMode.dark;

  @override
  ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _color.background,
      );
}

```
## lib/core/theme/foundation/app_color.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_theme.dart';

class AppColor {
  // Primary colors
  final Color primary;
  final Color primarySoft;
  final Color primaryVariant;
  final Color primaryHover;
  final Color primarySplash;
  final Color primaryHighlight;

  final Color secondary;
  final Color secondaryVariant;

  // Background colors
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceVariantSoft;

  // Terminal specific colors
  final Color terminalBackground;
  final Color terminalSurface;
  final Color terminalBorder;

  // Text colors
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onBackgroundSoft;
  final Color onSurface;
  final Color onSurfaceVariant;

  // Terminal text colors
  final Color terminalText;
  final Color terminalPrompt;
  final Color terminalCommand;
  final Color terminalOutput;

  // Status colors
  final Color success;
  final Color successVariant;
  final Color error;
  final Color errorVariant;
  final Color warning;
  final Color info;

  // Connection status
  final Color connected;
  final Color disconnected;
  final Color connecting;

  // Interactive colors
  final Color hover;
  final Color splash;
  final Color highlight;
  final Color pressed;
  final Color disabled;
  final Color border;

  // Divider and outline
  final Color divider;
  final Color outline;

  // Accent colors for neon effects
  final Color neonPurple;
  final Color neonGreen;
  final Color neonPink;
  final Color neonBlue;

  // Gaming-specific colors
  final Color gamingHighlight;
  final Color gamingShadow;
  final Color powerGlow;
  final Color neonTrail;
  final Color energyCore;

  const AppColor({
    required this.primary,
    required this.primarySoft,
    required this.primaryVariant,
    required this.primaryHover,
    required this.primarySplash,
    required this.primaryHighlight,
    required this.secondary,
    required this.secondaryVariant,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceVariantSoft,
    required this.terminalBackground,
    required this.terminalSurface,
    required this.terminalBorder,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onBackgroundSoft,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.terminalText,
    required this.terminalPrompt,
    required this.terminalCommand,
    required this.terminalOutput,
    required this.success,
    required this.successVariant,
    required this.error,
    required this.errorVariant,
    required this.warning,
    required this.info,
    required this.connected,
    required this.disconnected,
    required this.connecting,
    required this.hover,
    required this.splash,
    required this.highlight,
    required this.pressed,
    required this.disabled,
    required this.border,
    required this.divider,
    required this.outline,
    required this.neonPurple,
    required this.neonGreen,
    required this.neonPink,
    required this.neonBlue,
    required this.gamingHighlight,
    required this.gamingShadow,
    required this.powerGlow,
    required this.neonTrail,
    required this.energyCore,
  });

  AppColor copyWith({
    Color? primary,
    Color? primarySoft,
    Color? primaryVariant,
    Color? primaryHover,
    Color? primarySplash,
    Color? primaryHighlight,
    Color? secondary,
    Color? secondaryVariant,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceVariantSoft,
    Color? terminalBackground,
    Color? terminalSurface,
    Color? terminalBorder,
    Color? onPrimary,
    Color? onSecondary,
    Color? onBackground,
    Color? onBackgroundSoft,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? terminalText,
    Color? terminalPrompt,
    Color? terminalCommand,
    Color? terminalOutput,
    Color? success,
    Color? successVariant,
    Color? error,
    Color? errorVariant,
    Color? warning,
    Color? info,
    Color? connected,
    Color? disconnected,
    Color? connecting,
    Color? hover,
    Color? splash,
    Color? highlight,
    Color? pressed,
    Color? disabled,
    Color? border,
    Color? divider,
    Color? outline,
    Color? neonPurple,
    Color? neonGreen,
    Color? neonPink,
    Color? neonBlue,
    Color? gamingHighlight,
    Color? gamingShadow,
    Color? powerGlow,
    Color? neonTrail,
    Color? energyCore,
  }) {
    return AppColor(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      primaryHover: primaryHover ?? this.primaryHover,
      primarySplash: primarySplash ?? this.primarySplash,
      primaryHighlight: primaryHighlight ?? this.primaryHighlight,
      secondary: secondary ?? this.secondary,
      secondaryVariant: secondaryVariant ?? this.secondaryVariant,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceVariantSoft: surfaceVariantSoft ?? this.surfaceVariantSoft,
      terminalBackground: terminalBackground ?? this.terminalBackground,
      terminalSurface: terminalSurface ?? this.terminalSurface,
      terminalBorder: terminalBorder ?? this.terminalBorder,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onBackground: onBackground ?? this.onBackground,
      onBackgroundSoft: onBackgroundSoft ?? this.onBackgroundSoft,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      terminalText: terminalText ?? this.terminalText,
      terminalPrompt: terminalPrompt ?? this.terminalPrompt,
      terminalCommand: terminalCommand ?? this.terminalCommand,
      terminalOutput: terminalOutput ?? this.terminalOutput,
      success: success ?? this.success,
      successVariant: successVariant ?? this.successVariant,
      error: error ?? this.error,
      errorVariant: errorVariant ?? this.errorVariant,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      connected: connected ?? this.connected,
      disconnected: disconnected ?? this.disconnected,
      connecting: connecting ?? this.connecting,
      hover: hover ?? this.hover,
      splash: splash ?? this.splash,
      highlight: highlight ?? this.highlight,
      pressed: pressed ?? this.pressed,
      disabled: disabled ?? this.disabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      outline: outline ?? this.outline,
      neonPurple: neonPurple ?? this.neonPurple,
      neonGreen: neonGreen ?? this.neonGreen,
      neonPink: neonPink ?? this.neonPink,
      neonBlue: neonBlue ?? this.neonBlue,
      gamingHighlight: gamingHighlight ?? this.gamingHighlight,
      gamingShadow: gamingShadow ?? this.gamingShadow,
      powerGlow: powerGlow ?? this.powerGlow,
      neonTrail: neonTrail ?? this.neonTrail,
      energyCore: energyCore ?? this.energyCore,
    );
  }
}

```
## lib/core/theme/foundation/app_font.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_theme.dart';

class AppFont {
  AppFont({
    required this.font,
    required this.monoFont,
    required this.textColor,
    required this.hintColor,
  });

  final Font font;
  final Font monoFont;
  final Color textColor;
  final Color hintColor;

  // ==================== Pretendard Regular ====================
  TextStyle get regularText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);

  // ==================== Pretendard Medium ====================
  TextStyle get mediumText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);

  // ==================== Pretendard SemiBold ====================
  TextStyle get semiBoldText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);

  // ==================== Pretendard Bold ====================
  TextStyle get boldText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);

  // ==================== Space Mono Regular ====================
  TextStyle get monoRegularText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);

  // ==================== Space Mono Medium ====================
  TextStyle get monoMediumText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);

  // ==================== Space Mono SemiBold ====================
  TextStyle get monoSemiBoldText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);

  // ==================== Space Mono Bold ====================
  TextStyle get monoBoldText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);

  // ==================== Hint 텍스트 ====================
  TextStyle get hintText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);

  // ==================== 유틸리티 메소드 ====================
  TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);
  TextStyle withWeight(TextStyle style, FontWeight weight) =>
      style.copyWith(fontWeight: weight);
  TextStyle withSize(TextStyle style, double size) =>
      style.copyWith(fontSize: size);
  TextStyle withHeight(TextStyle style, double height) =>
      style.copyWith(height: height);
  TextStyle withOpacity(TextStyle style, double opacity) =>
      style.copyWith(color: style.color?.withValues(alpha: opacity));

  AppFont copyWith({
    Font? font,
    Font? monoFont,
    Color? textColor,
    Color? hintColor,
  }) {
    return AppFont(
      font: font ?? this.font,
      monoFont: monoFont ?? this.monoFont,
      textColor: textColor ?? this.textColor,
      hintColor: hintColor ?? this.hintColor,
    );
  }
}

```
## lib/core/theme/foundation/app_mode.dart
```dart
part of 'app_theme.dart';

enum AppMode {
  light,
  dark;

  String toJson() => name;

  static AppMode fromJson(String json) {
    return AppMode.values.firstWhere(
      (mode) => mode.name == json,
      orElse: () => AppMode.light,
    );
  }
}

```
## lib/core/theme/foundation/app_theme.dart
```dart
import 'package:flutter/material.dart';

import '../resources/font.dart';

part 'app_color.dart';
part 'app_font.dart';
part 'app_mode.dart';

abstract class AppTheme {
  AppMode get mode;
  AppColor get color;
  AppFont get font;

  ThemeData get themeData;
}

```
## lib/core/theme/light_theme.dart
```dart
import 'package:flutter/material.dart';

import 'foundation/app_theme.dart';
import 'resources/font.dart';
import 'resources/light_palette.dart';

class LightTheme implements AppTheme {
  static final LightTheme _instance = LightTheme._internal();

  factory LightTheme() => _instance;

  late final AppColor _color;
  late final AppFont _font;

  LightTheme._internal() {
    _color = const AppColor(
      primary: LightPalette.primary,
      primarySoft: LightPalette.primarySoft,
      primaryVariant: LightPalette.primaryVariant,
      primaryHover: LightPalette.primaryHover,
      primarySplash: LightPalette.primarySplash,
      primaryHighlight: LightPalette.primaryHighlight,
      secondary: LightPalette.secondary,
      secondaryVariant: LightPalette.secondaryVariant,
      background: LightPalette.background,
      surface: LightPalette.surface,
      surfaceVariant: LightPalette.surfaceVariant,
      surfaceVariantSoft: LightPalette.surfaceVariantSoft,
      terminalBackground: LightPalette.terminalBackground,
      terminalSurface: LightPalette.terminalSurface,
      terminalBorder: LightPalette.terminalBorder,
      onPrimary: LightPalette.onPrimary,
      onSecondary: LightPalette.onSecondary,
      onBackground: LightPalette.onBackground,
      onBackgroundSoft: LightPalette.onBackgroundSoft,
      onSurface: LightPalette.onSurface,
      onSurfaceVariant: LightPalette.onSurfaceVariant,
      terminalText: LightPalette.terminalText,
      terminalPrompt: LightPalette.terminalPrompt,
      terminalCommand: LightPalette.terminalCommand,
      terminalOutput: LightPalette.terminalOutput,
      success: LightPalette.success,
      successVariant: LightPalette.successVariant,
      error: LightPalette.error,
      errorVariant: LightPalette.errorVariant,
      warning: LightPalette.warning,
      info: LightPalette.info,
      connected: LightPalette.connected,
      disconnected: LightPalette.disconnected,
      connecting: LightPalette.connecting,
      hover: LightPalette.hover,
      splash: LightPalette.splash,
      highlight: LightPalette.highlight,
      pressed: LightPalette.pressed,
      disabled: LightPalette.disabled,
      border: LightPalette.border,
      divider: LightPalette.divider,
      outline: LightPalette.outline,
      neonPurple: LightPalette.neonPurple,
      neonGreen: LightPalette.neonGreen,
      neonPink: LightPalette.neonPink,
      neonBlue: LightPalette.neonBlue,
      gamingHighlight: LightPalette.gamingHighlight,
      gamingShadow: LightPalette.gamingShadow,
      powerGlow: LightPalette.powerGlow,
      neonTrail: LightPalette.neonTrail,
      energyCore: LightPalette.energyCore,
    );

    _font = AppFont(
      font: const Pretendard(),
      monoFont: const SpaceMono(),
      textColor: _color.onBackground,
      hintColor: _color.onSurfaceVariant,
    );
  }

  @override
  AppColor get color => _color;

  @override
  AppFont get font => _font;

  @override
  AppMode get mode => AppMode.light;

  @override
  ThemeData get themeData => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _color.background,
      );
}

```
## lib/core/theme/provider/theme_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../const/enum_debounce_key.dart';
import '../../const/enum_hive_key.dart';
import '../../util/debounce/debounce_service.dart';
import '../dark_theme.dart';
import '../foundation/app_theme.dart';
import '../light_theme.dart';

part 'theme_provider.g.dart';

@Riverpod(dependencies: [], keepAlive: true)
class Theme extends _$Theme {
  Box<String>? _box;

  @override
  AppTheme build() {
    try {
      final box = Hive.box<String>(HiveKey.boxSettings.key);
      final savedMode = box.get(HiveKey.theme.key);

      if (savedMode != null) {
        final mode = AppMode.fromJson(savedMode);
        return mode == AppMode.light ? LightTheme() : DarkTheme();
      }
    } catch (e) {
      // 에러시 기본값
    }

    return LightTheme();
  }

  /// 테마 변경 (토글)
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> toggleTheme() async {
    final newTheme = state.mode == AppMode.light ? DarkTheme() : LightTheme();

    // 1. UI 즉시 업데이트 (사용자 경험 우선)
    state = newTheme;

    // 2. 저장은 debounce로 처리 (성능 최적화)
    _scheduleThemeSave(newTheme.mode);
  }

  /// 특정 테마로 설정
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> setTheme(AppMode mode) async {
    final newTheme = mode == AppMode.light ? LightTheme() : DarkTheme();

    // 1. UI 즉시 업데이트
    state = newTheme;

    // 2. 저장은 debounce로 처리
    _scheduleThemeSave(mode);
  }

  /// 저장된 테마 불러오기 (앱 시작 시 한 번만 호출)
  Future<void> loadSavedTheme() async {
    _box ??= await _openBox();
    final savedMode = _box!.get(HiveKey.theme.key);

    if (savedMode != null) {
      final mode = AppMode.fromJson(savedMode);
      final newTheme = mode == AppMode.light ? LightTheme() : DarkTheme();

      state = newTheme;
    } else {}
  }

  /// 현재 대기 중인 테마 저장 작업을 즉시 실행
  Future<bool> flushThemeSave() async {
    return await DebounceService.instance
        .executeImmediately(DebounceKey.theme.key);
  }

  /// Provider 정리 시 대기 중인 저장 작업 완료
  Future<void> dispose() async {
    await flushThemeSave();
  }

  /// 테마 저장 작업을 debounce 서비스에 스케줄링
  void _scheduleThemeSave(AppMode mode) {
    DebounceService.instance.schedule(
      key: DebounceKey.theme.key,
      operation: () => _saveThemeMode(mode),
      delay: const Duration(seconds: 5), // 테마는 좀 더 빠르게 저장
    );
  }

  /// 테마 모드 저장 (실제 저장 로직)
  Future<void> _saveThemeMode(AppMode mode) async {
    try {
      _box ??= await _openBox();
      await _box!.put(HiveKey.theme.key, mode.toJson());

      // 🔍 Hive 박스 전체 내용 확인
    } catch (e) {}
  }

  /// Hive 박스 열기
  Future<Box<String>> _openBox() async {
    if (!Hive.isBoxOpen(HiveKey.boxSettings.key)) {
      final box = await Hive.openBox<String>(HiveKey.boxSettings.key);
      return box;
    }

    final box = Hive.box<String>(HiveKey.boxSettings.key);
    return box;
  }
}

extension ThemeProviderExt on WidgetRef {
  AppTheme get theme => watch(themeProvider);
  AppColor get color => theme.color;
  AppFont get font => theme.font;
  ThemeData get themeData => theme.themeData;
}

```
## lib/core/theme/resources/dark_palette.dart
```dart
import 'package:flutter/material.dart';

abstract class DarkPalette {
// Primary colors - Neon/Gaming Theme
  static const Color primary = Color(0xFF8B5CF6); // Violet-500
  static const Color primarySoft =
      Color(0x268B5CF6); // primary.withOpacity(0.15) - 활성 탭 배경
  static const Color primaryVariant = Color(0xFF7C3AED); // Violet-600
  static const Color primaryHover =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color primarySplash =
      Color(0x338B5CF6); // Violet-500 with 20% opacity
  static const Color primaryHighlight =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryVariant = Color(0xFF059669); // Emerald-600

  // Background colors
  static const Color background = Color(0xFF111827); // Gray-900
  static const Color surface = Color(0xFF1F2937); // Gray-800
  static const Color surfaceVariant = Color(0xFF374151); // Gray-700
  static const Color surfaceVariantSoft =
      Color(0x66374151); // surfaceVariant.withOpacity(0.4) - 비활성 탭 배경

  // Terminal specific colors
  static const Color terminalBackground = Color(0xFF000000); // Pure black
  static const Color terminalSurface = Color(0xFF111827); // Gray-900
  static const Color terminalBorder = Color(0xFF374151); // Gray-700

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFF9FAFB); // Gray-50
  static const Color onBackgroundSoft =
      Color(0xB3F9FAFB); // onBackground.withOpacity(0.7) - 부드러운 텍스트
  static const Color onSurface = Color(0xFFF9FAFB); // Gray-50
  static const Color onSurfaceVariant = Color(0xFF9CA3AF); // Gray-400

  // Terminal text colors
  static const Color terminalText = Color(0xFFD1D5DB); // Gray-300
  static const Color terminalPrompt = Color(0xFF10B981); // Emerald-500
  static const Color terminalCommand = Color(0xFF8B5CF6); // Violet-500
  static const Color terminalOutput = Color(0xFFD1D5DB); // Gray-300

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successVariant = Color(0xFF059669); // Emerald-600
  static const Color error = Color(0xFFF87171); // Red-400
  static const Color errorVariant = Color(0xFFEF4444); // Red-500
  static const Color warning = Color(0xFFFBBF24); // Yellow-400
  static const Color info = Color(0xFF8B5CF6); // Violet-500

  // Connection status
  static const Color connected = Color(0xFF10B981); // Emerald-500
  static const Color disconnected = Color(0xFFF87171); // Red-400
  static const Color connecting = Color(0xFFFBBF24); // Yellow-400

  // Interactive colors
  static const Color hover = Color(0x0DFFFFFF); // White 5% opacity
  static const Color splash = Color(0x1AFFFFFF); // White 10% opacity
  static const Color highlight = Color(0x14FFFFFF); // White 8% opacity
  static const Color pressed = Color(0xFF4B5563); // Gray-600
  static const Color disabled = Color(0xFF6B7280); // Gray-500
  static const Color border = Color(0xFF4B5563); // Gray-600

  // Divider and outline
  static const Color divider = Color(0xFF374151); // Gray-700
  static const Color outline = Color(0xFF4B5563); // Gray-600

  // Accent colors for neon effects - Dark Mode optimized
  static const Color neonPurple =
      Color(0xFFA855F7); // Violet-400 (brighter for dark mode)
  static const Color neonGreen =
      Color(0xFF34D399); // Emerald-400 (brighter for dark mode)
  static const Color neonPink =
      Color(0xFFF472B6); // Pink-400 (brighter for dark mode)
  static const Color neonBlue =
      Color(0xFF60A5FA); // Blue-400 (brighter for dark mode)

  // Gaming-specific colors
  static const Color gamingHighlight = Color(0xFFDDD6FE); // Violet-200
  static const Color gamingShadow = Color(0xFF581C87); // Violet-900
  static const Color powerGlow = Color(0xFF34D399); // Emerald-400
  static const Color neonTrail = Color(0xFFF472B6); // Pink-400 trail effect
  static const Color energyCore =
      Color(0xFFA855F7); // Violet-400 for energy cores
}

// Usage example for Gaming Style SSH Terminal:
// 
// class AppTheme {
//   static ThemeData lightGamingTheme = ThemeData(
//     primaryColor: LightPalette.primary,
//     scaffoldBackgroundColor: LightPalette.background,
//     colorScheme: ColorScheme.light(
//       primary: LightPalette.primary,
//       secondary: LightPalette.secondary,
//       surface: LightPalette.surface,
//       background: LightPalette.background,
//     ),
//   );
//
//   static ThemeData darkGamingTheme = ThemeData(
//     primaryColor: DarkPalette.primary,
//     scaffoldBackgroundColor: DarkPalette.background,
//     colorScheme: ColorScheme.dark(
//       primary: DarkPalette.primary,
//       secondary: DarkPalette.secondary,
//       surface: DarkPalette.surface,
//       background: DarkPalette.background,
//     ),
//   );
// }
//
// Gaming-style connect button:
//
// Widget gamingConnectButton(bool isDarkMode) {
//   final palette = isDarkMode ? DarkPalette : LightPalette;
//   
//   return Container(
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: [
//         BoxShadow(
//           color: palette.primary.withOpacity(0.4),
//           blurRadius: 15,
//           spreadRadius: 0,
//           offset: Offset(0, 4),
//         ),
//       ],
//     ),
//     child: ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: palette.primary,
//         foregroundColor: palette.onPrimary,
//         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       child: Text('Connect', 
//            style: TextStyle(fontWeight: FontWeight.bold)),
//       onPressed: () {
//         // Connect logic
//       },
//     ),
//   );
// }
```
## lib/core/theme/resources/font.dart
```dart
import 'package:flutter/material.dart';

abstract class Font {
  Font({
    required this.name,
    required this.regular,
    required this.medium,
    required this.semiBold,
    required this.bold,
  });

  final String name;
  final FontWeight regular;
  final FontWeight medium;
  final FontWeight semiBold;
  final FontWeight bold;
}

class Pretendard implements Font {
  const Pretendard();

  @override
  final String name = 'Pretendard';

  @override
  final FontWeight regular = FontWeight.w400;

  @override
  final FontWeight medium = FontWeight.w500;

  @override
  final FontWeight semiBold = FontWeight.w600;

  @override
  final FontWeight bold = FontWeight.w700;
}

class SpaceMono implements Font {
  const SpaceMono();

  @override
  final String name = 'Space Mono';

  @override
  final FontWeight regular = FontWeight.w400;

  @override
  final FontWeight medium =
      FontWeight.w400; // Space Mono에는 medium이 없어서 regular 사용

  @override
  final FontWeight semiBold =
      FontWeight.w700; // Space Mono에는 semiBold가 없어서 bold 사용

  @override
  final FontWeight bold = FontWeight.w700;
}

```
## lib/core/theme/resources/light_palette.dart
```dart
import 'package:flutter/material.dart';

abstract class LightPalette {
// Primary colors - Neon/Gaming Theme
  static const Color primary = Color(0xFF8B5CF6); // Violet-500
  static const Color primarySoft =
      Color(0x268B5CF6); // primary.withOpacity(0.15) - 활성 탭 배경
  static const Color primaryVariant = Color(0xFF7C3AED); // Violet-600
  static const Color primaryHover =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color primarySplash =
      Color(0x338B5CF6); // Violet-500 with 20% opacity
  static const Color primaryHighlight =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryVariant = Color(0xFF059669); // Emerald-600

  // Background colors - Gaming Style Light Mode
  static const Color background = Color(0xFFF8FAFC); // 약간 보라 틴트
  static const Color surface = Color(0xFFF1F5F9); // 쿨톤 표면
  static const Color surfaceVariant = Color(0xFFE2E8F0); // 더 진한 쿨톤
  static const Color surfaceVariantSoft =
      Color(0x66E2E8F0); // surfaceVariant.withOpacity(0.4) - 비활성 탭 배경

  // Terminal specific colors
  static const Color terminalBackground = Color(0xFF1F2937); // Gray-800
  static const Color terminalSurface = Color(0xFF374151); // Gray-700
  static const Color terminalBorder = Color(0xFF6B7280); // Gray-500

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF111827); // Gray-900
  static const Color onBackgroundSoft =
      Color(0xB3111827); // onBackground.withOpacity(0.7) - 부드러운 텍스트
  static const Color onSurface = Color(0xFF111827); // Gray-900
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Gray-500

  // Terminal text colors
  static const Color terminalText = Color(0xFFD1D5DB); // Gray-300
  static const Color terminalPrompt = Color(0xFF10B981); // Emerald-500
  static const Color terminalCommand = Color(0xFF8B5CF6); // Violet-500
  static const Color terminalOutput = Color(0xFFD1D5DB); // Gray-300

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successVariant = Color(0xFF059669); // Emerald-600
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color errorVariant = Color(0xFFDC2626); // Red-600
  static const Color warning = Color(0xFFF59E0B); // Yellow-500
  static const Color info = Color(0xFF8B5CF6); // Violet-500

  // Connection status
  static const Color connected = Color(0xFF10B981); // Emerald-500
  static const Color disconnected = Color(0xFFEF4444); // Red-500
  static const Color connecting = Color(0xFFF59E0B); // Yellow-500

  // Interactive colors - Gaming Style
  static const Color hover = Color(0x0D000000); // Black 5% opacity
  static const Color splash = Color(0x1A000000); // Black 10% opacity
  static const Color highlight = Color(0x14000000); // Black 8% opacity
  static const Color pressed = Color(0xFFCBD5E1); // 쿨톤 pressed
  static const Color disabled = Color(0xFF94A3B8); // 슬레이트 400
  static const Color border = Color(0xFFCBD5E1); // 슬레이트 300

  // Divider and outline - Gaming Style
  static const Color divider = Color(0xFFE2E8F0); // 슬레이트 200
  static const Color outline = Color(0xFFCBD5E1); // 슬레이트 300

  // Gaming-specific accent colors for Light Mode
  static const Color gamingAccent = Color(0xFFE879F9); // 핑크 글로우
  static const Color neonHighlight = Color(0xFFDDD6FE); // 바이올렛 하이라이트
  static const Color energyGlow = Color(0xFF34D399); // 에너지 글로우
  static const Color powerRing = Color(0xFFF0ABFC); // 퓨샤 하이라이트

  // Accent colors for neon effects - Light Mode optimized
  static const Color neonPurple = Color(0xFF8B5CF6); // Violet-500
  static const Color neonGreen = Color(0xFF10B981); // Emerald-500
  static const Color neonPink = Color(0xFFEC4899); // Pink-500
  static const Color neonBlue = Color(0xFF3B82F6); // Blue-500

  // Gaming UI enhancement colors
  static const Color glowShadow =
      Color(0x1A8B5CF6); // 10% opacity violet for shadows
  static const Color energyShadow =
      Color(0x1A10B981); // 10% opacity emerald for shadows

  // Gaming-specific colors
  static const Color gamingHighlight = Color(0xFFDDD6FE); // Violet-200
  static const Color gamingShadow = Color(0xFF581C87); // Violet-900
  static const Color powerGlow = Color(0xFF34D399); // Emerald-400
  static const Color neonTrail = Color(0xFFF472B6); // Pink-400 trail effect
  static const Color energyCore =
      Color(0xFFA855F7); // Violet-400 for energy cores
}

```
## lib/core/ui/app_button.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_tab_move/core/theme/provider/theme_provider.dart';

class AppButton extends ConsumerWidget {
  final bool isDisabled;

  /// size
  final double? width;
  final double? height;
  final double? borderWidth;

  /// spacing
  final EdgeInsets? margin;
  final EdgeInsets? childPadding;

  /// color
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;

  /// radius
  final BorderRadius? borderRadius;

  final VoidCallback? onPressed;
  final Widget child;

  const AppButton({
    super.key,
    this.isDisabled = false,
    this.width,
    this.height,
    this.borderWidth,
    this.margin,
    this.childPadding,
    this.backgroundColor,
    this.borderColor,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
              color: backgroundColor ?? ref.theme.color.background,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              border: borderColor != null
                  ? Border.all(width: borderWidth ?? 0, color: borderColor!)
                  : null),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              hoverColor: hoverColor ?? ref.theme.color.hover,
              splashColor: splashColor ?? ref.theme.color.splash,
              highlightColor: highlightColor ?? ref.theme.color.highlight,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              child: Padding(
                padding: childPadding ?? const EdgeInsets.all(0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```
## lib/core/ui/app_icon_button.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/svg/model/enum_svg_asset.dart';
import '../util/svg/widget/svg_icon.dart';
import 'app_button.dart';

class AppIconButton extends ConsumerWidget {
  final bool isDisabled;

  /// size
  final double? width;
  final double? height;
  final double? borderWidth;

  /// spacing
  final EdgeInsets? margin;
  final EdgeInsets? childPadding;

  /// color
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;

  /// radius
  final BorderRadius? borderRadius;

  final VoidCallback? onPressed;

  /// child
  final SVGAsset icon;
  final Color? iconColor;
  final double? iconSize;

  const AppIconButton({
    super.key,
    this.isDisabled = false,
    this.width,
    this.height,
    this.borderWidth,
    this.margin,
    this.childPadding,
    this.backgroundColor,
    this.borderColor,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.onPressed,
    required this.icon,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      isDisabled: isDisabled,

      /// size
      width: width,
      height: height,
      borderWidth: borderWidth,

      /// spacing
      margin: margin,
      childPadding: childPadding,

      /// color
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      hoverColor: hoverColor,
      splashColor: splashColor,
      highlightColor: highlightColor,

      /// radius
      borderRadius: borderRadius,

      /// onpressed
      onPressed: onPressed,

      child: Center(
        child: SVGIcon(
          asset: icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}

```
## lib/core/ui/title_bar/app_title_bar.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_tab_move/core/theme/provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../util/svg/model/enum_svg_asset.dart';
import '../app_icon_button.dart';
import 'provider/is_window_maximized_provider.dart';

class AppTitleBar extends ConsumerStatefulWidget {
  const AppTitleBar({super.key});

  @override
  ConsumerState<AppTitleBar> createState() => _AppTitleBarState();
}

class _AppTitleBarState extends ConsumerState<AppTitleBar> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // 🚀 초기 윈도우 상태 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isWindowMaximizedProvider.notifier).loadInitialState();
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // ========================================================================
  // WindowListener 메서드들 - Provider에만 상태 업데이트 (setState 없음!)
  // ========================================================================

  @override
  void onWindowMaximize() {
    ref.read(isWindowMaximizedProvider.notifier).setMaximized(true);
    // 🚀 setState() 없음 - 전체 위젯 rebuild 없음!
  }

  @override
  void onWindowUnmaximize() {
    ref.read(isWindowMaximizedProvider.notifier).setMaximized(false);
    // 🚀 setState() 없음 - 전체 위젯 rebuild 없음!
  }

  @override
  Widget build(BuildContext context) {
    // ✅ build는 WindowListener 이벤트와 무관하게 안정적
    return Container(
      height: 50,
      color: ref.color.background,
      child: Row(
        children: [
          // 🎯 드래그 영역 - 윈도우 최대화와 무관하므로 rebuild 안됨
          Expanded(child: DragToMoveArea(child: Container())),

          // 🎯 제어 버튼 영역
          Row(
            children: [
              AppIconButton(
                width: 30,
                height: 30,

                /// icon
                icon: SVGAsset.windowMinimize,
                iconColor: ref.color.onBackground,
                iconSize: 2,
                onPressed: () => windowManager.minimize(),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isMaximized = ref.watch(isWindowMaximizedProvider);
                  return AppIconButton(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 5),

                    /// icon
                    icon: isMaximized
                        ? SVGAsset.windowRestore
                        : SVGAsset.windowMaximize,
                    iconColor: ref.color.onBackground,
                    iconSize: 14,
                    onPressed: () {
                      ref
                          .read(isWindowMaximizedProvider.notifier)
                          .toggleMaximize();
                    },
                  );
                },
              ),
              AppIconButton(
                width: 30,
                height: 30,

                /// icon
                icon: SVGAsset.windowClose,
                iconColor: ref.color.onBackground,
                iconSize: 14,
                onPressed: () => windowManager.close(),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}

```
## lib/core/ui/title_bar/provider/is_window_maximized_provider.dart
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

part 'is_window_maximized_provider.g.dart';

@riverpod
class IsWindowMaximized extends _$IsWindowMaximized {
  @override
  bool build() {
    return false; // 초기값: 비최대화
  }

  /// 윈도우 최대화 상태 업데이트
  void setMaximized(bool isMaximized) {
    state = isMaximized;
  }

  /// 윈도우 최대화 토글
  Future<void> toggleMaximize() async {
    if (state) {
      await windowManager.unmaximize();
      // onWindowUnmaximize()에서 setMaximized(false) 호출됨
    } else {
      await windowManager.maximize();
      // onWindowMaximize()에서 setMaximized(true) 호출됨
    }
  }

  /// 초기 윈도우 상태 로드
  Future<void> loadInitialState() async {
    try {
      final isMaximized = await windowManager.isMaximized();
      state = isMaximized;
    } catch (e) {}
  }
}

```
## lib/core/util/debounce/debounce_operation.dart
```dart
import 'dart:async';

/// Debounce 작업을 나타내는 클래스
class DebounceOperation {
  final String key;
  final Future<void> Function() operation;
  Timer? _timer;
  final Duration delay;

  DebounceOperation({
    required this.key,
    required this.operation,
    this.delay = const Duration(milliseconds: 500),
  });

  /// 타이머를 시작하거나 재시작
  void schedule() {
    _timer?.cancel(); // 기존 타이머가 있으면 취소
    _timer = Timer(delay, () async {
      try {
        await operation();
      } catch (e) {
        // 에러 로깅 (나중에 로깅 서비스로 교체 가능)
        print('Debounce operation failed for key "$key": $e');
      }
    });
  }

  /// 즉시 실행 (debounce 무시하고 바로 실행)
  Future<void> executeImmediately() async {
    _timer?.cancel();
    try {
      await operation();
    } catch (e) {
      print('Immediate execution failed for key "$key": $e');
      rethrow;
    }
  }

  /// 타이머 취소
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 현재 대기 중인지 확인
  bool get isPending => _timer?.isActive ?? false;

  /// 리소스 정리
  void dispose() {
    cancel();
  }
}

```
## lib/core/util/debounce/debounce_service.dart
```dart
import 'dart:async';

import 'debounce_operation.dart';

class DebounceService {
  // 싱글톤 인스턴스
  static final DebounceService _instance = DebounceService._internal();
  static DebounceService get instance => _instance;

  DebounceService._internal();

  // 키별 debounce 작업 관리
  final Map<String, DebounceOperation> _operations = {};

  /// 기본 debounce 지연 시간
  static const Duration _defaultDelay = Duration(milliseconds: 500);

  /// Debounce 작업 등록/스케줄링
  ///
  /// [key] - 작업을 구분하는 고유 키 (예: 'theme_mode', 'locale')
  /// [operation] - 실행할 비동기 작업
  /// [delay] - debounce 지연 시간 (기본: 500ms)
  void schedule({
    required String key,
    required Future<void> Function() operation,
    Duration? delay,
  }) {
    // 기존 작업이 있으면 제거
    _operations[key]?.dispose();

    // 새로운 debounce 작업 등록
    _operations[key] = DebounceOperation(
      key: key,
      operation: operation,
      delay: delay ?? _defaultDelay,
    );

    // 타이머 시작
    _operations[key]!.schedule();
  }

  /// 특정 키의 작업을 즉시 실행
  ///
  /// [key] - 즉시 실행할 작업의 키
  /// 반환값: 성공하면 true, 해당 키의 작업이 없으면 false
  Future<bool> executeImmediately(String key) async {
    final operation = _operations[key];
    if (operation == null) {
      return false;
    }

    try {
      await operation.executeImmediately();
      _operations.remove(key); // 실행 완료 후 제거
      return true;
    } catch (e) {
      // 에러가 발생해도 작업은 제거 (재시도는 상위에서 결정)
      _operations.remove(key);
      rethrow;
    }
  }

  /// 모든 대기 중인 작업을 즉시 실행
  ///
  /// 앱 종료 시나 강제 저장이 필요할 때 사용
  /// 모든 작업이 완료될 때까지 대기
  Future<void> flushAll() async {
    if (_operations.isEmpty) {
      return;
    }

    // 현재 등록된 모든 작업의 키 복사 (실행 중 맵이 변경될 수 있음)
    final keysToFlush = _operations.keys.toList();

    // 모든 작업을 병렬로 실행
    final futures = <Future<void>>[];

    for (final key in keysToFlush) {
      final operation = _operations[key];
      if (operation != null) {
        futures.add(operation.executeImmediately().catchError((error) {
          print('Error flushing operation "$key": $error');
          // 개별 작업 실패가 전체 flush를 중단하지 않도록 함
        }));
      }
    }

    // 모든 작업 완료 대기
    await Future.wait(futures);

    // 실행 완료된 작업들 정리
    for (final key in keysToFlush) {
      _operations.remove(key);
    }
  }

  /// 특정 키의 작업 취소
  ///
  /// [key] - 취소할 작업의 키
  /// 반환값: 취소된 작업이 있으면 true, 없으면 false
  bool cancel(String key) {
    final operation = _operations.remove(key);
    if (operation != null) {
      operation.dispose();
      return true;
    }
    return false;
  }

  /// 모든 작업 취소 (저장하지 않고 단순 취소)
  void cancelAll() {
    for (final operation in _operations.values) {
      operation.dispose();
    }
    _operations.clear();
  }

  /// 현재 대기 중인 작업 수
  int get pendingCount => _operations.length;

  /// 특정 키의 작업이 대기 중인지 확인
  bool isPending(String key) {
    return _operations[key]?.isPending ?? false;
  }

  /// 현재 대기 중인 모든 키 목록
  List<String> get pendingKeys => _operations.keys.toList();

  /// 리소스 정리 (앱 종료 시 호출)
  void dispose() {
    cancelAll();
  }
}

```
## lib/core/util/svg/enum/color_target.dart
```dart
enum ColorTarget {
  auto, // 기존 스타일에 따라 자동 결정
  fill, // fill만 적용
  stroke, // stroke만 적용
  both, // fill과 stroke 둘 다 적용
}

```
## lib/core/util/svg/model/enum_svg_asset.dart
```dart
enum SVGAsset {
  theme("assets/icons/ico_theme.svg"),
  language("assets/icons/ico_language.svg"),
  windowClose('assets/icons/titlebar/ico_window_close.svg'),
  windowMinimize('assets/icons/titlebar/ico_window_minimize.svg'),
  windowMaximize('assets/icons/titlebar/ico_window_maximize.svg'),
  windowRestore('assets/icons/titlebar/ico_window_restore.svg'),
  ;

  final String path;

  const SVGAsset(this.path);
}

```
## lib/core/util/svg/svg_util.dart
```dart
import 'package:flutter/services.dart';

import 'enum/color_target.dart';
import 'model/enum_svg_asset.dart';

class SVGUtil {
  static final SVGUtil _instance = SVGUtil._internal();

  factory SVGUtil() => _instance;

  SVGUtil._internal();

  static final RegExp _svgNPathRegex = RegExp(r'<(svg|path)(\s+[^>]*?)?/?>');
  static final RegExp _widthRegex = RegExp(r'\swidth="[^"]*"');
  static final RegExp _heightRegex = RegExp(r'\sheight="[^"]*"');

  static final RegExp _fillRegex = RegExp(r'fill="(?!none")[^"]*"');
  static final RegExp _strokeRegex = RegExp(r'stroke="[^"]*"');

  static final RegExp _fillCustomRegex =
      RegExp(r'fill="(?!(none|white))"[^"]*"');
  static final RegExp _strokeCustomRegex =
      RegExp(r'stroke="(?!(none|white))"[^"]*"');

  final Map<SVGAsset, Map<String, String>> _processedSVGCache = {};

  Future<String> getSVG({
    required SVGAsset asset,
    Color? svgColor,
    double? svgSize,
    bool isCustom = false,
    ColorTarget colorTarget = ColorTarget.auto,
  }) async {
    try {
      // 1. 캐시 키 생성
      final cacheKey =
          _generateCacheKey(color: svgColor, size: svgSize, isCustom: isCustom);

      // 2. 캐시된 결과 확인
      if (_processedSVGCache[asset]?[cacheKey] != null) {
        return _processedSVGCache[asset]![cacheKey]!;
      }

      // 3. 원본 SVG 로드
      String svgString = await rootBundle.loadString(asset.path);

      // 4. 크기 적용
      if (svgSize != null) {
        svgString = _applySize(svgString);
      }

      // 5. 색상 적용
      if (svgColor != null) {
        svgString = _applyColor(
          svgString: svgString,
          color: svgColor,
          isCustom: isCustom,
          target: colorTarget,
        );
      }

      // 6. 결과 캐싱
      _processedSVGCache[asset] ??= {};
      _processedSVGCache[asset]![cacheKey] = svgString;

      return svgString;
    } catch (error, stackTrace) {
      return "";
    }
  }

  /// SVG에서 width, height 속성을 제거합니다
  String _applySize(String svgString) {
    return svgString.replaceAll(_widthRegex, '').replaceAll(_heightRegex, '');
  }

  /// SVG에 색상을 적용합니다
  String _applyColor({
    required String svgString,
    required Color color,
    bool isCustom = false,
    ColorTarget target = ColorTarget.auto,
  }) {
    final colorHex = _colorToHex(color);

    return svgString.replaceAllMapped(
      _svgNPathRegex,
      (match) {
        String tag = match.group(0)!;

        switch (target) {
          case ColorTarget.fill:
            tag = _applyFillOnly(tag, colorHex, isCustom);
            break;

          case ColorTarget.stroke:
            tag = _applyStrokeOnly(tag, colorHex, isCustom);
            break;

          case ColorTarget.both:
            tag = _applyBoth(tag, colorHex, isCustom);
            break;

          case ColorTarget.auto:
            tag = _applyAuto(tag, colorHex, isCustom);
            break;
        }

        return tag;
      },
    );
  }

// 각각의 적용 메서드들
  String _applyAuto(String tag, String colorHex, bool isCustom) {
    bool hasFill =
        isCustom ? _fillCustomRegex.hasMatch(tag) : _fillRegex.hasMatch(tag);
    bool hasStroke = isCustom
        ? _strokeCustomRegex.hasMatch(tag)
        : _strokeRegex.hasMatch(tag);

    if (hasFill) {
      // 기존 fill이 있으면 fill 변경
      return _applyFillOnly(tag, colorHex, isCustom);
    } else if (hasStroke) {
      // fill이 없고 stroke가 있으면 stroke 변경
      return _applyStrokeOnly(tag, colorHex, isCustom);
    } else {
      // 둘 다 없으면 fill 추가 (기본값)
      return _applyFillOnly(tag, colorHex, isCustom);
    }
  }

  String _applyFillOnly(String tag, String colorHex, bool isCustom) {
    if (isCustom) {
      if (_fillCustomRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(
            _fillCustomRegex, (match) => 'fill="$colorHex"');
      } else if (!tag.contains('fill=')) {
        return _addAttribute(tag, 'fill', colorHex);
      }
    } else {
      if (_fillRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(_fillRegex, (match) => 'fill="$colorHex"');
      } else if (!tag.contains('fill=')) {
        return _addAttribute(tag, 'fill', colorHex);
      }
    }
    return tag;
  }

  String _applyStrokeOnly(String tag, String colorHex, bool isCustom) {
    if (isCustom) {
      if (_strokeCustomRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(
            _strokeCustomRegex, (match) => 'stroke="$colorHex"');
      } else if (!tag.contains('stroke=')) {
        return _addAttribute(tag, 'stroke', colorHex);
      }
    } else {
      if (_strokeRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(
            _strokeRegex, (match) => 'stroke="$colorHex"');
      } else if (!tag.contains('stroke=')) {
        return _addAttribute(tag, 'stroke', colorHex);
      }
    }
    return tag;
  }

  String _applyBoth(String tag, String colorHex, bool isCustom) {
    // fill 먼저 적용
    tag = _applyFillOnly(tag, colorHex, isCustom);
    // stroke 적용
    tag = _applyStrokeOnly(tag, colorHex, isCustom);
    return tag;
  }

  /// 태그에 속성을 추가하는 헬퍼 메서드
  String _addAttribute(String tag, String attribute, String value) {
    if (tag.endsWith('/>')) {
      return tag.replaceFirst('/>', ' $attribute="$value"/>');
    } else if (tag.endsWith('>')) {
      return tag.replaceFirst('>', ' $attribute="$value">');
    }
    return tag;
  }

  /// Color 객체를 Hex 문자열로 변환합니다
  String _colorToHex(Color color) {
    final int r = (color.r * 255).toInt();
    final int g = (color.g * 255).toInt();
    final int b = (color.b * 255).toInt();
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// 캐시 키를 생성합니다
  String _generateCacheKey({
    Color? color,
    double? size,
    bool isCustom = false,
  }) {
    String colorPart = 'null';
    if (color != null) {
      colorPart = '${color.a}_${color.r}_${color.g}_${color.b}';
    }

    final sizePart = size?.toString() ?? 'null';
    final customPart = isCustom.toString();

    return '$colorPart..$sizePart..$customPart';
  }

  void clearCache() {
    _processedSVGCache.clear();
  }
}

```
## lib/core/util/svg/widget/svg_icon.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/enum_svg_asset.dart';
import '../svg_util.dart';

class SVGIcon extends StatelessWidget {
  final SVGAsset asset;
  final Color? color;
  final double? size;
  final bool isCustom;

  const SVGIcon({
    super.key,
    required this.asset,
    this.color,
    this.size,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SVGUtil().getSVG(
          asset: asset, svgColor: color, svgSize: size, isCustom: isCustom),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return SvgPicture.string(
          snapshot.data!,
          width: size,
          height: size,
        );
      },
    );
  }
}

```
## lib/features/split_workspace/extension/drop_zone_type_extension.dart
```dart
import 'package:flutter/material.dart';

import '../models/split_panel_model.dart';

/// 드롭 존 타입별 색상 반환
extension DropZoneTypeExtension on DropZoneType {
  /// 각 드롭 존의 기본 색상
  Color get baseColor {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitRight:
      case DropZoneType.splitTop:
      case DropZoneType.splitBottom:
        return Colors.blue; // 분할 구역은 파란색
      case DropZoneType.moveToGroup:
        return Colors.green; // 중앙은 초록색
    }
  }

  /// 호버 시 강조 색상
  Color get hoverColor {
    return baseColor.withOpacity(0.4);
  }

  /// 기본 색상 (비호버)
  Color get normalColor {
    return baseColor.withOpacity(0.2);
  }

  /// 드롭 존 설명 텍스트
  String get description {
    switch (this) {
      case DropZoneType.splitLeft:
        return '좌측 분할';
      case DropZoneType.splitRight:
        return '우측 분할';
      case DropZoneType.splitTop:
        return '상단 분할';
      case DropZoneType.splitBottom:
        return '하단 분할';
      case DropZoneType.moveToGroup:
        return '탭 이동';
    }
  }

  /// 분할 방향 반환 (분할 존만)
  SplitDirection? get splitDirection {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitRight:
        return SplitDirection.vertical;
      case DropZoneType.splitTop:
      case DropZoneType.splitBottom:
        return SplitDirection.horizontal;
      case DropZoneType.moveToGroup:
        return null; // 분할이 아님
    }
  }

  /// 분할 시 새 그룹이 첫 번째인지 여부
  bool get isNewGroupFirst {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitTop:
        return true; // 새 그룹이 앞쪽
      case DropZoneType.splitRight:
      case DropZoneType.splitBottom:
        return false; // 새 그룹이 뒤쪽
      case DropZoneType.moveToGroup:
        return false; // 분할이 아님
    }
  }
}

```
## lib/features/split_workspace/models/split_panel_model.dart
```dart
import '../../../features/tab_system/models/tab_model.dart';

/// 분할 방향
enum SplitDirection {
  horizontal, // 수평 분할 (상하)
  vertical // 수직 분할 (좌우)
}

/// 드롭 존 타입
enum DropZoneType {
  splitLeft, // 좌측 수직분할
  splitRight, // 우측 수직분할
  splitTop, // 상단 수평분할
  splitBottom, // 하단 수평분할
  moveToGroup, // 중앙 탭이동
}

/// 분할 패널 모델
class SplitPanel {
  final String id;
  final SplitDirection? direction; // null = 단일 그룹 (리프 노드)
  final List<SplitPanel>? children; // 분할 시 하위 패널들
  final List<TabModel>? tabs; // 단일 그룹의 탭들 (리프 노드만)
  final String? activeTabId; // 활성 탭 ID (리프 노드만)
  final double ratio; // 분할 비율 (0.0 ~ 1.0)

  const SplitPanel({
    required this.id,
    this.direction,
    this.children,
    this.tabs,
    this.activeTabId,
    this.ratio = 0.5, // 기본 50:50
  });

  /// 단일 탭 그룹 생성자 (리프 노드)
  SplitPanel.singleGroup({
    required this.id,
    required List<TabModel> tabs,
    this.activeTabId,
  })  : direction = null,
        children = null,
        tabs = tabs,
        ratio = 0.5;

  /// 분할 패널 생성자 (브랜치 노드)
  SplitPanel.split({
    required this.id,
    required this.direction,
    required List<SplitPanel> children,
    this.ratio = 0.5,
  })  : children = children,
        tabs = null,
        activeTabId = null;

  /// 리프 노드인지 확인 (탭 그룹)
  bool get isLeaf => tabs != null;

  /// 브랜치 노드인지 확인 (분할 컨테이너)
  bool get isSplit => children != null;

  /// 활성 탭 반환
  TabModel? get activeTab {
    if (!isLeaf || tabs == null) return null;
    if (activeTabId == null) return null;

    try {
      return tabs!.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      return null;
    }
  }

  /// 탭 수 반환 (리프 노드만)
  int get tabCount => isLeaf ? (tabs?.length ?? 0) : 0;

  /// 패널 복사
  SplitPanel copyWith({
    String? id,
    SplitDirection? direction,
    List<SplitPanel>? children,
    List<TabModel>? tabs,
    String? activeTabId,
    double? ratio,
  }) {
    return SplitPanel(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      children: children ?? this.children,
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
      ratio: ratio ?? this.ratio,
    );
  }

  /// 탭 추가 (리프 노드만) - 기존 메서드 (맨 뒤에 추가)
  SplitPanel addTab(TabModel tab, {bool makeActive = false}) {
    if (!isLeaf) return this;

    final List<TabModel> updatedTabs = [...(tabs ?? []), tab];
    final newActiveTabId = makeActive ? tab.id : activeTabId;

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// 🆕 특정 위치에 탭 삽입 (리프 노드만)
  SplitPanel insertTabAt(TabModel tab, int index, {bool makeActive = false}) {
    if (!isLeaf) return this;

    final List<TabModel> updatedTabs = List<TabModel>.from(tabs ?? []);
    final clampedIndex = index.clamp(0, updatedTabs.length);
    updatedTabs.insert(clampedIndex, tab);

    final newActiveTabId = makeActive ? tab.id : activeTabId;

    print(
        '🔧 insertTabAt: ${tab.title} → 위치 $clampedIndex/${updatedTabs.length}');

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// 탭 제거 (리프 노드만)
  SplitPanel removeTab(String tabId) {
    if (!isLeaf || tabs == null) return this;

    final updatedTabs = tabs!.where((tab) => tab.id != tabId).toList();

    // 삭제된 탭이 활성 탭이었다면 다른 탭을 활성화
    String? newActiveTabId = activeTabId;
    if (activeTabId == tabId && updatedTabs.isNotEmpty) {
      // 같은 위치의 탭을 활성화 (마지막이면 이전 탭)
      final deletedIndex = tabs!.indexWhere((tab) => tab.id == tabId);
      final newActiveIndex = deletedIndex >= updatedTabs.length
          ? updatedTabs.length - 1
          : deletedIndex;
      newActiveTabId = updatedTabs[newActiveIndex].id;
    } else if (updatedTabs.isEmpty) {
      newActiveTabId = null;
    }

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// 탭 활성화 (리프 노드만)
  SplitPanel activateTab(String tabId) {
    if (!isLeaf || tabs == null) return this;

    final hasTab = tabs!.any((tab) => tab.id == tabId);
    if (!hasTab) return this;

    return copyWith(activeTabId: tabId);
  }

  /// 탭 순서 변경 (리프 노드만)
  SplitPanel reorderTab(String tabId, int newIndex) {
    if (!isLeaf || tabs == null) return this;

    final updatedTabs = List<TabModel>.from(tabs!);
    final tabIndex = updatedTabs.indexWhere((tab) => tab.id == tabId);

    if (tabIndex == -1) return this;

    // 탭 제거 후 새 위치에 삽입
    final tab = updatedTabs.removeAt(tabIndex);
    final clampedIndex = newIndex.clamp(0, updatedTabs.length);
    updatedTabs.insert(clampedIndex, tab);

    return copyWith(tabs: updatedTabs);
  }

  /// 디버그용 문자열 출력
  @override
  String toString() {
    if (isLeaf) {
      return 'SplitPanel.leaf(id: $id, tabs: ${tabs?.length ?? 0}, active: $activeTabId)';
    } else {
      return 'SplitPanel.split(id: $id, direction: $direction, children: ${children?.length ?? 0})';
    }
  }

  /// 트리 구조 출력 (디버그용)
  String toTreeString([int indent = 0]) {
    final prefix = '  ' * indent;

    if (isLeaf) {
      final tabTitles = tabs?.map((t) => t.title).join(', ') ?? '';
      return '$prefix└─ Group($id): [$tabTitles] active:$activeTabId';
    } else {
      final lines = <String>[];
      lines.add('$prefix├─ Split($id): ${direction?.name ?? 'unknown'}');

      if (children != null) {
        for (int i = 0; i < children!.length; i++) {
          lines.add(children![i].toTreeString(indent + 1));
        }
      }

      return lines.join('\n');
    }
  }
}

```
## lib/features/split_workspace/providers/drop_zone_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/split_panel_model.dart';

part 'drop_zone_provider.g.dart';

/// 드롭 존 상태 모델
class DropZoneState {
  final bool isVisible; // 드롭 존이 표시되는가?
  final DropZoneType? hoveredZone; // 현재 호버 중인 존
  final Size contentSize; // 콘텐츠 영역 크기
  final Map<DropZoneType, Rect> zones; // 각 존의 영역

  const DropZoneState({
    this.isVisible = false,
    this.hoveredZone,
    this.contentSize = Size.zero,
    this.zones = const {},
  });

  DropZoneState copyWith({
    bool? isVisible,
    DropZoneType? hoveredZone,
    Size? contentSize,
    Map<DropZoneType, Rect>? zones,
  }) {
    return DropZoneState(
      isVisible: isVisible ?? this.isVisible,
      hoveredZone: hoveredZone ?? this.hoveredZone,
      contentSize: contentSize ?? this.contentSize,
      zones: zones ?? this.zones,
    );
  }

  /// 호버 존 초기화
  DropZoneState clearHover() {
    return copyWith(hoveredZone: null);
  }
}

@riverpod
class DropZone extends _$DropZone {
  @override
  DropZoneState build() {
    return const DropZoneState();
  }

  /// 드롭 존 표시 시작 (드래그 시작 시 호출)
  void showDropZones(Size contentSize) {
    final zones = _calculateDropZones(contentSize);

    state = state.copyWith(
      isVisible: true,
      contentSize: contentSize,
      zones: zones,
      hoveredZone: null, // 호버 초기화
    );
  }

  /// 드롭 존 숨기기 (드래그 종료 시 호출)
  void hideDropZones() {
    state = state.copyWith(
      isVisible: false,
      hoveredZone: null,
      zones: {},
    );
  }

  /// 마우스 위치에 따른 호버 존 업데이트
  void updateHoverZone(Offset localPosition) {
    if (!state.isVisible) return;

    DropZoneType? newHoveredZone;

    // 각 존을 확인하여 마우스가 어느 존에 있는지 판단
    for (final entry in state.zones.entries) {
      if (entry.value.contains(localPosition)) {
        newHoveredZone = entry.key;
        break;
      }
    }

    // 호버 존이 변경된 경우에만 상태 업데이트
    if (newHoveredZone != state.hoveredZone) {
      state = state.copyWith(hoveredZone: newHoveredZone);
    }
  }

  /// 호버 존 초기화
  void clearHover() {
    if (state.hoveredZone != null) {
      state = state.clearHover();
    }
  }

  /// 현재 호버 중인 존의 액션 타입 반환
  DropZoneType? getHoveredZone() {
    return state.hoveredZone;
  }

  /// 특정 위치에서 드롭 존 타입 반환
  DropZoneType? getDropZoneAt(Offset localPosition) {
    for (final entry in state.zones.entries) {
      if (entry.value.contains(localPosition)) {
        return entry.key;
      }
    }
    return null;
  }

  /// 5개 드롭 존 영역 계산
  Map<DropZoneType, Rect> _calculateDropZones(Size size) {
    final width = size.width;
    final height = size.height;

    // 33% 기준으로 5구역 계산
    return {
      // 좌측 33% (수직 분할 - 왼쪽)
      DropZoneType.splitLeft: Rect.fromLTWH(0, 0, width * 0.33, height),

      // 우측 33% (수직 분할 - 오른쪽)
      DropZoneType.splitRight:
          Rect.fromLTWH(width * 0.67, 0, width * 0.33, height),

      // 상단 33% (수평 분할 - 위쪽)
      DropZoneType.splitTop:
          Rect.fromLTWH(width * 0.33, 0, width * 0.34, height * 0.33),

      // 하단 33% (수평 분할 - 아래쪽)
      DropZoneType.splitBottom: Rect.fromLTWH(
          width * 0.33, height * 0.67, width * 0.34, height * 0.33),

      // 중앙 영역 (탭 이동)
      DropZoneType.moveToGroup: Rect.fromLTWH(
          width * 0.33, height * 0.33, width * 0.34, height * 0.34),
    };
  }
}

```
## lib/features/split_workspace/providers/global_drag_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../tab_system/models/tab_model.dart';

part 'global_drag_provider.g.dart';

/// 전역 드래그 정보 모델 (최적화됨)
class GlobalDragInfo {
  final bool isDragging;
  final TabModel? draggedTab;
  final String? sourceGroupId;
  final Offset? globalPosition;

  const GlobalDragInfo({
    this.isDragging = false,
    this.draggedTab,
    this.sourceGroupId,
    this.globalPosition,
  });

  GlobalDragInfo copyWith({
    bool? isDragging,
    TabModel? draggedTab,
    String? sourceGroupId,
    Offset? globalPosition,
  }) {
    return GlobalDragInfo(
      isDragging: isDragging ?? this.isDragging,
      draggedTab: draggedTab ?? this.draggedTab,
      sourceGroupId: sourceGroupId ?? this.sourceGroupId,
      globalPosition: globalPosition ?? this.globalPosition,
    );
  }

  /// 드래그 정보 초기화
  GlobalDragInfo clear() {
    return const GlobalDragInfo();
  }
}

@riverpod
class GlobalDrag extends _$GlobalDrag {
  @override
  GlobalDragInfo build() {
    return const GlobalDragInfo();
  }

  /// 드래그 시작
  void startDrag(TabModel tab, String sourceGroupId, Offset position) {
    state = state.copyWith(
      isDragging: true,
      draggedTab: tab,
      sourceGroupId: sourceGroupId,
      globalPosition: position,
    );
  }

  /// 전역 드래그 위치 업데이트
  void updateGlobalPosition(Offset position) {
    if (state.isDragging && state.globalPosition != position) {
      state = state.copyWith(globalPosition: position);
    }
  }

  /// 드래그 종료
  void endDrag() {
    state = const GlobalDragInfo();
  }

  /// 드래그 취소 (ESC키 등)
  void cancelDrag() {
    state = const GlobalDragInfo();
  }
}

```
## lib/features/split_workspace/providers/group_drag_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/split_panel_model.dart';
import 'global_drag_provider.dart';

part 'group_drag_provider.g.dart';

/// 🆕 분할 미리보기 영역 정보 모델
class SplitPreviewArea {
  final Rect newGroupArea; // 새로 생성될 그룹 영역
  final Rect existingGroupArea; // 기존 그룹이 차지할 영역
  final SplitDirection direction; // 분할 방향
  final DropZoneType dropZoneType; // 드롭존 타입

  const SplitPreviewArea({
    required this.newGroupArea,
    required this.existingGroupArea,
    required this.direction,
    required this.dropZoneType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitPreviewArea &&
          runtimeType == other.runtimeType &&
          newGroupArea == other.newGroupArea &&
          existingGroupArea == other.existingGroupArea &&
          direction == other.direction &&
          dropZoneType == other.dropZoneType;

  @override
  int get hashCode =>
      newGroupArea.hashCode ^
      existingGroupArea.hashCode ^
      direction.hashCode ^
      dropZoneType.hashCode;
}

/// 🔧 미리보기 기능이 추가된 그룹 드래그 상태 모델
class GroupDragState {
  final String? targetGroupId; // 현재 타겟 그룹 ID
  final bool isHovered;
  final int? insertIndex;
  final double? indicatorX;
  final DropZoneType? dropZone;
  final bool showInsertIndicator;

  // 🆕 미리보기 관련 필드들
  final bool showSplitPreview; // 분할 미리보기 표시 여부
  final SplitPreviewArea? splitPreviewArea; // 분할 영역 정보
  final Size? contentSize; // 콘텐츠 영역 크기 (미리보기 계산용)

  const GroupDragState({
    this.targetGroupId,
    this.isHovered = false,
    this.insertIndex,
    this.indicatorX,
    this.dropZone,
    this.showInsertIndicator = false,
    // 🆕 미리보기 기본값
    this.showSplitPreview = false,
    this.splitPreviewArea,
    this.contentSize,
  });

  GroupDragState copyWith({
    String? targetGroupId,
    bool? isHovered,
    int? insertIndex,
    double? indicatorX,
    DropZoneType? dropZone,
    bool? showInsertIndicator,
    // 🆕 미리보기 관련
    bool? showSplitPreview,
    SplitPreviewArea? splitPreviewArea,
    Size? contentSize,
  }) {
    return GroupDragState(
      targetGroupId: targetGroupId ?? this.targetGroupId,
      isHovered: isHovered ?? this.isHovered,
      insertIndex: insertIndex ?? this.insertIndex,
      indicatorX: indicatorX ?? this.indicatorX,
      dropZone: dropZone ?? this.dropZone,
      showInsertIndicator: showInsertIndicator ?? this.showInsertIndicator,
      // 🆕 미리보기 관련
      showSplitPreview: showSplitPreview ?? this.showSplitPreview,
      splitPreviewArea: splitPreviewArea ?? this.splitPreviewArea,
      contentSize: contentSize ?? this.contentSize,
    );
  }

  /// 모든 상태 초기화
  GroupDragState clear() {
    return const GroupDragState();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupDragState &&
          runtimeType == other.runtimeType &&
          targetGroupId == other.targetGroupId &&
          isHovered == other.isHovered &&
          insertIndex == other.insertIndex &&
          indicatorX == other.indicatorX &&
          dropZone == other.dropZone &&
          showInsertIndicator == other.showInsertIndicator &&
          showSplitPreview == other.showSplitPreview &&
          splitPreviewArea == other.splitPreviewArea &&
          contentSize == other.contentSize;

  @override
  int get hashCode =>
      targetGroupId.hashCode ^
      isHovered.hashCode ^
      insertIndex.hashCode ^
      indicatorX.hashCode ^
      dropZone.hashCode ^
      showInsertIndicator.hashCode ^
      showSplitPreview.hashCode ^
      splitPreviewArea.hashCode ^
      contentSize.hashCode;
}

@Riverpod(dependencies: [GlobalDrag])
class GroupDrag extends _$GroupDrag {
  @override
  GroupDragState build() {
    // GlobalDrag 상태 변화 감지하여 자동 정리
    ref.listen(globalDragProvider, (prev, curr) {
      if (prev?.isDragging == true && !curr.isDragging) {
        // 드래그 종료시 상태 정리
        Future.microtask(() {
          state = const GroupDragState();
        });
      }
    });

    return const GroupDragState();
  }

  // ========================================================================
  // 🔧 기존 메서드들 (변경 없음)
  // ========================================================================

  /// 특정 그룹의 호버 상태 설정
  void setGroupHover(String groupId, bool isHovered) {
    state = state.copyWith(
      targetGroupId: groupId,
      isHovered: isHovered,
    );
  }

  /// 탭바 삽입 위치 설정
  void setInsertPosition(String groupId, int index, double indicatorX) {
    state = state.copyWith(
      targetGroupId: groupId,
      insertIndex: index,
      indicatorX: indicatorX,
      showInsertIndicator: true,
    );
  }

  /// 인서트 위치 초기화
  void clearInsertPosition(String groupId) {
    // 해당 그룹이 타겟이 아니면 무시
    if (state.targetGroupId != groupId) {
      return;
    }

    state = state.copyWith(
      insertIndex: null,
      indicatorX: null,
      showInsertIndicator: false,
    );
  }

  /// 드롭존 설정
  void setDropZone(String groupId, DropZoneType? dropZone) {
    state = state.copyWith(
      targetGroupId: groupId,
      dropZone: dropZone,
    );
  }

  /// 드롭존 초기화
  void clearDropZone(String groupId) {
    // 해당 그룹이 타겟이 아니면 무시
    if (state.targetGroupId != groupId) return;

    state = state.copyWith(dropZone: null);
  }

  /// 모든 상태 초기화
  void clearAllStates() {
    state = const GroupDragState();
  }

  // ========================================================================
  // 🆕 미리보기 관련 메서드들
  // ========================================================================

  /// 분할 미리보기 설정
  void setSplitPreview(
      String groupId, Size contentSize, DropZoneType dropZoneType) {
    // 미리보기 영역 계산
    final previewArea = _calculateSplitPreviewArea(contentSize, dropZoneType);

    state = state.copyWith(
      targetGroupId: groupId,
      dropZone: dropZoneType,
      contentSize: contentSize,
      splitPreviewArea: previewArea,
      showSplitPreview: true,
    );
  }

  /// 분할 미리보기 초기화
  void clearSplitPreview(String groupId) {
    // 해당 그룹이 타겟이 아니면 무시
    if (state.targetGroupId != groupId) return;

    state = state.copyWith(
      showSplitPreview: false,
      splitPreviewArea: null,
      contentSize: null,
    );
  }

  /// 🆕 분할 미리보기 영역 계산
  /// 🆕 분할 미리보기 영역 계산
  SplitPreviewArea _calculateSplitPreviewArea(
      Size contentSize, DropZoneType dropZoneType) {
    final width = contentSize.width;
    final height = contentSize.height;

    switch (dropZoneType) {
      case DropZoneType.splitLeft:
        // 좌측 분할: 새 그룹이 왼쪽 50%, 기존 그룹이 오른쪽 50%
        return SplitPreviewArea(
          newGroupArea: Rect.fromLTWH(0, 0, width * 0.5, height),
          existingGroupArea: Rect.fromLTWH(width * 0.5, 0, width * 0.5, height),
          direction: SplitDirection.vertical,
          dropZoneType: dropZoneType,
        );

      case DropZoneType.splitRight:
        // 우측 분할: 기존 그룹이 왼쪽 50%, 새 그룹이 오른쪽 50%
        return SplitPreviewArea(
          newGroupArea: Rect.fromLTWH(width * 0.5, 0, width * 0.5, height),
          existingGroupArea: Rect.fromLTWH(0, 0, width * 0.5, height),
          direction: SplitDirection.vertical,
          dropZoneType: dropZoneType,
        );

      case DropZoneType.splitTop:
        // 상단 분할: 새 그룹이 위쪽 50%, 기존 그룹이 아래쪽 50%
        return SplitPreviewArea(
          newGroupArea: Rect.fromLTWH(0, 0, width, height * 0.5),
          existingGroupArea:
              Rect.fromLTWH(0, height * 0.5, width, height * 0.5),
          direction: SplitDirection.horizontal,
          dropZoneType: dropZoneType,
        );

      case DropZoneType.splitBottom:
        // 하단 분할: 기존 그룹이 위쪽 50%, 새 그룹이 아래쪽 50%
        return SplitPreviewArea(
          newGroupArea: Rect.fromLTWH(0, height * 0.5, width, height * 0.5),
          existingGroupArea: Rect.fromLTWH(0, 0, width, height * 0.5),
          direction: SplitDirection.horizontal,
          dropZoneType: dropZoneType,
        );

      case DropZoneType.moveToGroup:
        // 🆕 탭 이동: 전체 그룹 영역을 새 그룹으로 표시
        return SplitPreviewArea(
          newGroupArea: Rect.fromLTWH(0, 0, width, height), // 🔧 전체 영역
          existingGroupArea: Rect.fromLTWH(0, 0, width, height), // 동일한 영역
          direction: SplitDirection.horizontal, // 임시값 (사용되지 않음)
          dropZoneType: dropZoneType,
        );
    }
  }

  // ========================================================================
  // 🔧 기존 상태 조회 메서드들 (변경 없음)
  // ========================================================================

  /// 특정 그룹이 호버 중인가?
  bool isGroupHovered(String groupId) {
    return state.targetGroupId == groupId && state.isHovered;
  }

  /// 특정 그룹의 인서트 인덱스
  int? getInsertIndex(String groupId) {
    return state.targetGroupId == groupId ? state.insertIndex : null;
  }

  /// 특정 그룹의 인디케이터 X 위치
  double? getIndicatorX(String groupId) {
    return state.targetGroupId == groupId ? state.indicatorX : null;
  }

  /// 특정 그룹의 드롭존 타입
  DropZoneType? getDropZone(String groupId) {
    return state.targetGroupId == groupId ? state.dropZone : null;
  }

  /// 특정 그룹이 인서트 인디케이터를 표시해야 하는가?
  bool shouldShowInsertIndicator(String groupId) {
    return state.targetGroupId == groupId && state.showInsertIndicator;
  }

  // ========================================================================
  // 🆕 미리보기 상태 조회 메서드들
  // ========================================================================

  /// 특정 그룹이 분할 미리보기를 표시해야 하는가?
  bool shouldShowSplitPreview(String groupId) {
    return state.targetGroupId == groupId &&
        state.showSplitPreview &&
        state.splitPreviewArea != null;
  }

  /// 특정 그룹의 분할 미리보기 영역 정보
  SplitPreviewArea? getSplitPreviewArea(String groupId) {
    return state.targetGroupId == groupId ? state.splitPreviewArea : null;
  }
}

```
## lib/features/split_workspace/providers/split_workspace_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/split_panel_model.dart';
import '../services/split_service.dart'; // 🆕 SplitResult 사용
import '../services/tab_service.dart';

part 'split_workspace_provider.g.dart';

@riverpod
class SplitWorkspace extends _$SplitWorkspace {
  @override
  SplitPanel build() {
    // 초기 상태: 단일 그룹으로 시작
    return SplitPanel.singleGroup(
      id: 'root',
      tabs: [
        TabService.createWelcomeTab(),
      ],
      activeTabId: '1',
    );
  }

  // ========================================================================
  // 🎯 순수 상태 업데이트 메서드들 (비즈니스 로직은 Service에 위임)
  // ========================================================================

  /// 새 탭 추가
  void addTab({String? title, Widget? content}) {
    state = TabService.addTab(state, title: title, content: content);
  }

  /// 특정 그룹에 탭 추가
  void addTabToGroup(String groupId, {String? title, Widget? content}) {
    state = TabService.addTabToGroup(state, groupId,
        title: title, content: content);
  }

  /// 탭 삭제 (빈 그룹 자동 제거 포함)
  void removeTab(String tabId) {
    // 1. 탭 삭제 및 빈 그룹 감지
    final result = TabService.removeTabWithEmptyCheck(state, tabId);

    // 2. 빈 그룹이 생겼으면 제거 처리
    if (result.emptyGroupId != null) {
      final cleanedState = SplitService.removeEmptyGroup(
        result.newState,
        result.emptyGroupId!,
      );

      // 3. 정리 후 루트가 비어졌으면 기본 탭 추가
      if (cleanedState.isLeaf && cleanedState.tabCount == 0) {
        state = TabService.addTab(cleanedState, title: 'Empty Tab');
      } else {
        state = cleanedState;
      }
    } else if (result.rootBecameEmpty) {
      // 4. 루트가 직접 비어진 경우
      state = TabService.addTab(result.newState, title: 'Empty Tab');
    } else {
      // 5. 일반적인 탭 삭제
      state = result.newState;
    }
  }

  /// 탭 활성화
  void activateTab(String tabId) {
    state = TabService.activateTab(state, tabId);
  }

  /// 탭 순서 변경
  void reorderTab(String tabId, int newIndex) {
    state = TabService.reorderTab(state, tabId, newIndex);
  }

  // ========================================================================
  // 🎯 분할 관련 메서드들 (Split Service에 위임) - 🆕 안전한 빈 그룹 정리
  // ========================================================================

  /// 화면 분할 생성 (🆕 안전한 빈 그룹 정리)
  void createSplit({
    required String sourceTabId,
    required DropZoneType dropZone,
    String? targetGroupId,
  }) {
    // 1. 🆕 새로운 SplitResult API 사용
    final splitResult = SplitService.createSplitWithResult(
      state,
      sourceTabId: sourceTabId,
      dropZone: dropZone,
      targetGroupId: targetGroupId,
    );

    // 2. 🆕 빈 그룹 정리가 필요한지 확인
    if (splitResult.needsEmptyGroupCleanup &&
        splitResult.emptyGroupId != null) {
      final cleanedState = SplitService.removeEmptyGroup(
        splitResult.newState,
        splitResult.emptyGroupId!,
      );

      // 3. 정리 후 루트가 비어졌으면 기본 탭 추가
      if (cleanedState.isLeaf && cleanedState.tabCount == 0) {
        state = TabService.addTab(cleanedState, title: 'Empty Tab');
      } else {
        state = cleanedState;
      }
    } else {
      // 4. 일반적인 분할 완료
      state = splitResult.newState;
    }
  }

  /// 탭을 다른 그룹으로 이동 (빈 그룹 자동 제거 포함)
  void moveTabToGroup({
    required String tabId,
    required String targetGroupId,
    int? insertIndex,
  }) {
    // 1. 탭 이동 및 빈 그룹 감지
    final result = SplitService.moveTabToGroupWithEmptyCheck(
      state,
      tabId: tabId,
      targetGroupId: targetGroupId,
      insertIndex: insertIndex,
    );

    // 2. 빈 그룹이 생겼으면 제거 처리
    if (result.emptyGroupId != null) {
      final cleanedState = SplitService.removeEmptyGroup(
        result.newState,
        result.emptyGroupId!,
      );

      // 3. 정리 후 루트가 비어졌으면 기본 탭 추가
      if (cleanedState.isLeaf && cleanedState.tabCount == 0) {
        state = TabService.addTab(cleanedState, title: 'Empty Tab');
      } else {
        state = cleanedState;
      }
    } else {
      // 4. 일반적인 탭 이동
      state = result.newState;
    }
  }

  /// 분할 비율 업데이트
  void updateSplitRatio(String panelId, double newRatio) {
    state = SplitService.updateSplitRatio(state, panelId, newRatio);
  }

  // ========================================================================
  // 🎯 직접 상태 업데이트 (Service에서 호출용)
  // ========================================================================

  /// 상태 직접 업데이트 (Service 레이어에서 사용)
  void updateState(SplitPanel newState) {
    state = newState;
  }
}

```
## lib/features/split_workspace/providers/workspace_computed_providers.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../tab_system/models/tab_model.dart';
import '../services/workspace_helpers.dart';
import 'split_workspace_provider.dart';

part 'workspace_computed_providers.g.dart';

/// 현재 활성 탭 반환
@Riverpod(dependencies: [SplitWorkspace])
TabModel? activeTab(Ref ref) {
  final workspace = ref.watch(splitWorkspaceProvider);

  if (workspace.isLeaf) {
    return workspace.activeTab;
  } else {
    // 분할된 상태에서는 활성 그룹의 활성 탭 반환 (추후 개선)
    return null;
  }
}

/// 현재 표시되는 탭 목록 (레이아웃 계산용)
@Riverpod(dependencies: [SplitWorkspace])
List<TabModel> currentTabs(Ref ref) {
  final workspace = ref.watch(splitWorkspaceProvider);

  if (workspace.isLeaf && workspace.tabs != null) {
    return workspace.tabs!;
  } else {
    // 분할된 상태에서는 빈 리스트 반환 (4단계에서 해결)
    return [];
  }
}

/// 워크스페이스 통계
@Riverpod(dependencies: [SplitWorkspace])
Map<String, dynamic> workspaceStats(Ref ref) {
  final workspace = ref.watch(splitWorkspaceProvider);

  return {
    'totalTabs': WorkspaceHelpers.countTabs(workspace),
    'totalGroups': WorkspaceHelpers.countGroups(workspace),
    'isSplit': workspace.isSplit,
    'rootType': workspace.isLeaf ? 'single' : 'split',
  };
}

```
## lib/features/split_workspace/services/split_service.dart
```dart
import '../../tab_system/models/tab_model.dart';
import '../extension/drop_zone_type_extension.dart';
import '../models/split_panel_model.dart';
import 'workspace_helpers.dart';

/// 🆕 분할 결과 모델 - 빈 그룹 정보 포함
class SplitResult {
  final SplitPanel newState;
  final String? emptyGroupId; // 빈 그룹이 생겼다면 해당 ID
  final bool needsEmptyGroupCleanup; // 빈 그룹 정리가 필요한가?

  const SplitResult({
    required this.newState,
    this.emptyGroupId,
    this.needsEmptyGroupCleanup = false,
  });
}

/// 화면 분할 관련 비즈니스 로직을 담당하는 서비스
class SplitService {
  SplitService._(); // Private constructor

  // 🆕 최대 분할 깊이 제한 (성능 및 UX 고려)
  static const int maxSplitDepth = 4;

  // ========================================================================
  // 🎯 화면 분할 생성 (중첩 분할 지원) - 🆕 SplitResult 반환
  // ========================================================================

  /// 화면 분할 생성 (중첩 분할 지원) - 🆕 빈 그룹 정보 포함 반환
  static SplitResult createSplitWithResult(
    SplitPanel state, {
    required String sourceTabId,
    required DropZoneType dropZone,
    String? targetGroupId,
  }) {
    // 1. 중앙 존은 분할이 아닌 이동
    if (dropZone == DropZoneType.moveToGroup) {
      return SplitResult(newState: state);
    }

    // 2. targetGroupId가 있으면 특정 그룹 분할, 없으면 루트 분할
    if (targetGroupId != null) {
      return _splitSpecificGroupWithResult(
          state, sourceTabId, dropZone, targetGroupId);
    } else {
      final splitPanel = _splitRootGroup(state, sourceTabId, dropZone);
      return SplitResult(newState: splitPanel);
    }
  }

  /// 🔧 기존 API 호환성 유지
  static SplitPanel createSplit(
    SplitPanel state, {
    required String sourceTabId,
    required DropZoneType dropZone,
    String? targetGroupId,
  }) {
    final result = createSplitWithResult(
      state,
      sourceTabId: sourceTabId,
      dropZone: dropZone,
      targetGroupId: targetGroupId,
    );
    return result.newState;
  }

  /// 🆕 특정 그룹 분할 (중첩 분할, 외부 탭 지원) - 빈 그룹 정보 반환
  static SplitResult _splitSpecificGroupWithResult(
    SplitPanel state,
    String sourceTabId,
    DropZoneType dropZone,
    String targetGroupId,
  ) {
    // 1. 타겟 그룹 찾기
    final targetGroup = WorkspaceHelpers.findGroupById(state, targetGroupId);
    if (targetGroup == null) {
      return SplitResult(newState: state);
    }

    // 2. 소스 탭 정보 가져오기
    TabModel? sourceTab;
    String? sourceGroupId;

    // 🔧 소스 탭이 타겟 그룹에 있는지 확인
    if (targetGroup.tabs != null &&
        targetGroup.tabs!.any((tab) => tab.id == sourceTabId)) {
      // 케이스 1: 같은 그룹 내 분할
      sourceTab = targetGroup.tabs!.firstWhere((tab) => tab.id == sourceTabId);
      sourceGroupId = targetGroupId;
    } else {
      // 케이스 2: 외부 그룹에서 온 탭
      final sourceGroup =
          WorkspaceHelpers.findTabOwnerGroup(state, sourceTabId);
      if (sourceGroup == null) {
        return SplitResult(newState: state);
      }

      sourceTab = sourceGroup.tabs!.firstWhere((tab) => tab.id == sourceTabId);
      sourceGroupId = sourceGroup.id;
    }

    // 3. 분할 가능 여부 검사
    if (!_validateGroupForSplit(targetGroup, sourceTabId)) {
      return SplitResult(newState: state);
    }

    // 4. 현재 깊이 체크
    final currentDepth = WorkspaceHelpers.calculateMaxDepth(state);
    if (currentDepth >= maxSplitDepth) {
      return SplitResult(newState: state);
    }

    // 5. 분할 실행
    final splitResult = _performGroupSplit(targetGroup, sourceTab, dropZone);
    if (splitResult == null) {
      return SplitResult(newState: state);
    }

    // 6. 트리에서 타겟 그룹을 분할 결과로 교체
    var newState = WorkspaceHelpers.updatePanel(
      state,
      targetGroupId,
      splitResult,
    );

    // 7. 🆕 외부 탭인 경우 원래 그룹에서 제거 - 빈 그룹 정보 포함
    if (sourceGroupId != targetGroupId) {
      final sourceGroup =
          WorkspaceHelpers.findGroupById(newState, sourceGroupId);
      if (sourceGroup != null && sourceGroup.isLeaf) {
        final updatedSourceGroup = sourceGroup.removeTab(sourceTabId);
        newState = WorkspaceHelpers.updatePanel(
          newState,
          sourceGroupId,
          updatedSourceGroup,
        );

        // 8. 🆕 빈 그룹이 되었는지 확인하고 정보 반환
        if (updatedSourceGroup.tabCount == 0) {
          return SplitResult(
            newState: newState,
            emptyGroupId: sourceGroupId,
            needsEmptyGroupCleanup: true,
          );
        }
      }
    }

    return SplitResult(newState: newState);
  }

  /// 기존 루트 그룹 분할
  static SplitPanel _splitRootGroup(
    SplitPanel state,
    String sourceTabId,
    DropZoneType dropZone,
  ) {
    // 기존 검증 로직
    if (!state.isLeaf || state.tabs == null || state.tabs!.length <= 1) {
      return state;
    }

    // 기존 분할 로직
    TabModel? sourceTab;
    try {
      sourceTab = state.tabs!.firstWhere((tab) => tab.id == sourceTabId);
    } catch (e) {
      return state;
    }

    final splitResult = _performGroupSplit(state, sourceTab, dropZone);
    if (splitResult == null) {
      return state;
    }

    return splitResult;
  }

  /// 🆕 그룹 분할 가능 여부 검증 (외부 탭 지원)
  static bool _validateGroupForSplit(SplitPanel group, String sourceTabId) {
    // 1. 리프 노드(탭 그룹)인지 확인
    if (!group.isLeaf) {
      return false;
    }

    // 2. 🔧 외부 탭으로 분할하는 경우 빈 그룹도 허용
    if (group.tabs == null) {
      return false;
    }

    // 3. 🔧 외부 탭인지 확인
    final hasSourceTab = group.tabs!.any((tab) => tab.id == sourceTabId);

    if (hasSourceTab) {
      // 케이스 1: 같은 그룹 내 분할 - 최소 2개 탭 필요
      if (group.tabs!.length <= 1) {
        return false;
      }
    } else {
      // 케이스 2: 외부 탭으로 분할 - 빈 그룹도 가능!
    }

    return true;
  }

  /// 🆕 실제 그룹 분할 수행 (외부 탭 지원)
  static SplitPanel? _performGroupSplit(
    SplitPanel targetGroup,
    TabModel sourceTab,
    DropZoneType dropZone,
  ) {
    // 🔧 외부 탭인지 확인
    final isExternalTab =
        !targetGroup.tabs!.any((tab) => tab.id == sourceTab.id);

    List<TabModel> remainingTabs;
    String? newActiveTabId;

    if (isExternalTab) {
      // 케이스 2: 외부 탭으로 분할
      remainingTabs = List.from(targetGroup.tabs!); // 기존 탭들 그대로 유지
      newActiveTabId = targetGroup.activeTabId; // 기존 활성 탭 유지
    } else {
      // 케이스 1: 같은 그룹 내 분할
      remainingTabs =
          targetGroup.tabs!.where((tab) => tab.id != sourceTab.id).toList();

      if (remainingTabs.isEmpty) {
        return null;
      }

      // 활성 탭 처리
      newActiveTabId = targetGroup.activeTabId != sourceTab.id
          ? targetGroup.activeTabId
          : remainingTabs.first.id;
    }

    // 2. 새 그룹 ID 생성
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final existingGroupId = '${targetGroup.id}_existing_$timestamp';
    final newGroupId = '${targetGroup.id}_new_${timestamp + 1}';

    // 3. 기존 탭들을 가진 그룹 생성
    final existingGroup = SplitPanel.singleGroup(
      id: existingGroupId,
      tabs: remainingTabs,
      activeTabId: remainingTabs.isNotEmpty ? newActiveTabId : null,
    );

    // 4. 새 탭을 가진 그룹 생성
    final newGroup = SplitPanel.singleGroup(
      id: newGroupId,
      tabs: [sourceTab],
      activeTabId: sourceTab.id,
    );

    // 5. 분할 방향 및 순서 결정
    final direction = dropZone.splitDirection!;
    final children = dropZone.isNewGroupFirst
        ? [newGroup, existingGroup]
        : [existingGroup, newGroup];

    // 6. 새로운 분할 패널 생성 (기존 그룹 ID 유지)
    final splitPanel = SplitPanel.split(
      id: targetGroup.id, // 🔧 기존 ID 유지로 트리 구조 보존
      direction: direction,
      children: children,
    );

    return splitPanel;
  }

  // ========================================================================
  // 🎯 탭 이동 (그룹 간) - 기존 로직 유지
  // ========================================================================

  /// 탭을 다른 그룹으로 이동 (insertIndex 활용)
  static ({SplitPanel newState, String? emptyGroupId})
      moveTabToGroupWithEmptyCheck(
    SplitPanel state, {
    required String tabId,
    required String targetGroupId,
    int? insertIndex,
  }) {
    // 기존 로직 그대로 유지...
    // 1. 유효성 검사
    if (state.isLeaf) {
      return (newState: state, emptyGroupId: null);
    }

    final sourceGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
    final targetGroup = WorkspaceHelpers.findGroupById(state, targetGroupId);

    if (sourceGroup == null) {
      return (newState: state, emptyGroupId: null);
    }

    if (targetGroup == null) {
      return (newState: state, emptyGroupId: null);
    }

    if (sourceGroup.id == targetGroupId) {
      // 같은 그룹 내 순서 변경
      if (insertIndex != null) {
        final newState = WorkspaceHelpers.updatePanel(
          state,
          sourceGroup.id,
          sourceGroup.reorderTab(tabId, insertIndex),
        );
        return (newState: newState, emptyGroupId: null);
      }
      return (newState: state, emptyGroupId: null);
    }

    // 2. 이동할 탭 정보 추출
    TabModel movingTab;
    try {
      movingTab = sourceGroup.tabs!.firstWhere((tab) => tab.id == tabId);
    } catch (e) {
      return (newState: state, emptyGroupId: null);
    }

    // 3. 소스 그룹에서 탭 제거
    final updatedSourceGroup = sourceGroup.removeTab(tabId);

    // 4. 타겟 그룹에 탭 추가 (insertIndex 활용)
    final updatedTargetGroup = insertIndex != null
        ? targetGroup.insertTabAt(movingTab, insertIndex, makeActive: true)
        : targetGroup.addTab(movingTab, makeActive: true);

    // 5. 트리 업데이트
    var newState = WorkspaceHelpers.updatePanel(
      state,
      sourceGroup.id,
      updatedSourceGroup,
    );
    newState = WorkspaceHelpers.updatePanel(
      newState,
      targetGroup.id,
      updatedTargetGroup,
    );

    // 6. 빈 그룹 ID 반환 (Provider에서 처리하도록)
    final emptyGroupId =
        updatedSourceGroup.tabCount == 0 ? sourceGroup.id : null;

    return (newState: newState, emptyGroupId: emptyGroupId);
  }

  /// 탭을 다른 그룹으로 이동 (기존 API 호환성 유지 - 자동 빈 그룹 제거)
  static SplitPanel moveTabToGroup(
    SplitPanel state, {
    required String tabId,
    required String targetGroupId,
    int? insertIndex,
  }) {
    final result = moveTabToGroupWithEmptyCheck(
      state,
      tabId: tabId,
      targetGroupId: targetGroupId,
      insertIndex: insertIndex,
    );

    // 빈 그룹이 생겼으면 자동 제거
    if (result.emptyGroupId != null) {
      return removeEmptyGroup(result.newState, result.emptyGroupId!);
    }

    return result.newState;
  }

  // ========================================================================
  // 🎯 빈 그룹 정리 - 기존 로직 유지
  // ========================================================================

  /// 빈 그룹 제거 및 트리 재구성
  static SplitPanel removeEmptyGroup(SplitPanel state, String groupId) {
    // 기존 로직 그대로 유지...
    // 1. 루트 그룹 처리 (호출하는 곳에서 처리하도록 상태만 반환)
    if (groupId == state.id) {
      return state;
    }

    // 2. 유효성 검사
    final emptyGroup = WorkspaceHelpers.findGroupById(state, groupId);
    if (emptyGroup == null || !emptyGroup.isLeaf || emptyGroup.tabCount > 0) {
      return state;
    }

    // 3. 부모 경로 찾기
    final parentPath = WorkspaceHelpers.findParentPath(state, groupId);
    if (parentPath == null) {
      return state;
    }

    // 4. 형제 그룹으로 부모 대체
    final parent = parentPath.panel;
    final siblingGroup =
        parent.children!.firstWhere((child) => child.id != groupId);

    // 5. 조부모가 있으면 조부모에 형제 연결, 없으면 루트 교체
    if (parentPath.grandParent != null) {
      // 조부모의 자식 목록에서 부모를 형제로 교체
      final updatedChildren = parentPath.grandParent!.children!
          .map((child) => child.id == parent.id ? siblingGroup : child)
          .toList();

      final updatedGrandParent =
          parentPath.grandParent!.copyWith(children: updatedChildren);

      final newState = WorkspaceHelpers.updatePanel(
        state,
        parentPath.grandParent!.id,
        updatedGrandParent,
      );

      return newState;
    } else {
      // 부모가 루트였으면 형제를 새 루트로
      final newState = siblingGroup.copyWith(id: state.id);

      return newState;
    }
  }

  // ========================================================================
  // 🎯 분할 비율 업데이트 - 기존 로직 유지
  // ========================================================================

  /// 분할 비율 업데이트
  static SplitPanel updateSplitRatio(
    SplitPanel state,
    String panelId,
    double newRatio,
  ) {
    final targetPanel = WorkspaceHelpers.findGroupById(state, panelId);
    if (targetPanel == null) {
      return state;
    }

    if (!targetPanel.isSplit) {
      return state;
    }

    final updatedPanel = targetPanel.copyWith(ratio: newRatio);
    return WorkspaceHelpers.updatePanel(state, panelId, updatedPanel);
  }
}

```
## lib/features/split_workspace/services/tab_service.dart
```dart
import 'package:flutter/material.dart';

import '../../tab_system/models/tab_model.dart';
import '../models/split_panel_model.dart';
import 'workspace_helpers.dart';

/// 탭 관련 비즈니스 로직을 담당하는 서비스
class TabService {
  TabService._(); // Private constructor

  // ========================================================================
  // 🎯 탭 생성 및 기본 컨텐츠
  // ========================================================================

  /// 환영 탭 생성
  static TabModel createWelcomeTab() {
    return const TabModel(
      id: '1',
      title: 'Welcome',
      isActive: true,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.splitscreen, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Split Workspace Test!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// 기본 탭 컨텐츠 생성
  static Widget createDefaultContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 48),
          SizedBox(height: 16),
          Text('New Tab Content'),
        ],
      ),
    );
  }

  /// 새 탭 모델 생성
  static TabModel createNewTab({String? title, Widget? content}) {
    return TabModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'New Tab',
      isActive: false,
      content: content ?? createDefaultContent(),
    );
  }

  // ========================================================================
  // 🎯 탭 추가 로직
  // ========================================================================

  /// 새 탭 추가
  static SplitPanel addTab(
    SplitPanel state, {
    String? title,
    Widget? content,
  }) {
    final newTab = createNewTab(
      title: title ?? 'New Tab ${_getTotalTabCount(state) + 1}',
      content: content,
    );

    if (state.isLeaf) {
      // 단일 그룹인 경우
      return state.addTab(newTab);
    } else {
      // 분할된 상태인 경우 - 활성 그룹에 추가
      final activeGroup = WorkspaceHelpers.findActiveGroup(state);
      if (activeGroup != null) {
        return WorkspaceHelpers.updatePanel(
          state,
          activeGroup.id,
          activeGroup.addTab(newTab),
        );
      }
      return state;
    }
  }

  /// 특정 그룹에 탭 추가
  static SplitPanel addTabToGroup(
    SplitPanel state,
    String groupId, {
    String? title,
    Widget? content,
  }) {
    final newTab = createNewTab(
      title: title ?? 'New Tab ${_getTotalTabCount(state) + 1}',
      content: content,
    );

    if (state.isLeaf && state.id == groupId) {
      // 단일 그룹이고 해당 그룹인 경우
      return state.addTab(newTab, makeActive: true);
    } else {
      // 분할된 상태 - 특정 그룹 찾아서 추가
      final targetGroup = WorkspaceHelpers.findGroupById(state, groupId);
      if (targetGroup != null && targetGroup.isLeaf) {
        final updatedGroup = targetGroup.addTab(newTab, makeActive: true);
        return WorkspaceHelpers.updatePanel(state, groupId, updatedGroup);
      }
      return state;
    }
  }

  // ========================================================================
  // 🎯 탭 제거 로직
  // ========================================================================

  /// 탭 삭제 (빈 그룹 감지 포함)
  static ({SplitPanel newState, String? emptyGroupId, bool rootBecameEmpty})
      removeTabWithEmptyCheck(SplitPanel state, String tabId) {
    if (state.isLeaf) {
      // 단일 그룹인 경우
      final updatedPanel = state.removeTab(tabId);

      // 탭이 모두 없어지면 루트가 비어짐
      if (updatedPanel.tabCount == 0) {
        return (
          newState: updatedPanel,
          emptyGroupId: null,
          rootBecameEmpty: true,
        );
      } else {
        return (
          newState: updatedPanel,
          emptyGroupId: null,
          rootBecameEmpty: false,
        );
      }
    } else {
      // 분할된 상태인 경우 - 해당 그룹에서 제거
      final ownerGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
      if (ownerGroup != null) {
        final updatedGroup = ownerGroup.removeTab(tabId);

        // 상태 업데이트
        final newState = WorkspaceHelpers.updatePanel(
          state,
          ownerGroup.id,
          updatedGroup,
        );

        // 빈 그룹 ID 반환
        if (updatedGroup.tabCount == 0) {
          return (
            newState: newState,
            emptyGroupId: ownerGroup.id,
            rootBecameEmpty: false,
          );
        }

        return (
          newState: newState,
          emptyGroupId: null,
          rootBecameEmpty: false,
        );
      }
      return (
        newState: state,
        emptyGroupId: null,
        rootBecameEmpty: false,
      );
    }
  }

  /// 탭 삭제 (기존 API 유지 - 내부적으로 새 로직 사용)
  static SplitPanel removeTab(SplitPanel state, String tabId) {
    final result = removeTabWithEmptyCheck(state, tabId);

    // 루트가 비어진 경우에만 여기서 기본 탭 추가
    if (result.rootBecameEmpty) {
      return addTab(result.newState, title: 'Empty Tab');
    }

    return result.newState;
  }

  // ========================================================================
  // 🎯 탭 활성화 및 순서 변경
  // ========================================================================

  /// 탭 활성화
  static SplitPanel activateTab(SplitPanel state, String tabId) {
    if (state.isLeaf) {
      // 단일 그룹인 경우
      return state.activateTab(tabId);
    } else {
      // 분할된 상태인 경우 - 해당 그룹에서 활성화
      final ownerGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
      if (ownerGroup != null) {
        return WorkspaceHelpers.updatePanel(
          state,
          ownerGroup.id,
          ownerGroup.activateTab(tabId),
        );
      }
      return state;
    }
  }

  /// 탭 순서 변경
  static SplitPanel reorderTab(SplitPanel state, String tabId, int newIndex) {
    if (state.isLeaf) {
      // 단일 그룹인 경우
      return state.reorderTab(tabId, newIndex);
    } else {
      // 분할된 상태인 경우 - 해당 그룹에서 순서 변경
      final ownerGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
      if (ownerGroup != null) {
        return WorkspaceHelpers.updatePanel(
          state,
          ownerGroup.id,
          ownerGroup.reorderTab(tabId, newIndex),
        );
      }
      return state;
    }
  }

  // ========================================================================
  // 🔧 Private Helper Methods
  // ========================================================================

  /// 전체 탭 수 계산
  static int _getTotalTabCount(SplitPanel state) {
    return WorkspaceHelpers.countTabs(state);
  }
}

```
## lib/features/split_workspace/services/workspace_helpers.dart
```dart
import '../models/split_panel_model.dart';

/// 부모-자식 경로 정보 클래스
class ParentPath {
  final SplitPanel panel; // 부모 패널
  final SplitPanel? grandParent; // 조부모 패널 (null이면 부모가 루트)

  ParentPath(this.panel, this.grandParent);
}

/// 🆕 상태 검증 결과 클래스
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// 성공 결과
  static const ValidationResult success = ValidationResult(isValid: true);

  /// 오류 결과
  static ValidationResult error(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  /// 경고 포함 결과
  static ValidationResult warning(List<String> warnings) =>
      ValidationResult(isValid: true, warnings: warnings);
}

/// 워크스페이스 관련 헬퍼 유틸리티들
class WorkspaceHelpers {
  WorkspaceHelpers._(); // Private constructor

  // ========================================================================
  // 🔍 검색 및 탐색 메서드들
  // ========================================================================

  /// 그룹 ID로 패널 찾기
  static SplitPanel? findGroupById(SplitPanel panel, String groupId) {
    if (panel.id == groupId) {
      return panel;
    }

    if (panel.children != null) {
      for (final child in panel.children!) {
        final found = findGroupById(child, groupId);
        if (found != null) return found;
      }
    }

    return null;
  }

  /// 특정 탭을 소유한 그룹 찾기
  static SplitPanel? findTabOwnerGroup(SplitPanel panel, String tabId) {
    if (panel.isLeaf && panel.tabs != null) {
      final hasTab = panel.tabs!.any((tab) => tab.id == tabId);
      return hasTab ? panel : null;
    } else if (panel.children != null) {
      for (final child in panel.children!) {
        final ownerGroup = findTabOwnerGroup(child, tabId);
        if (ownerGroup != null) return ownerGroup;
      }
    }
    return null;
  }

  /// 활성 그룹 찾기
  static SplitPanel? findActiveGroup(SplitPanel panel) {
    if (panel.isLeaf) {
      return panel.activeTabId != null ? panel : null;
    } else if (panel.children != null) {
      for (final child in panel.children!) {
        final activeGroup = findActiveGroup(child);
        if (activeGroup != null) return activeGroup;
      }
    }
    return null;
  }

  /// 특정 자식의 부모 경로 찾기
  static ParentPath? findParentPath(
    SplitPanel current,
    String childId, [
    SplitPanel? grandParent,
  ]) {
    // 현재 패널의 직접 자식들 중에서 찾기
    if (current.children != null) {
      for (final child in current.children!) {
        if (child.id == childId) {
          return ParentPath(current, grandParent);
        }
      }

      // 재귀적으로 더 깊이 찾기
      for (final child in current.children!) {
        final found = findParentPath(child, childId, current);
        if (found != null) return found;
      }
    }

    return null;
  }

  // ========================================================================
  // 🔧 패널 트리 업데이트
  // ========================================================================

  /// 패널 트리에서 특정 패널 업데이트
  static SplitPanel updatePanel(
    SplitPanel root,
    String panelId,
    SplitPanel newPanel,
  ) {
    if (root.id == panelId) {
      return newPanel;
    }

    if (root.children != null) {
      final updatedChildren = root.children!.map((child) {
        return updatePanel(child, panelId, newPanel);
      }).toList();

      return root.copyWith(children: updatedChildren);
    }

    return root;
  }

  // ========================================================================
  // 📊 통계 및 계산 메서드들
  // ========================================================================

  /// 재귀적으로 탭 수 계산
  static int countTabs(SplitPanel panel) {
    if (panel.isLeaf) {
      return panel.tabCount;
    } else if (panel.children != null) {
      return panel.children!.fold(0, (sum, child) => sum + countTabs(child));
    }
    return 0;
  }

  /// 재귀적으로 그룹 수 계산
  static int countGroups(SplitPanel panel) {
    if (panel.isLeaf) {
      return 1;
    } else if (panel.children != null) {
      return panel.children!.fold(0, (sum, child) => sum + countGroups(child));
    }
    return 0;
  }

  /// 워크스페이스의 최대 깊이 계산
  static int calculateMaxDepth(SplitPanel panel, [int currentDepth = 0]) {
    if (panel.isLeaf) {
      return currentDepth;
    } else if (panel.children != null) {
      int maxChildDepth = currentDepth;
      for (final child in panel.children!) {
        final childDepth = calculateMaxDepth(child, currentDepth + 1);
        if (childDepth > maxChildDepth) {
          maxChildDepth = childDepth;
        }
      }
      return maxChildDepth;
    }
    return currentDepth;
  }

  // ========================================================================
  // 🔍 유효성 검사 메서드들 - 🆕 강화된 검증
  // ========================================================================

  /// 🆕 포괄적인 워크스페이스 상태 검증
  static ValidationResult validateWorkspaceState(SplitPanel panel) {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. 기본 패널 구조 검증
    final structureResult = _validatePanelStructure(panel, 0);
    errors.addAll(structureResult.errors);
    warnings.addAll(structureResult.warnings);

    // 2. 탭 ID 중복 검증
    final tabIds = <String>[];
    _collectTabIds(panel, tabIds);
    final duplicates = _findDuplicates(tabIds);
    if (duplicates.isNotEmpty) {
      errors.add('중복된 탭 ID 발견: ${duplicates.join(", ")}');
    }

    // 3. 그룹 ID 중복 검증
    final groupIds = <String>[];
    _collectGroupIds(panel, groupIds);
    final groupDuplicates = _findDuplicates(groupIds);
    if (groupDuplicates.isNotEmpty) {
      errors.add('중복된 그룹 ID 발견: ${groupDuplicates.join(", ")}');
    }

    // 4. 활성 탭 유효성 검증
    final activeTabErrors = _validateActiveTabs(panel);
    errors.addAll(activeTabErrors);

    // 5. 빈 그룹 검증
    final emptyGroups = _findEmptyGroups(panel);
    if (emptyGroups.isNotEmpty) {
      warnings.add('빈 그룹 발견: ${emptyGroups.join(", ")}');
    }

    // 6. 깊이 제한 검증
    final maxDepth = calculateMaxDepth(panel);
    if (maxDepth > 4) {
      errors.add('최대 분할 깊이 초과: $maxDepth > 4');
    } else if (maxDepth > 3) {
      warnings.add('분할 깊이가 높습니다: $maxDepth');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 패널 구조가 유효한지 검사 (재귀적)
  static ValidationResult _validatePanelStructure(SplitPanel panel, int depth) {
    final errors = <String>[];
    final warnings = <String>[];

    // 리프 노드 검사
    if (panel.isLeaf) {
      if (panel.tabs == null) {
        errors.add('리프 노드 ${panel.id}의 tabs가 null');
      } else if (panel.tabs!.isEmpty && depth > 0) {
        warnings.add('빈 리프 노드: ${panel.id}');
      }

      if (panel.children != null) {
        errors.add('리프 노드 ${panel.id}에 children이 존재');
      }
      if (panel.direction != null) {
        errors.add('리프 노드 ${panel.id}에 direction이 설정됨');
      }
    }
    // 브랜치 노드 검사
    else if (panel.isSplit) {
      if (panel.children == null || panel.children!.isEmpty) {
        errors.add('분할 노드 ${panel.id}에 children이 없음');
      } else if (panel.children!.length != 2) {
        errors.add(
            '분할 노드 ${panel.id}의 children 수가 2가 아님: ${panel.children!.length}');
      }

      if (panel.direction == null) {
        errors.add('분할 노드 ${panel.id}에 direction이 없음');
      }
      if (panel.tabs != null) {
        errors.add('분할 노드 ${panel.id}에 tabs가 존재');
      }
      if (panel.activeTabId != null) {
        errors.add('분할 노드 ${panel.id}에 activeTabId가 설정됨');
      }

      // 자식 노드들 재귀 검증
      if (panel.children != null) {
        for (final child in panel.children!) {
          final childResult = _validatePanelStructure(child, depth + 1);
          errors.addAll(childResult.errors);
          warnings.addAll(childResult.warnings);
        }
      }
    } else {
      errors.add('패널 ${panel.id}가 리프도 분할도 아님');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 🆕 탭 ID 수집
  static void _collectTabIds(SplitPanel panel, List<String> tabIds) {
    if (panel.isLeaf && panel.tabs != null) {
      for (final tab in panel.tabs!) {
        tabIds.add(tab.id);
      }
    } else if (panel.children != null) {
      for (final child in panel.children!) {
        _collectTabIds(child, tabIds);
      }
    }
  }

  /// 🆕 그룹 ID 수집
  static void _collectGroupIds(SplitPanel panel, List<String> groupIds) {
    groupIds.add(panel.id);
    if (panel.children != null) {
      for (final child in panel.children!) {
        _collectGroupIds(child, groupIds);
      }
    }
  }

  /// 🆕 중복 값 찾기
  static List<String> _findDuplicates(List<String> items) {
    final seen = <String>{};
    final duplicates = <String>{};

    for (final item in items) {
      if (seen.contains(item)) {
        duplicates.add(item);
      } else {
        seen.add(item);
      }
    }

    return duplicates.toList();
  }

  /// 🆕 활성 탭 유효성 검증
  static List<String> _validateActiveTabs(SplitPanel panel) {
    final errors = <String>[];

    if (panel.isLeaf && panel.tabs != null) {
      if (panel.activeTabId != null) {
        final hasActiveTab =
            panel.tabs!.any((tab) => tab.id == panel.activeTabId);
        if (!hasActiveTab) {
          errors.add('그룹 ${panel.id}의 활성 탭 ${panel.activeTabId}이 탭 목록에 없음');
        }
      } else if (panel.tabs!.isNotEmpty) {
        errors.add('그룹 ${panel.id}에 탭이 있지만 활성 탭이 설정되지 않음');
      }
    } else if (panel.children != null) {
      for (final child in panel.children!) {
        errors.addAll(_validateActiveTabs(child));
      }
    }

    return errors;
  }

  /// 🆕 빈 그룹 찾기
  static List<String> _findEmptyGroups(SplitPanel panel) {
    final emptyGroups = <String>[];

    if (panel.isLeaf && (panel.tabs == null || panel.tabs!.isEmpty)) {
      emptyGroups.add(panel.id);
    } else if (panel.children != null) {
      for (final child in panel.children!) {
        emptyGroups.addAll(_findEmptyGroups(child));
      }
    }

    return emptyGroups;
  }

  /// 기존 패널 구조 검사 (단순 버전, 호환성 유지)
  static bool isValidPanelStructure(SplitPanel panel) {
    final result = validateWorkspaceState(panel);
    return result.isValid;
  }

  /// 탭이 존재하는지 확인
  static bool tabExists(SplitPanel panel, String tabId) {
    return findTabOwnerGroup(panel, tabId) != null;
  }

  /// 그룹이 존재하는지 확인
  static bool groupExists(SplitPanel panel, String groupId) {
    return findGroupById(panel, groupId) != null;
  }

  // ========================================================================
  // 🛠️ 디버그 및 개발 도구 - 🆕 검증 정보 포함
  // ========================================================================

  /// 워크스페이스 구조를 보기 좋게 출력 (🆕 검증 정보 포함)
  static String getWorkspaceDebugInfo(SplitPanel panel) {
    final buffer = StringBuffer();
    buffer.writeln('🏗️ Workspace Structure Debug Info:');
    buffer.writeln('═' * 50);

    // 🆕 상태 검증 정보
    final validation = validateWorkspaceState(panel);
    buffer.writeln('✅ 상태 검증:');
    buffer.writeln('   유효성: ${validation.isValid ? "✅ 정상" : "❌ 오류"}');
    if (validation.errors.isNotEmpty) {
      buffer.writeln('   오류: ${validation.errors.length}개');
      for (final error in validation.errors) {
        buffer.writeln('     - $error');
      }
    }
    if (validation.warnings.isNotEmpty) {
      buffer.writeln('   경고: ${validation.warnings.length}개');
      for (final warning in validation.warnings) {
        buffer.writeln('     - $warning');
      }
    }
    buffer.writeln('');

    buffer.writeln('📊 Statistics:');
    buffer.writeln('   Total Tabs: ${countTabs(panel)}');
    buffer.writeln('   Total Groups: ${countGroups(panel)}');
    buffer.writeln('   Max Depth: ${calculateMaxDepth(panel)}');
    buffer.writeln(
        '   Root Type: ${panel.isLeaf ? 'Single Group' : 'Split Container'}');
    buffer.writeln('');
    buffer.writeln('🌳 Tree Structure:');
    buffer.writeln(panel.toTreeString());
    buffer.writeln('═' * 50);

    return buffer.toString();
  }

  /// 특정 그룹의 상세 정보 출력
  static String getGroupDebugInfo(SplitPanel panel, String groupId) {
    final group = findGroupById(panel, groupId);
    if (group == null) {
      return '❌ Group not found: $groupId';
    }

    final buffer = StringBuffer();
    buffer.writeln('🎯 Group Debug Info: $groupId');
    buffer.writeln('─' * 30);
    buffer.writeln('Type: ${group.isLeaf ? 'Tab Group' : 'Split Container'}');

    if (group.isLeaf) {
      buffer.writeln('Tab Count: ${group.tabCount}');
      buffer.writeln('Active Tab: ${group.activeTabId ?? 'None'}');
      if (group.tabs != null) {
        buffer.writeln('Tabs:');
        for (int i = 0; i < group.tabs!.length; i++) {
          final tab = group.tabs![i];
          final isActive = tab.id == group.activeTabId ? ' (Active)' : '';
          buffer.writeln('  [$i] ${tab.title}$isActive');
        }
      }
    } else {
      buffer.writeln('Direction: ${group.direction?.name ?? 'Unknown'}');
      buffer.writeln('Ratio: ${(group.ratio * 100).round()}%');
      buffer.writeln('Children: ${group.children?.length ?? 0}');
    }

    return buffer.toString();
  }

  /// 모든 그룹 목록 및 정보 출력
  static String getAllGroupsInfo(SplitPanel panel) {
    final buffer = StringBuffer();
    final groups = <SplitPanel>[];

    // 모든 그룹 수집
    void collectGroups(SplitPanel p) {
      groups.add(p);
      if (p.children != null) {
        for (final child in p.children!) {
          collectGroups(child);
        }
      }
    }

    collectGroups(panel);

    buffer.writeln('📝 All Groups Info:');
    buffer.writeln('═' * 40);

    for (final group in groups) {
      buffer.writeln('🔹 ${group.id}:');
      buffer.writeln(
          '   Type: ${group.isLeaf ? 'Tab Group' : 'Split Container'}');
      if (group.isLeaf) {
        buffer.writeln('   Tabs: ${group.tabCount}');
        buffer.writeln('   Active: ${group.activeTabId ?? 'None'}');
      } else {
        buffer.writeln('   Direction: ${group.direction?.name ?? 'Unknown'}');
        buffer.writeln('   Children: ${group.children?.length ?? 0}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

```
## lib/features/split_workspace/widgets/group_content.dart
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/provider/theme_provider.dart';
import '../../split_workspace/providers/global_drag_provider.dart';
import '../../split_workspace/providers/group_drag_provider.dart';
import '../../split_workspace/widgets/split_preview_overlay.dart'; // 🆕 미리보기만 남김
import '../../tab_system/models/tab_model.dart';
import '../models/split_panel_model.dart';
import '../providers/split_workspace_provider.dart';

/// 성능 최적화된 그룹별 콘텐츠 영역 위젯
class GroupContent extends ConsumerStatefulWidget {
  final String groupId;
  final TabModel? activeTab;

  const GroupContent({
    super.key,
    required this.groupId,
    this.activeTab,
  });

  @override
  ConsumerState<GroupContent> createState() => _GroupContentState();
}

class _GroupContentState extends ConsumerState<GroupContent> {
  bool _dropZonesInitialized = false;

  // 🚀 성능 최적화: Event Throttling
  Timer? _moveThrottleTimer;
  static const Duration _throttleDuration = Duration(milliseconds: 16); // 60fps

  // 🚀 성능 최적화: 좌표 캐싱
  Size? _lastContentSize;
  Map<DropZoneType, Rect>? _cachedDropZones;
  DropZoneType? _lastDetectedZone;

  @override
  Widget build(BuildContext context) {
    // 🔧 단순화된 상태 조회
    final isDragging =
        ref.watch(globalDragProvider.select((state) => state.isDragging));

    return Stack(
      children: [
        // 🔧 기본 콘텐츠 (DragTarget 포함)
        DragTarget<TabModel>(
          onWillAcceptWithDetails: (details) {
            if (isDragging && !_dropZonesInitialized) {
              _initializeDropZones();
            }
            return true;
          },
          onMove: (details) {
            if (isDragging && _dropZonesInitialized) {
              _handleThrottledMove();
            }
          },
          onLeave: (data) {
            _cleanupDropZones();
          },
          onAcceptWithDetails: (details) {
            _handleDrop(details.data);
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              color: ref.color.surface,
              child: widget.activeTab?.content ??
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color:
                              ref.color.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No active tab in group ${widget.groupId}',
                          style: ref.font.regularText14.copyWith(
                            color: ref.color.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
            );
          },
        ),

        // 🆕 분할 미리보기만 남김 (최상위 레이어)
        if (isDragging && _dropZonesInitialized)
          SplitPreviewOverlay(groupId: widget.groupId),
      ],
    );
  }

  /// 🚀 성능 최적화: Throttled 마우스 이벤트 처리
  void _handleThrottledMove() {
    if (_moveThrottleTimer?.isActive == true) return;

    _moveThrottleTimer = Timer(_throttleDuration, () {
      if (!mounted) return;
      _processMousePosition();
    });
  }

  /// 🚀 성능 최적화: 실제 마우스 위치 처리 (throttled)
  void _processMousePosition() {
    final globalDrag = ref.read(globalDragProvider);
    if (!globalDrag.isDragging || globalDrag.globalPosition == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalDrag.globalPosition!);
    final size = renderBox.size;

    // 🚀 최적화: 영역 밖이면 빠른 종료
    if (localPosition.dx < 0 ||
        localPosition.dx > size.width ||
        localPosition.dy < 0 ||
        localPosition.dy > size.height) {
      return;
    }

    // 🚀 최적화: 드롭존 캐싱 및 재사용
    final dropZones = _getOrCalculateDropZones(size);
    final detectedZone = _detectDropZone(localPosition, dropZones);

    // 🚀 최적화: 같은 존이면 상태 업데이트 건너뛰기
    if (detectedZone == _lastDetectedZone) return;
    _lastDetectedZone = detectedZone;

    // 🔧 기존 상태 업데이트 (완전 보존)
    ref.read(groupDragProvider.notifier).setGroupHover(widget.groupId, true);
    ref
        .read(groupDragProvider.notifier)
        .setDropZone(widget.groupId, detectedZone);

    // 🆕 미리보기 상태 업데이트
    _updateSplitPreview(size, detectedZone);
  }

  /// 🆕 분할 미리보기 상태 업데이트
  void _updateSplitPreview(Size contentSize, DropZoneType? detectedZone) {
    final groupDragNotifier = ref.read(groupDragProvider.notifier);

    // 🔧 모든 드롭존 타입에서 미리보기 표시 (moveToGroup 포함)
    if (detectedZone != null) {
      groupDragNotifier.setSplitPreview(
          widget.groupId, contentSize, detectedZone);
    } else {
      groupDragNotifier.clearSplitPreview(widget.groupId);
    }
  }

  /// 🚀 성능 최적화: 드롭존 캐싱
  Map<DropZoneType, Rect> _getOrCalculateDropZones(Size size) {
    if (_lastContentSize == size && _cachedDropZones != null) {
      return _cachedDropZones!;
    }

    _lastContentSize = size;
    _cachedDropZones = _calculateDropZones(size);
    return _cachedDropZones!;
  }

  /// 🚀 최적화된 드롭존 계산
  Map<DropZoneType, Rect> _calculateDropZones(Size size) {
    final width = size.width;
    final height = size.height;

    return {
      DropZoneType.splitLeft: Rect.fromLTWH(0, 0, width * 0.33, height),
      DropZoneType.splitRight:
          Rect.fromLTWH(width * 0.67, 0, width * 0.33, height),
      DropZoneType.splitTop:
          Rect.fromLTWH(width * 0.33, 0, width * 0.34, height * 0.33),
      DropZoneType.splitBottom: Rect.fromLTWH(
          width * 0.33, height * 0.67, width * 0.34, height * 0.33),
      DropZoneType.moveToGroup: Rect.fromLTWH(
          width * 0.33, height * 0.33, width * 0.34, height * 0.34),
    };
  }

  /// 🚀 최적화된 드롭존 감지
  DropZoneType? _detectDropZone(
      Offset position, Map<DropZoneType, Rect> zones) {
    // 중앙 영역 먼저 체크 (가장 자주 사용)
    if (zones[DropZoneType.moveToGroup]!.contains(position)) {
      return DropZoneType.moveToGroup;
    }

    // 나머지 영역들 체크
    for (final entry in zones.entries) {
      if (entry.key != DropZoneType.moveToGroup &&
          entry.value.contains(position)) {
        return entry.key;
      }
    }

    return null;
  }

  /// 🆕 중첩 분할 지원 드롭 처리 (기존 로직 완전 보존)
  void _handleDrop(TabModel droppedTab) {
    final groupDragState = ref.read(groupDragProvider);
    final targetDropZone = groupDragState.dropZone;

    if (targetDropZone != null) {
      switch (targetDropZone) {
        case DropZoneType.splitLeft:
        case DropZoneType.splitRight:
        case DropZoneType.splitTop:
        case DropZoneType.splitBottom:
          ref.read(splitWorkspaceProvider.notifier).createSplit(
                sourceTabId: droppedTab.id,
                dropZone: targetDropZone,
                targetGroupId: widget.groupId,
              );
          break;

        case DropZoneType.moveToGroup:
          ref.read(splitWorkspaceProvider.notifier).moveTabToGroup(
                tabId: droppedTab.id,
                targetGroupId: widget.groupId,
              );
          break;
      }
    }

    _cleanupAfterDrop();
  }

  /// 드롭 존 초기화
  void _initializeDropZones() {
    if (_dropZonesInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(groupDragProvider.notifier).setGroupHover(widget.groupId, true);

      setState(() {
        _dropZonesInitialized = true;
      });
    });
  }

  /// 🔧 드롭 존 정리 (🆕 미리보기 정리 추가)
  void _cleanupDropZones() {
    if (!_dropZonesInitialized) return;

    // 🔧 기존 정리 로직 (완전 보존)
    ref.read(groupDragProvider.notifier).setGroupHover(widget.groupId, false);
    ref.read(groupDragProvider.notifier).clearDropZone(widget.groupId);

    // 🆕 미리보기 정리 추가
    ref.read(groupDragProvider.notifier).clearSplitPreview(widget.groupId);

    setState(() {
      _dropZonesInitialized = false;
    });

    // 캐시 초기화
    _lastDetectedZone = null;
  }

  /// 🔧 드롭 후 완전 정리 (🆕 미리보기 정리 추가)
  void _cleanupAfterDrop() {
    // 🔧 기존 정리 로직 (완전 보존)
    ref.read(globalDragProvider.notifier).endDrag();
    ref.read(groupDragProvider.notifier).clearAllStates();

    setState(() {
      _dropZonesInitialized = false;
    });

    // 캐시 완전 초기화
    _lastDetectedZone = null;
    _cachedDropZones = null;
    _lastContentSize = null;
  }

  @override
  void dispose() {
    _moveThrottleTimer?.cancel();
    if (_dropZonesInitialized) {
      _cleanupDropZones();
    }
    super.dispose();
  }
}

```
## lib/features/split_workspace/widgets/group_tab_bar.dart
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/provider/theme_provider.dart';
import '../../split_workspace/providers/global_drag_provider.dart';
import '../../split_workspace/providers/group_drag_provider.dart';
import '../../tab_system/models/tab_model.dart';
import '../../tab_system/widgets/tab_item.dart';
import '../providers/split_workspace_provider.dart';

/// 성능 최적화된 그룹별 독립적인 탭바 위젯
class GroupTabBar extends ConsumerStatefulWidget {
  final String groupId;
  final List<TabModel> tabs;
  final String? activeTabId;
  final Function(String) onTabTap;
  final Function(String) onTabClose;

  const GroupTabBar({
    super.key,
    required this.groupId,
    required this.tabs,
    this.activeTabId,
    required this.onTabTap,
    required this.onTabClose,
  });

  @override
  ConsumerState<GroupTabBar> createState() => _GroupTabBarState();
}

class _GroupTabBarState extends ConsumerState<GroupTabBar> {
  final Map<String, GlobalKey> _tabKeys = {};
  final GlobalKey _tabBarKey = GlobalKey();

  // 🚀 성능 최적화: Move Event Throttling
  Timer? _moveThrottleTimer;
  static const Duration _throttleDuration = Duration(milliseconds: 8);

  // 🚀 성능 최적화: 계산 캐싱
  double? _cachedTabWidth;
  int? _lastInsertIndex;
  double? _lastIndicatorX;

  @override
  Widget build(BuildContext context) {
    // 🔧 단순화된 상태 조회
    final isDragging =
        ref.watch(globalDragProvider.select((state) => state.isDragging));
    final groupDragState = ref.watch(groupDragProvider);
    final isMyGroupTarget = groupDragState.targetGroupId == widget.groupId;

    // 탭 키 준비 (변경된 탭만)
    for (final tab in widget.tabs) {
      _tabKeys[tab.id] ??= GlobalKey();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 🚀 최적화: 탭 너비 캐싱
        final availableWidth = constraints.maxWidth - 36;
        final tabWidth = widget.tabs.isNotEmpty
            ? (availableWidth / widget.tabs.length).clamp(80.0, 200.0)
            : 120.0;

        _cachedTabWidth = tabWidth;

        return Stack(
          children: [
            // 메인 탭바
            DragTarget<TabModel>(
              key: _tabBarKey,
              onWillAcceptWithDetails: (details) {
                return true;
              },
              onMove: (details) {
                if (isDragging) {
                  _handleImmediateMove();
                  _handleThrottledMove();
                }
              },
              onLeave: (data) {
                ref
                    .read(groupDragProvider.notifier)
                    .clearInsertPosition(widget.groupId);

                // 🔧 캐시 변수도 초기화!
                _lastInsertIndex = null;
                _lastIndicatorX = null;
              },
              onAcceptWithDetails: (details) {
                _handleDrop(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: ref.color.background,
                    border: Border(
                      bottom: BorderSide(
                        color: ref.color.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 표시되는 탭들
                      ...widget.tabs.map((tab) => TabItem(
                            tab: tab,
                            tabKey: _tabKeys[tab.id]!,
                            groupId: widget.groupId,
                            tabWidth: tabWidth,
                            onTap: () => widget.onTabTap(tab.id),
                            onClose: () => widget.onTabClose(tab.id),
                          )),

                      // 새 탭 추가 버튼
                      _buildNewTabButton(),

                      // 남은 공간
                      Expanded(
                        child: Container(
                          color: ref.color.background,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 🔧 단순화된 인디케이터 조건
            if (isDragging &&
                isMyGroupTarget &&
                groupDragState.showInsertIndicator &&
                groupDragState.indicatorX != null)
              Positioned(
                left: groupDragState.indicatorX! - 1,
                top: 0,
                child: Container(
                  width: 2,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ref.color.primary,
                    boxShadow: [
                      BoxShadow(
                        color: ref.color.primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 새 탭 추가 버튼
  Widget _buildNewTabButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: ref.color.border,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref
                .read(splitWorkspaceProvider.notifier)
                .addTabToGroup(widget.groupId);
          },
          child: Icon(
            Icons.add,
            size: 16,
            color: ref.color.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// 즉시 처리 (throttling 없이)
  void _handleImmediateMove() {
    if (!mounted) return;
    _updateInsertPosition();
  }

  /// Throttled 마우스 이벤트 처리
  void _handleThrottledMove() {
    if (_moveThrottleTimer?.isActive == true) return;

    _moveThrottleTimer = Timer(_throttleDuration, () {
      if (!mounted) return;
      _updateInsertPosition();
    });
  }

  /// 🔧 기존 삽입 위치 업데이트 로직 유지
  void _updateInsertPosition() {
    final globalDrag = ref.read(globalDragProvider);

    if (!globalDrag.isDragging ||
        globalDrag.globalPosition == null ||
        _cachedTabWidth == null) {
      return;
    }

    final renderBox =
        _tabBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalDrag.globalPosition!);
    final tabWidth = _cachedTabWidth!;

    // 기존 로직 유지 (1단계에서 개선한 것)
    int insertIndex = 0;
    double indicatorX = 0;

    final draggedTabIndex = globalDrag.sourceGroupId == widget.groupId
        ? widget.tabs.indexWhere((tab) => tab.id == globalDrag.draggedTab!.id)
        : -1;

    // 화면상 실제 탭 위치 기준으로 계산 (모든 탭 포함)
    bool found = false;
    for (int i = 0; i < widget.tabs.length; i++) {
      final tabX = i * tabWidth;
      final tabCenter = tabX + (tabWidth / 2);

      if (localPosition.dx < tabCenter) {
        insertIndex = i;
        indicatorX = tabX;
        found = true;
        break;
      }
    }

    if (!found) {
      insertIndex = widget.tabs.length;
      indicatorX = widget.tabs.length * tabWidth;
    }

    // 같은 그룹 내 드래그인 경우 원래 위치 보정
    if (draggedTabIndex != -1 && insertIndex > draggedTabIndex) {
      insertIndex--;
    }

    // insertIndex와 indicatorX 둘 다 체크
    if (insertIndex == _lastInsertIndex && indicatorX == _lastIndicatorX) {
      return;
    }

    _lastInsertIndex = insertIndex;
    _lastIndicatorX = indicatorX;

    ref
        .read(groupDragProvider.notifier)
        .setInsertPosition(widget.groupId, insertIndex, indicatorX);
  }

  /// 드롭 처리
  void _handleDrop(TabModel droppedTab) {
    final globalDrag = ref.read(globalDragProvider);
    final groupDragState = ref.read(groupDragProvider);

    if (globalDrag.sourceGroupId != widget.groupId) {
      // 다른 그룹에서 온 탭
      ref.read(splitWorkspaceProvider.notifier).moveTabToGroup(
            tabId: droppedTab.id,
            targetGroupId: widget.groupId,
            insertIndex: groupDragState.insertIndex,
          );
    } else {
      // 같은 그룹 내 순서 변경
      if (groupDragState.insertIndex != null) {
        ref.read(splitWorkspaceProvider.notifier).reorderTab(
              droppedTab.id,
              groupDragState.insertIndex!,
            );
      }
    }

    // 정리
    ref.read(groupDragProvider.notifier).clearInsertPosition(widget.groupId);
    ref.read(globalDragProvider.notifier).endDrag();
    _lastInsertIndex = null;
    _lastIndicatorX = null;
  }

  @override
  void dispose() {
    _moveThrottleTimer?.cancel();
    super.dispose();
  }
}

```
## lib/features/split_workspace/widgets/resizable_splitter.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/provider/theme_provider.dart';
import '../models/split_panel_model.dart';

/// 드래그 가능한 분할선 위젯
class ResizableSplitter extends ConsumerStatefulWidget {
  final SplitDirection direction; // 분할 방향 (수직/수평)
  final double ratio; // 현재 비율 (0.0 ~ 1.0)
  final Function(double) onRatioChanged; // 비율 변경 콜백
  final double minRatio; // 최소 비율 (기본: 0.2 = 20%)
  final double maxRatio; // 최대 비율 (기본: 0.8 = 80%)
  final double thickness; // 스플리터 두께 (기본: 4px)

  const ResizableSplitter({
    super.key,
    required this.direction,
    required this.ratio,
    required this.onRatioChanged,
    this.minRatio = 0.2,
    this.maxRatio = 0.8,
    this.thickness = 4.0,
  });

  @override
  ConsumerState<ResizableSplitter> createState() => _ResizableSplitterState();
}

class _ResizableSplitterState extends ConsumerState<ResizableSplitter> {
  bool _isDragging = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.direction == SplitDirection.vertical
          ? SystemMouseCursors.resizeLeftRight // 수직 분할 시 좌우 화살표
          : SystemMouseCursors.resizeUpDown, // 수평 분할 시 상하 화살표
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanEnd: (_) => setState(() => _isDragging = false),
        onPanUpdate: _handleDrag,
        child: Container(
          // 🆕 방향별로 고정된 크기 설정 (AnimatedContainer 제거)
          key: ValueKey(
              '${widget.direction.name}_splitter'), // 🆕 방향 변경 시 위젯 재생성
          width: widget.direction == SplitDirection.vertical
              ? widget.thickness
              : null,
          height: widget.direction == SplitDirection.horizontal
              ? widget.thickness
              : null,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: Border.all(
              color: _getBorderColor(),
              width: 0.5,
            ),
          ),
          child: _buildGripIndicator(),
        ),
      ),
    );
  }

  /// 드래그 처리 로직
  void _handleDrag(DragUpdateDetails details) {
    // 1. 부모 위젯의 크기 구하기
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // 2. 부모의 부모 크기 구하기 (실제 분할 영역)
    final parentRenderBox = renderBox.parent?.parent as RenderBox?;
    if (parentRenderBox == null) return;

    final parentSize = parentRenderBox.size;

    // 3. 드래그 델타를 비율로 변환
    double deltaRatio;
    if (widget.direction == SplitDirection.vertical) {
      deltaRatio = details.delta.dx / parentSize.width;
    } else {
      deltaRatio = details.delta.dy / parentSize.height;
    }

    // 4. 새 비율 계산 및 제한 적용
    final newRatio =
        (widget.ratio + deltaRatio).clamp(widget.minRatio, widget.maxRatio);

    // 5. 미세 변화 무시 (성능 최적화)
    if ((newRatio - widget.ratio).abs() < 0.001) return;

    // 6. 비율 변경 콜백 호출
    print(
        '🔧 스플리터 드래그: ${(widget.ratio * 100).round()}% → ${(newRatio * 100).round()}%');
    widget.onRatioChanged(newRatio);
  }

  /// 배경색 계산
  Color _getBackgroundColor() {
    if (_isDragging) {
      return ref.color.primary.withOpacity(0.3);
    } else if (_isHovered) {
      return ref.color.primary.withOpacity(0.1);
    } else {
      return ref.color.border;
    }
  }

  /// 경계선 색상 계산
  Color _getBorderColor() {
    if (_isDragging) {
      return ref.color.primary;
    } else if (_isHovered) {
      return ref.color.primary.withOpacity(0.5);
    } else {
      return ref.color.border;
    }
  }

  /// 그립 인디케이터 빌드
  Widget _buildGripIndicator() {
    final isVertical = widget.direction == SplitDirection.vertical;

    return Center(
      child: Container(
        width: isVertical ? 2 : 20,
        height: isVertical ? 20 : 2,
        decoration: BoxDecoration(
          color: _getGripColor(),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  /// 그립 색상 계산
  Color _getGripColor() {
    if (_isDragging) {
      return ref.color.primary;
    } else if (_isHovered) {
      return ref.color.primary.withOpacity(0.7);
    } else {
      return ref.color.onSurfaceVariant.withOpacity(0.4);
    }
  }
}

```
## lib/features/split_workspace/widgets/split_container.dart
```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/split_panel_model.dart';
import '../providers/split_workspace_provider.dart';
import 'resizable_splitter.dart';
import 'tab_group.dart';

/// 재귀적 분할 패널 렌더링 위젯
class SplitContainer extends ConsumerWidget {
  final SplitPanel panel;
  final VoidCallback? onPanelFocused;
  final int depth; // 무한 재귀 방지용

  const SplitContainer({
    super.key,
    required this.panel,
    this.onPanelFocused,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🆕 개선된 안전장치: SplitService와 동일한 최대 깊이 사용
    if (depth > 4) {
      return Container(
        color: Colors.red.withValues(alpha: 0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                'ERROR: 최대 분할 깊이 초과 ($depth/4)',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                '더 이상 분할할 수 없습니다.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (panel.isLeaf) {
      // 단일 그룹: TabGroup 렌더링
      return TabGroup(
        groupId: panel.id,
        tabs: panel.tabs ?? [],
        activeTabId: panel.activeTabId,
        onPanelFocused: onPanelFocused,
      );
    } else {
      // 분할 상태: Flex로 자식들 재귀 렌더링
      return _buildSplitLayout(ref);
    }
  }

  /// 분할 레이아웃 빌드
  Widget _buildSplitLayout(WidgetRef ref) {
    // 안전장치: children 검증
    if (panel.children == null || panel.children!.isEmpty) {
      return Container(
        color: Colors.orange.withValues(alpha: 0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              const Text(
                'ERROR: 빈 분할 패널',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Panel ID: ${panel.id}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 안전장치: 정확히 2개 자식만 지원 (현재 구현)
    if (panel.children!.length != 2) {
      return Container(
        color: Colors.red.withValues(alpha: 0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              const Text(
                'ERROR: 분할은 2개 자식만 지원',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '현재: ${panel.children!.length}개 자식',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final direction = panel.direction ?? SplitDirection.horizontal;
    final children = panel.children!;
    final ratio = panel.ratio; // 0.0 ~ 1.0

    return Flex(
      direction: direction == SplitDirection.horizontal
          ? Axis.vertical
          : Axis.horizontal,
      children: _buildSplitChildren(ref, children, direction, ratio),
    );
  }

  /// 분할 자식 위젯들 빌드 (비율 적용 + 스플리터)
  List<Widget> _buildSplitChildren(
    WidgetRef ref,
    List<SplitPanel> children,
    SplitDirection direction,
    double ratio,
  ) {
    // 첫 번째와 두 번째 자식의 flex 비율 계산
    // 최소값 1로 제한하여 0 flex 방지
    final firstFlex = math.max((ratio * 1000).round(), 1);
    final secondFlex = math.max(((1.0 - ratio) * 1000).round(), 1);

    // 🆕 중첩 분할에 대한 시각적 구분을 위한 경계선 색상 조정
    final borderColor = depth == 0
        ? Colors.grey[400]! // 루트 레벨
        : depth == 1
            ? Colors.grey[300]! // 1차 중첩
            : Colors.grey[200]!; // 2차 이상 중첩

    return [
      // 첫 번째 자식
      Expanded(
        flex: firstFlex,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: SplitContainer(
            panel: children[0],
            onPanelFocused: onPanelFocused,
            depth: depth + 1, // 🆕 깊이 증가
          ),
        ),
      ),

      // 🆕 크기 조절 가능한 스플리터
      ResizableSplitter(
        direction: direction,
        ratio: ratio,
        onRatioChanged: (newRatio) {
          ref
              .read(splitWorkspaceProvider.notifier)
              .updateSplitRatio(panel.id, newRatio);
        },
      ),

      // 두 번째 자식
      Expanded(
        flex: secondFlex,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: SplitContainer(
            panel: children[1],
            onPanelFocused: onPanelFocused,
            depth: depth + 1, // 🆕 깊이 증가
          ),
        ),
      ),
    ];
  }
}

```
## lib/features/split_workspace/widgets/split_preview_overlay.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/foundation/app_theme.dart';
import '../../../core/theme/provider/theme_provider.dart';
import '../models/split_panel_model.dart';
import '../providers/group_drag_provider.dart';

/// 🎨 분할 미리보기 전용 오버레이 위젯
class SplitPreviewOverlay extends ConsumerWidget {
  final String groupId;

  const SplitPreviewOverlay({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🚀 최적화: 해당 그룹의 미리보기 상태만 선택적으로 watch
    final shouldShow = ref.watch(groupDragProvider.select(
        (state) => state.targetGroupId == groupId && state.showSplitPreview));

    final previewArea = ref.watch(groupDragProvider.select((state) =>
        state.targetGroupId == groupId ? state.splitPreviewArea : null));

    // 🔍 디버깅용 로그
    print(
        '🎨 [SplitPreviewOverlay-$groupId] shouldShow: $shouldShow, previewArea: ${previewArea != null}');

    // 미리보기가 필요없거나 정보가 없으면 빈 위젯 반환
    if (!shouldShow || previewArea == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        // 마우스 이벤트 차단하지 않음
        child: Container(
          // 🔍 디버깅용 배경색 (나중에 제거)
          color: Colors.red.withValues(alpha: 0.1),
          child: Stack(
            children: [
              // 1. 기존 그룹 영역 (어두운 오버레이)
              _buildExistingGroupOverlay(ref, previewArea),

              // 2. 새 그룹 영역 (밝은 강조)
              _buildNewGroupArea(ref, previewArea),

              // 3. 분할선 강조
              _buildSplitLine(ref, previewArea),
            ],
          ),
        ),
      ),
    );
  }

  /// 기존 그룹 영역 오버레이 (약간 어둡게)
  Widget _buildExistingGroupOverlay(
      WidgetRef ref, SplitPreviewArea previewArea) {
    // 🔧 moveToGroup일 때는 기존 그룹 오버레이 표시하지 않음
    // (전체 영역이 새 그룹이므로)
    if (previewArea.dropZoneType == DropZoneType.moveToGroup) {
      return const SizedBox.shrink();
    }

    return Positioned.fromRect(
      rect: previewArea.existingGroupArea,
      child: Container(
        decoration: BoxDecoration(
          color: ref.color.surface.withValues(alpha: 0.9), // 🔧 더 진하게
          border: Border.all(
            color: ref.color.outline.withValues(alpha: 0.8), // 🔧 더 진하게
            width: 2, // 🔧 더 굵게
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ref.color.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ref.color.outline,
                width: 1,
              ),
            ),
            child: Text(
              '기존 그룹',
              style: ref.font.mediumText12.copyWith(
                color: ref.color.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 새 그룹 영역 (밝은 강조)
  Widget _buildNewGroupArea(WidgetRef ref, SplitPreviewArea previewArea) {
    // 🆕 moveToGroup과 분할의 다른 스타일 적용
    final isMoveToGroup = previewArea.dropZoneType == DropZoneType.moveToGroup;

    // 색상과 스타일 선택
    final backgroundColor = isMoveToGroup
        ? ref.color.success.withValues(alpha: 0.2) // 탭 이동: 초록색
        : ref.color.primary.withValues(alpha: 0.3); // 분할: 보라색

    final borderColor = isMoveToGroup
        ? ref.color.success.withValues(alpha: 0.9)
        : ref.color.primary.withValues(alpha: 0.9);

    final shadowColor = isMoveToGroup
        ? ref.color.success.withValues(alpha: 0.5)
        : ref.color.primary.withValues(alpha: 0.5);

    final labelText = isMoveToGroup ? '📥 탭 추가' : '🆕 새 그룹';
    final labelColor = isMoveToGroup ? ref.color.success : ref.color.primary;

    return Positioned.fromRect(
      rect: previewArea.newGroupArea,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 3,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: labelColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Text(
              labelText,
              style: ref.font.semiBoldText14.copyWith(
                color:
                    isMoveToGroup ? ref.color.onPrimary : ref.color.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 분할선 강조
  Widget _buildSplitLine(WidgetRef ref, SplitPreviewArea previewArea) {
    // 🔧 moveToGroup은 분할선이 없으므로 제외
    if (previewArea.dropZoneType == DropZoneType.moveToGroup) {
      return const SizedBox.shrink();
    }

    final isVertical = previewArea.direction == SplitDirection.vertical;
    final lineColor = ref.color.primary.withValues(alpha: 0.9);
    const lineWidth = 4.0;

    Widget splitLine;

    if (isVertical) {
      // 세로 분할선 (좌우 분할)
      final lineX = previewArea.direction == SplitDirection.vertical
          ? previewArea.newGroupArea.right // 새 그룹과 기존 그룹 경계
          : previewArea.newGroupArea.left;

      splitLine = Positioned(
        left: lineX - lineWidth / 2,
        top: 0,
        child: Container(
          width: lineWidth,
          height: previewArea.existingGroupArea.height,
          decoration: BoxDecoration(
            color: lineColor,
            borderRadius: BorderRadius.circular(lineWidth / 2),
            boxShadow: [
              BoxShadow(
                color: lineColor.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    } else {
      // 가로 분할선 (상하 분할)
      final lineY = previewArea.direction == SplitDirection.horizontal
          ? previewArea.newGroupArea.bottom // 새 그룹과 기존 그룹 경계
          : previewArea.newGroupArea.top;

      splitLine = Positioned(
        left: 0,
        top: lineY - lineWidth / 2,
        child: Container(
          width: previewArea.existingGroupArea.width,
          height: lineWidth,
          decoration: BoxDecoration(
            color: lineColor,
            borderRadius: BorderRadius.circular(lineWidth / 2),
            boxShadow: [
              BoxShadow(
                color: lineColor.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    }

    return splitLine;
  }
}

/// 🎨 분할 방향별 미리보기 도우미 클래스
class SplitPreviewHelper {
  SplitPreviewHelper._();

  /// 드롭존 타입에 따른 미리보기 설명 텍스트
  static String getPreviewDescription(DropZoneType dropZoneType) {
    switch (dropZoneType) {
      case DropZoneType.splitLeft:
        return '좌측에 새 그룹 생성';
      case DropZoneType.splitRight:
        return '우측에 새 그룹 생성';
      case DropZoneType.splitTop:
        return '상단에 새 그룹 생성';
      case DropZoneType.splitBottom:
        return '하단에 새 그룹 생성';
      case DropZoneType.moveToGroup:
        return '기존 그룹에 탭 추가';
    }
  }

  /// 분할 방향에 따른 아이콘
  static IconData getPreviewIcon(DropZoneType dropZoneType) {
    switch (dropZoneType) {
      case DropZoneType.splitLeft:
        return Icons.border_left;
      case DropZoneType.splitRight:
        return Icons.border_right;
      case DropZoneType.splitTop:
        return Icons.border_top;
      case DropZoneType.splitBottom:
        return Icons.border_bottom;
      case DropZoneType.moveToGroup:
        return Icons.add_box_outlined;
    }
  }

  /// 미리보기 색상 조합
  static ({Color newGroup, Color existingGroup, Color splitLine})
      getPreviewColors(
    AppColor colors,
    DropZoneType dropZoneType,
  ) {
    if (dropZoneType == DropZoneType.moveToGroup) {
      return (
        newGroup: colors.success.withValues(alpha: 0.15),
        existingGroup: colors.surface.withValues(alpha: 0.8),
        splitLine: colors.success,
      );
    }

    return (
      newGroup: colors.primary.withValues(alpha: 0.15),
      existingGroup: colors.surface.withValues(alpha: 0.8),
      splitLine: colors.primary.withValues(alpha: 0.9),
    );
  }
}

/// 🎨 커스텀 페인터를 사용한 고성능 미리보기 (향후 확장용)
class SplitPreviewPainter extends CustomPainter {
  final SplitPreviewArea previewArea;
  final Color newGroupColor;
  final Color existingGroupColor;
  final Color splitLineColor;

  SplitPreviewPainter({
    required this.previewArea,
    required this.newGroupColor,
    required this.existingGroupColor,
    required this.splitLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 기존 그룹 영역 그리기
    paint.color = existingGroupColor;
    canvas.drawRect(previewArea.existingGroupArea, paint);

    // 새 그룹 영역 그리기 (분할일 때만)
    if (previewArea.dropZoneType != DropZoneType.moveToGroup) {
      paint.color = newGroupColor;
      canvas.drawRect(previewArea.newGroupArea, paint);

      // 분할선 그리기
      paint.color = splitLineColor;
      paint.strokeWidth = 4.0;

      if (previewArea.direction == SplitDirection.vertical) {
        // 세로 분할선
        final lineX = previewArea.newGroupArea.right;
        canvas.drawLine(
          Offset(lineX, 0),
          Offset(lineX, size.height),
          paint,
        );
      } else {
        // 가로 분할선
        final lineY = previewArea.newGroupArea.bottom;
        canvas.drawLine(
          Offset(0, lineY),
          Offset(size.width, lineY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SplitPreviewPainter oldDelegate) {
    return previewArea != oldDelegate.previewArea ||
        newGroupColor != oldDelegate.newGroupColor ||
        existingGroupColor != oldDelegate.existingGroupColor ||
        splitLineColor != oldDelegate.splitLineColor;
  }
}

```
## lib/features/split_workspace/widgets/tab_group.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/provider/theme_provider.dart';
import '../../tab_system/models/tab_model.dart';
import '../providers/split_workspace_provider.dart';
import 'group_content.dart';
import 'group_tab_bar.dart';

/// 개별 그룹의 탭바 + 콘텐츠 렌더링 위젯
class TabGroup extends ConsumerWidget {
  final String groupId;
  final List<TabModel> tabs;
  final String? activeTabId;
  final VoidCallback? onPanelFocused;

  const TabGroup({
    super.key,
    required this.groupId,
    required this.tabs,
    this.activeTabId,
    this.onPanelFocused,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 빈 그룹 처리
    if (tabs.isEmpty) {
      return Container(
        color: ref.color.surfaceVariant.withOpacity(0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tab_unselected,
                size: 48,
                color: ref.color.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Empty Group',
                style: ref.font.regularText14.copyWith(
                  color: ref.color.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref
                    .read(splitWorkspaceProvider.notifier)
                    .addTabToGroup(groupId),
                child: const Text('Add Tab'),
              ),
            ],
          ),
        ),
      );
    } 

    // 활성 탭 찾기
    final activeTab = _findActiveTab(tabs, activeTabId);

    return Container(
      decoration: BoxDecoration(
        color: ref.color.background,
        border: Border.all(
          color: ref.color.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 그룹별 탭바
          GroupTabBar(
            groupId: groupId,
            tabs: tabs,
            activeTabId: activeTabId,
            onTabTap: (tabId) {
              ref.read(splitWorkspaceProvider.notifier).activateTab(tabId);
              onPanelFocused?.call();
            },
            onTabClose: (tabId) {
              ref.read(splitWorkspaceProvider.notifier).removeTab(tabId);
            },
          ),

          // 그룹별 콘텐츠
          Expanded(
            child: GroupContent(
              groupId: groupId,
              activeTab: activeTab,
            ),
          ),
        ],
      ),
    );
  }

  /// 활성 탭 찾기 (안전한 검색)
  TabModel? _findActiveTab(List<TabModel> tabs, String? activeTabId) {
    if (activeTabId == null || tabs.isEmpty) return null;

    try {
      return tabs.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      // activeTabId가 목록에 없으면 첫 번째 탭을 기본값으로
      return tabs.first;
    }
  }
}

```
## lib/features/tab_system/models/tab_model.dart
```dart
import 'package:flutter/material.dart';

class TabModel {
  final String id;
  final String title;
  final bool isActive;
  final Widget? content;

  const TabModel({
    required this.id,
    required this.title,
    this.isActive = false,
    this.content,
  });

  TabModel copyWith({
    String? id,
    String? title,
    bool? isActive,
    Widget? content,
  }) {
    return TabModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      content: content ?? this.content,
    );
  }
}

```
## lib/features/tab_system/screens/tab_workspace_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_tab_move/features/split_workspace/providers/workspace_computed_providers.dart';

import '../../split_workspace/providers/split_workspace_provider.dart';
import '../../split_workspace/services/workspace_helpers.dart';
import '../../split_workspace/widgets/split_container.dart';

class TabWorkspaceScreen extends ConsumerWidget {
  const TabWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🚀 최적화: 워크스페이스와 통계를 선택적으로 watch
    final workspace = ref.watch(splitWorkspaceProvider);
    final stats = ref.watch(workspaceStatsProvider);

    return Column(
      children: [
        // 메인 워크스페이스
        Expanded(
          child: SplitContainer(
            panel: workspace,
            onPanelFocused: () {
              // 그룹 포커스 변경 시 처리 (추후 확장)
            },
          ),
        ),

        // 🆕 강화된 디버그 정보 (상태 검증 포함)
        _EnhancedDebugInfoBar(stats: stats, workspace: workspace),
      ],
    );
  }
}

/// 🆕 상태 검증을 포함한 강화된 디버그 정보 바
class _EnhancedDebugInfoBar extends ConsumerWidget {
  final Map<String, dynamic> stats;
  final dynamic workspace;

  const _EnhancedDebugInfoBar({
    required this.stats,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🆕 실시간 상태 검증
    final validation = WorkspaceHelpers.validateWorkspaceState(workspace);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // 기본 통계 정보
          Row(
            children: [
              Text(
                '📊 탭: ${stats['totalTabs']} | 그룹: ${stats['totalGroups']} | 타입: ${stats['rootType']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 16),

              // 🆕 상태 검증 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: validation.isValid
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  validation.isValid ? '✅ 정상' : '❌ 오류',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              if (workspace?.isSplit == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SPLIT MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          // 🆕 상세 오류/경고 정보 (있을 때만 표시)
          if (validation.errors.isNotEmpty ||
              validation.warnings.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: validation.errors.isNotEmpty
                    ? Colors.red.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 오류 목록
                  if (validation.errors.isNotEmpty) ...[
                    Text(
                      '❌ 오류 (${validation.errors.length}):',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...validation.errors.take(3).map((error) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '• $error',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                            ),
                          ),
                        )),
                    if (validation.errors.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '• ... 외 ${validation.errors.length - 3}개',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],

                  // 경고 목록
                  if (validation.warnings.isNotEmpty) ...[
                    if (validation.errors.isNotEmpty) const SizedBox(height: 2),
                    Text(
                      '⚠️ 경고 (${validation.warnings.length}):',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...validation.warnings.take(2).map((warning) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '• $warning',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                            ),
                          ),
                        )),
                    if (validation.warnings.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '• ... 외 ${validation.warnings.length - 2}개',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

```
## lib/features/tab_system/widgets/tab_item.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/provider/theme_provider.dart';
import '../../split_workspace/providers/drop_zone_provider.dart';
import '../../split_workspace/providers/global_drag_provider.dart';
import '../models/tab_model.dart';
 
class TabItem extends ConsumerWidget {
  final TabModel tab;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final GlobalKey tabKey;
  final String groupId;
  final double? tabWidth;

  const TabItem({
    super.key,
    required this.tab,
    required this.onTap,
    required this.onClose,
    required this.tabKey,
    required this.groupId,
    this.tabWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      key: tabKey,
      height: 36,
      width: tabWidth,
      constraints: tabWidth == null
          ? const BoxConstraints(
              minWidth: 120,
              maxWidth: 200,
            )
          : null,
      child: Stack(
        children: [
          // 드래그 가능한 탭 영역 (X 버튼 제외)
          LongPressDraggable<TabModel>(
            data: tab,
            delay: const Duration(milliseconds: 100),
            onDragStarted: () => _handleDragStart(ref),
            onDragUpdate: (details) {
              ref
                  .read(globalDragProvider.notifier)
                  .updateGlobalPosition(details.globalPosition);
            },
            onDragEnd: (details) => _handleDragEnd(ref),
            feedback: _buildDragFeedback(ref, tabWidth),
            feedbackOffset: Offset.zero, // 🆕 마우스 포인터를 좌측 상단에 맞춤
            childWhenDragging: _buildDragPlaceholder(ref, tabWidth),
            child: _buildTabContent(ref, tabWidth),
          ),

          // X 버튼 (별도 레이어, 드래그 불가능)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 32,
              height: 36,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(4),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: tab.isActive
                          ? ref.color.onSurface
                          : ref.color.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 드래그 시작 처리
  void _handleDragStart(WidgetRef ref) {
    final renderBox = tabKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      ref.read(globalDragProvider.notifier).startDrag(tab, groupId, position);
    }
  }

  /// 드래그 종료 처리
  void _handleDragEnd(WidgetRef ref) {
    ref.read(globalDragProvider.notifier).endDrag();
    ref.read(dropZoneProvider.notifier).hideDropZones();
  }

  /// 🔧 개선된 드래그 피드백 위젯 (더 투명하고 크기 조정)
  Widget _buildDragFeedback(WidgetRef ref, double? tabWidth) {
    final feedbackWidth = (tabWidth ?? 140) * 0.95;

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(6),
      color: Colors.transparent,
      child: Container(
        height: 34,
        width: feedbackWidth,
        decoration: BoxDecoration(
          color: ref.color.primary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: ref.color.primary.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tab,
                size: 15,
                color: ref.color.onPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tab.title,
                  style: ref.font.mediumText12.copyWith(
                    // 13 → 12로 폰트 크기 줄임
                    color: ref.color.onPrimary.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 드래그 중 표시될 플레이스홀더
  Widget _buildDragPlaceholder(WidgetRef ref, double? tabWidth) {
    return Container(
      height: 36,
      width: tabWidth,
      decoration: BoxDecoration(
        color: ref.color.surfaceVariant.withValues(alpha: 0.3),
        border: Border(
          right: BorderSide(
            color: ref.color.border,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              Icons.drag_indicator,
              size: 12,
              color: ref.color.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                tab.title,
                style: ref.font.regularText13.copyWith(
                  color: ref.color.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  /// 일반 탭 콘텐츠
  Widget _buildTabContent(WidgetRef ref, double? tabWidth) {
    return Container(
      height: 36,
      width: tabWidth,
      decoration: BoxDecoration(
        color: tab.isActive
            ? ref.color.surface
            : ref.color.surfaceVariant.withValues(alpha: 0.3),
        border: Border(
          right: BorderSide(
            color: ref.color.border,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 32),
            child: Row(
              children: [
                // 드래그 핸들 (너비가 충분할 때만 표시)
                if ((tabWidth ?? 120) > 100) ...[
                  Icon(
                    Icons.drag_indicator,
                    size: 12,
                    color: ref.color.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                ],

                // 탭 제목
                Expanded(
                  child: Text(
                    tab.title,
                    style: ref.font.regularText13.copyWith(
                      color: tab.isActive
                          ? ref.color.onSurface
                          : ref.color.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
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

```
## lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/const/enum_hive_key.dart';
import 'core/localization/generated/l10n.dart';
import 'core/localization/provider/locale_state_provider.dart';
import 'core/theme/provider/theme_provider.dart';
import 'core/ui/title_bar/app_title_bar.dart';
import 'features/tab_system/screens/tab_workspace_screen.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  /// Hive 초기화
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveKey.boxSettings.key);

  // 윈도우 매니저 설정
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // 타이틀바 숨기기
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 앱 실행
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tab System Demo',
      theme: theme.themeData,
      locale: locale,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('ko'), // Korean
      ],
      home: const MyHome(),
    );
  }
}

class MyHome extends ConsumerWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Column(
        children: [
          // 커스텀 타이틀바
          AppTitleBar(),

          // 탭 워크스페이스
          Expanded(
            child: TabWorkspaceScreen(),
          ),
        ],
      ),
    );
  }
}

```
## pubspec.yaml
```yaml
name: test_tab_move
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev


version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  cupertino_icons: ^1.0.8
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  flutter_svg: ^2.2.0
  hive_flutter: ^1.1.0
  intl: ^0.20.2
  riverpod_annotation: ^2.6.1
  window_manager: ^0.4.3

dev_dependencies:
  build_runner: ^2.5.4
  flutter_lints: ^5.0.0
  flutter_test:
    sdk: flutter
  # hive
  hive_generator: ^2.0.1

  # riverpod
  riverpod_generator: ^2.6.3
  riverpod_lint: ^2.6.3 

flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/icons/titlebar/
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
          weight: 400
        - asset: assets/fonts/Pretendard-Medium.ttf
          weight: 500
        - asset: assets/fonts/Pretendard-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
        - asset: assets/fonts/SpaceMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/SpaceMono-Bold.ttf
          weight: 700

flutter_intl:
  enabled: true
  arb_dir: lib/core/localization/l10n
  output_dir: lib/core/localization/generated

```
