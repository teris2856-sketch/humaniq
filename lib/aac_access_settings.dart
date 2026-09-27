import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AacGridSize { large, standard, compact }

enum AacSpacing { tight, normal, wide }

enum AacToolbarSize { compact, standard, large }

enum AacVocabLevel { basic, intermediate }

class AacAccessSettings {
  const AacAccessSettings({
    this.vocabLevel = AacVocabLevel.intermediate,
    this.gridSize = AacGridSize.standard,
    this.spacing = AacSpacing.normal,
    this.toolbarSize = AacToolbarSize.standard,
    this.holdDurationSeconds = 0,
    this.selectOnRelease = false,
  });

  static const holdDurationOptions = <double>[0, 0.25, 0.5, 1.0, 1.5];

  final AacVocabLevel vocabLevel;
  final AacGridSize gridSize;
  final AacSpacing spacing;
  final AacToolbarSize toolbarSize;
  final double holdDurationSeconds;
  final bool selectOnRelease;

  static const defaults = AacAccessSettings();

  int get columns {
    switch (gridSize) {
      case AacGridSize.large:
        return 2;
      case AacGridSize.standard:
        return 3;
      case AacGridSize.compact:
        return 4;
    }
  }

  int get rows {
    switch (gridSize) {
      case AacGridSize.large:
        return 3;
      case AacGridSize.standard:
        return 3;
      case AacGridSize.compact:
        return 4;
    }
  }

  int get buttonsPerPage => columns * rows;

  int contentSlots(int pinnedCount) =>
      (buttonsPerPage - pinnedCount).clamp(1, buttonsPerPage);

  int gridColumns(int itemCount) {
    if (itemCount <= 0) return columns;
    if (itemCount < columns) return itemCount;
    return columns;
  }

  int gridRows(int itemCount) {
    final cols = gridColumns(itemCount);
    return (itemCount / cols).ceil().clamp(1, rows);
  }

  double get gap {
    switch (spacing) {
      case AacSpacing.tight:
        return 6;
      case AacSpacing.normal:
        return 10;
      case AacSpacing.wide:
        return 18;
    }
  }

  double get padding {
    switch (spacing) {
      case AacSpacing.tight:
        return 8;
      case AacSpacing.normal:
        return 12;
      case AacSpacing.wide:
        return 16;
    }
  }

  double get toolbarHeight {
    switch (toolbarSize) {
      case AacToolbarSize.compact:
        return 48;
      case AacToolbarSize.standard:
        return 56;
      case AacToolbarSize.large:
        return 80;
    }
  }

  double get toolbarTitleSize {
    switch (toolbarSize) {
      case AacToolbarSize.compact:
        return 18;
      case AacToolbarSize.standard:
        return 20;
      case AacToolbarSize.large:
        return 26;
    }
  }

  double get toolbarIconSize {
    switch (toolbarSize) {
      case AacToolbarSize.compact:
        return 22;
      case AacToolbarSize.standard:
        return 26;
      case AacToolbarSize.large:
        return 34;
    }
  }

  double get tileIconSize {
    switch (gridSize) {
      case AacGridSize.large:
        return 44;
      case AacGridSize.standard:
        return 36;
      case AacGridSize.compact:
        return 28;
    }
  }

  double get tileFontSize {
    switch (gridSize) {
      case AacGridSize.large:
        return 16;
      case AacGridSize.standard:
        return 14;
      case AacGridSize.compact:
        return 12;
    }
  }

  double get coreRowHeight {
    switch (gridSize) {
      case AacGridSize.large:
        return 108;
      case AacGridSize.standard:
        return 92;
      case AacGridSize.compact:
        return 80;
    }
  }

  double get pageControlSize {
    switch (toolbarSize) {
      case AacToolbarSize.compact:
        return 40;
      case AacToolbarSize.standard:
        return 48;
      case AacToolbarSize.large:
        return 60;
    }
  }

  AacAccessSettings copyWith({
    AacVocabLevel? vocabLevel,
    AacGridSize? gridSize,
    AacSpacing? spacing,
    AacToolbarSize? toolbarSize,
    double? holdDurationSeconds,
    bool? selectOnRelease,
  }) {
    return AacAccessSettings(
      vocabLevel: vocabLevel ?? this.vocabLevel,
      gridSize: gridSize ?? this.gridSize,
      spacing: spacing ?? this.spacing,
      toolbarSize: toolbarSize ?? this.toolbarSize,
      holdDurationSeconds: holdDurationSeconds ?? this.holdDurationSeconds,
      selectOnRelease: selectOnRelease ?? this.selectOnRelease,
    );
  }

  static AacAccessSettings fromPrefs(SharedPreferences prefs) {
    T readEnum<T extends Enum>(List<T> values, String key, T fallback) {
      final name = prefs.getString(key);
      return values.cast<T?>().firstWhere(
            (value) => value?.name == name,
            orElse: () => fallback,
          ) ??
          fallback;
    }

    return AacAccessSettings(
      vocabLevel: readEnum(
        AacVocabLevel.values,
        'aac_vocab_level',
        AacVocabLevel.intermediate,
      ),
      gridSize: readEnum(AacGridSize.values, 'aac_grid_size', AacGridSize.standard),
      spacing: readEnum(AacSpacing.values, 'aac_spacing', AacSpacing.normal),
      toolbarSize: readEnum(
        AacToolbarSize.values,
        'aac_toolbar_size',
        AacToolbarSize.standard,
      ),
      holdDurationSeconds: prefs.getDouble('aac_hold_duration') ?? 0,
      selectOnRelease: prefs.getBool('aac_select_on_release') ?? false,
    );
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setString('aac_vocab_level', vocabLevel.name);
    await prefs.setString('aac_grid_size', gridSize.name);
    await prefs.setString('aac_spacing', spacing.name);
    await prefs.setString('aac_toolbar_size', toolbarSize.name);
    await prefs.setDouble('aac_hold_duration', holdDurationSeconds);
    await prefs.setBool('aac_select_on_release', selectOnRelease);
  }
}

class AacAccessController extends ChangeNotifier {
  AacAccessController._() {
    load();
  }

  static final AacAccessController instance = AacAccessController._();

  AacAccessSettings settings = AacAccessSettings.defaults;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    settings = AacAccessSettings.fromPrefs(prefs);
    notifyListeners();
  }

  Future<void> update({
    AacVocabLevel? vocabLevel,
    AacGridSize? gridSize,
    AacSpacing? spacing,
    AacToolbarSize? toolbarSize,
    double? holdDurationSeconds,
    bool? selectOnRelease,
  }) async {
    settings = settings.copyWith(
      vocabLevel: vocabLevel,
      gridSize: gridSize,
      spacing: spacing,
      toolbarSize: toolbarSize,
      holdDurationSeconds: holdDurationSeconds,
      selectOnRelease: selectOnRelease,
    );
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await settings.save(prefs);
  }
}
