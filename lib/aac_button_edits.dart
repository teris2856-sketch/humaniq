part of 'communicate.dart';

class AacButtonOverride {
  const AacButtonOverride({
    this.label,
    this.imagePath,
    this.audioPath,
  });

  final String? label;
  final String? imagePath;
  final String? audioPath;

  Map<String, dynamic> toJson() {
    return {
      if (label != null) 'label': label,
      if (imagePath != null) 'imagePath': imagePath,
      if (audioPath != null) 'audioPath': audioPath,
    };
  }

  factory AacButtonOverride.fromJson(Map<String, dynamic> json) {
    return AacButtonOverride(
      label: json['label'] as String?,
      imagePath: json['imagePath'] as String?,
      audioPath: json['audioPath'] as String?,
    );
  }
}

class AacButtonEditController extends ChangeNotifier {
  AacButtonEditController._() {
    load();
  }

  static final AacButtonEditController instance = AacButtonEditController._();

  static const _prefsKey = 'aac_button_edits';

  bool editing = false;
  Map<String, AacButtonOverride> overrides = {};

  void toggleEditing() {
    editing = !editing;
    notifyListeners();
  }

  void stopEditing() {
    if (!editing) return;
    editing = false;
    notifyListeners();
  }

  static bool isCoreWord(AacItem item, String categoryId) {
    if (item.isAddWord) return false;
    if (item.identity == 'Core' || item.originalLabel == 'Core') return true;
    return categoryId == 'Core' || categoryId.startsWith('Core ›');
  }

  String keyFor(AacItem item, String categoryId) {
    if (item.customId != null && item.customId != AacVocabulary.addWordId) {
      return 'custom:${item.customId}';
    }
    final original = item.originalLabel ?? item.label;
    if (original == 'Yes' || original == 'No' || original == 'Emergency') {
      return 'global|$original';
    }
    return '$categoryId|$original';
  }

  AacItem apply(AacItem item, String categoryId) {
    if (item.isAddWord) return item;
    final override = overrides[keyFor(item, categoryId)];
    if (override == null) return item;
    final lockName = isCoreWord(item, categoryId);
    return item.copyWith(
      label: lockName
          ? (item.originalLabel ?? item.label)
          : (override.label ?? item.label),
      originalLabel: item.originalLabel ?? item.label,
      imagePath: override.imagePath,
      audioPath: override.audioPath,
    );
  }

  List<AacItem> applyAll(List<AacItem> items, String categoryId) {
    return items.map((item) => apply(item, categoryId)).toList();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      overrides = {};
      notifyListeners();
      return;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      overrides = decoded.map(
        (key, value) => MapEntry(
          key,
          AacButtonOverride.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      );
    } catch (_) {
      overrides = {};
    }
    AacVocabulary.invalidateSearch();
    notifyListeners();
  }

  Future<void> _save() async {
    AacVocabulary.invalidateSearch();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(
        overrides.map((key, value) => MapEntry(key, value.toJson())),
      ),
    );
  }

  Future<void> update(
    AacItem item,
    String categoryId, {
    String? label,
    String? imagePath,
    String? audioPath,
    bool clearImage = false,
    bool clearAudio = false,
  }) async {
    final key = keyFor(item, categoryId);
    final current = overrides[key];
    final lockName = isCoreWord(item, categoryId);
    final nextLabel = lockName
        ? null
        : (label ?? current?.label)?.trim();
    final nextImage = clearImage ? null : (imagePath ?? current?.imagePath);
    final nextAudio = clearAudio ? null : (audioPath ?? current?.audioPath);
    if ((nextLabel == null || nextLabel.isEmpty || nextLabel == item.identity) &&
        nextImage == null &&
        nextAudio == null) {
      overrides = Map<String, AacButtonOverride>.from(overrides)..remove(key);
    } else {
      overrides = {
        ...overrides,
        key: AacButtonOverride(
          label: nextLabel == item.identity ? null : nextLabel,
          imagePath: nextImage,
          audioPath: nextAudio,
        ),
      };
    }
    await _save();
  }

  Future<String?> savePickedPhoto(XFile picked, String key) async {
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory('${docs.path}/aac_button_photos');
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    final dest = File('${folder.path}/$safeKey.jpg');
    await File(picked.path).copy(dest.path);
    return dest.path;
  }

  static const _audioExtensions = {
    '.m4a',
    '.aac',
    '.mp3',
    '.wav',
    '.ogg',
    '.caf',
    '.flac',
  };

  Future<Directory> _soundFolder() async {
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory('${docs.path}/aac_button_sounds');
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  String _safeKey(String key) => key.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');

  String _audioExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '.m4a';
    final ext = path.substring(dot).toLowerCase();
    return _audioExtensions.contains(ext) ? ext : '.m4a';
  }

  Future<void> _clearOldSounds(Directory folder, String safeKey) async {
    for (final file in folder.listSync()) {
      if (file is! File) continue;
      final name = file.uri.pathSegments.last;
      if (name.startsWith('$safeKey.')) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  Future<String> createTempSoundPath({String extension = '.wav'}) async {
    final folder = await _soundFolder();
    final ext = _audioExtensions.contains(extension) ? extension : '.wav';
    return '${folder.path}/tmp_${DateTime.now().millisecondsSinceEpoch}$ext';
  }

  Future<String?> createSoundPath(String key, String extension) async {
    final folder = await _soundFolder();
    final safeKey = _safeKey(key);
    await _clearOldSounds(folder, safeKey);
    final ext = _audioExtensions.contains(extension) ? extension : '.m4a';
    return '${folder.path}/$safeKey$ext';
  }

  Future<String?> saveAudioFile(String sourcePath, String key) async {
    final source = File(sourcePath);
    if (!source.existsSync()) return null;
    final destPath = await createSoundPath(key, _audioExtension(sourcePath));
    if (destPath == null) return null;
    if (source.path == destPath) return destPath;
    await source.copy(destPath);
    return destPath;
  }
}
