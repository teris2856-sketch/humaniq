part of 'communicate.dart';

class AacWordCategory {
  const AacWordCategory({
    required this.id,
    required this.label,
    required this.group,
    required this.icon,
    required this.color,
    this.tileColor,
    this.inBasic = false,
    this.inIntermediate = true,
  });

  final String id;
  final String label;
  final String group;
  final IconData icon;
  final Color color;
  final Color? tileColor;
  final bool inBasic;
  final bool inIntermediate;

  Color get background =>
      tileColor ?? Color.alphaBlend(color.withValues(alpha: 0.16), Colors.white);

  static const home = AacWordCategory(
    id: 'Home',
    label: 'Home',
    group: 'Board',
    icon: Icons.home,
    color: Colors.blueAccent,
    tileColor: Color(0xFFE3F2FD),
    inBasic: true,
  );

  static const myWords = AacWordCategory(
    id: 'My words',
    label: 'My words',
    group: 'Board',
    icon: Icons.star,
    color: Colors.deepPurple,
    tileColor: Color(0xFFF3E5F5),
    inBasic: true,
  );

  static const all = <AacWordCategory>[
    home,
    myWords,
    AacWordCategory(
      id: 'Requests',
      label: 'Requests',
      group: 'Board',
      icon: Icons.front_hand,
      color: Colors.amber,
      tileColor: Color(0xFFFFF8E1),
      inBasic: true,
      inIntermediate: false,
    ),
    AacWordCategory(
      id: 'Choices / responses',
      label: 'Choices / responses',
      group: 'Board',
      icon: Icons.thumbs_up_down,
      color: Colors.green,
      tileColor: Color(0xFFE8F5E9),
      inBasic: true,
      inIntermediate: false,
    ),
    AacWordCategory(
      id: 'Actions',
      label: 'Actions',
      group: 'Board',
      icon: Icons.directions_run,
      color: Colors.green,
      tileColor: Color(0xFFE8F5E9),
      inBasic: true,
      inIntermediate: false,
    ),
    AacWordCategory(
      id: 'People / social',
      label: 'People / social',
      group: 'Board',
      icon: Icons.groups,
      color: Colors.pink,
      tileColor: Color(0xFFFCE4EC),
      inBasic: true,
      inIntermediate: false,
    ),
    AacWordCategory(
      id: 'Needs / feelings',
      label: 'Needs / feelings',
      group: 'Board',
      icon: Icons.favorite,
      color: Colors.orange,
      tileColor: Color(0xFFFFF3E0),
      inBasic: true,
      inIntermediate: false,
    ),
    AacWordCategory(
      id: 'Sentence starters',
      label: 'Sentence starters',
      group: 'Board',
      icon: Icons.format_quote,
      color: Colors.indigo,
      tileColor: Color(0xFFE8EAF6),
      inBasic: true,
      inIntermediate: false,
    ),
    AacWordCategory(
      id: 'Topic words',
      label: 'Topic words',
      group: 'Board',
      icon: Icons.category,
      color: Colors.deepPurple,
      tileColor: Color(0xFFEDE7F6),
      inBasic: true,
      inIntermediate: false,
    ),
    AacWordCategory(
      id: 'Feelings',
      label: 'Feelings',
      group: 'Board',
      icon: Icons.emoji_emotions,
      color: Colors.purple,
      tileColor: Color(0xFFF3E5F5),
    ),
    AacWordCategory(
      id: 'Comfort',
      label: 'Comfort',
      group: 'Board',
      icon: Icons.thermostat,
      color: Colors.teal,
      tileColor: Color(0xFFE0F2F1),
    ),
    AacWordCategory(
      id: 'Questions',
      label: 'Questions',
      group: 'Board',
      icon: Icons.question_mark,
      color: Colors.indigo,
      tileColor: Color(0xFFE8EAF6),
    ),
    AacWordCategory(
      id: 'Needs',
      label: 'Needs',
      group: 'Board',
      icon: Icons.room_service,
      color: Colors.orange,
      tileColor: Color(0xFFFFF3E0),
    ),
    AacWordCategory(
      id: 'Pain',
      label: 'Pain',
      group: 'Board',
      icon: Icons.healing,
      color: Colors.deepOrange,
      tileColor: Color(0xFFFBE9E7),
    ),
    AacWordCategory(
      id: 'People',
      label: 'People',
      group: 'Board',
      icon: Icons.groups,
      color: Colors.pink,
      tileColor: Color(0xFFFCE4EC),
    ),
    AacWordCategory(
      id: 'Symptoms',
      label: 'Symptoms',
      group: 'Board',
      icon: Icons.sick,
      color: Colors.green,
      tileColor: Color(0xFFE8F5E9),
    ),
    AacWordCategory(
      id: 'Care',
      label: 'Care',
      group: 'Board',
      icon: Icons.soap,
      color: Colors.teal,
      tileColor: Color(0xFFE0F7FA),
    ),
    AacWordCategory(
      id: 'Core',
      label: 'Core',
      group: 'Board',
      icon: Icons.grid_view,
      color: Colors.indigo,
      tileColor: Color(0xFFE8EAF6),
    ),
    AacWordCategory(
      id: 'Topics',
      label: 'Topics',
      group: 'Board',
      icon: Icons.category,
      color: Colors.deepPurple,
      tileColor: Color(0xFFEDE7F6),
    ),
    AacWordCategory(
      id: 'Core › People words',
      label: 'People words',
      group: 'Core',
      icon: Icons.person,
      color: Colors.blue,
      tileColor: Color(0xFFE3F2FD),
    ),
    AacWordCategory(
      id: 'Core › Verbs',
      label: 'Verbs',
      group: 'Core',
      icon: Icons.directions_run,
      color: Colors.green,
      tileColor: Color(0xFFE8F5E9),
    ),
    AacWordCategory(
      id: 'Core › Describe',
      label: 'Describe',
      group: 'Core',
      icon: Icons.tune,
      color: Colors.orange,
      tileColor: Color(0xFFFFF3E0),
    ),
    AacWordCategory(
      id: 'Core › Ask',
      label: 'Ask',
      group: 'Core',
      icon: Icons.help_outline,
      color: Colors.indigo,
      tileColor: Color(0xFFE8EAF6),
    ),
    AacWordCategory(
      id: 'Core › Location',
      label: 'Location',
      group: 'Core',
      icon: Icons.place,
      color: Colors.teal,
      tileColor: Color(0xFFE0F2F1),
    ),
    AacWordCategory(
      id: 'Core › Time',
      label: 'Time',
      group: 'Core',
      icon: Icons.schedule,
      color: Colors.purple,
      tileColor: Color(0xFFF3E5F5),
    ),
    AacWordCategory(
      id: 'Core › Social',
      label: 'Social',
      group: 'Core',
      icon: Icons.handshake,
      color: Colors.pink,
      tileColor: Color(0xFFFCE4EC),
    ),
    AacWordCategory(
      id: 'Core › Grammar',
      label: 'Grammar',
      group: 'Core',
      icon: Icons.text_fields,
      color: Colors.blueGrey,
      tileColor: Color(0xFFECEFF1),
    ),
    AacWordCategory(
      id: 'Core › Helpers',
      label: 'Helpers',
      group: 'Core',
      icon: Icons.extension,
      color: Colors.blueGrey,
      tileColor: Color(0xFFECEFF1),
    ),
    AacWordCategory(
      id: 'Topics › Food',
      label: 'Food',
      group: 'Topics',
      icon: Icons.restaurant,
      color: Colors.orange,
      tileColor: Color(0xFFFFF3E0),
    ),
    AacWordCategory(
      id: 'Topics › Places',
      label: 'Places',
      group: 'Topics',
      icon: Icons.place,
      color: Colors.teal,
      tileColor: Color(0xFFE0F2F1),
    ),
    AacWordCategory(
      id: 'Topics › Things',
      label: 'Things',
      group: 'Topics',
      icon: Icons.widgets,
      color: Colors.brown,
      tileColor: Color(0xFFEFEBE9),
    ),
    AacWordCategory(
      id: 'Topics › People',
      label: 'People',
      group: 'Topics',
      icon: Icons.groups,
      color: Colors.pink,
      tileColor: Color(0xFFFCE4EC),
    ),
    AacWordCategory(
      id: 'Topics › Time',
      label: 'Time',
      group: 'Topics',
      icon: Icons.calendar_month,
      color: Colors.purple,
      tileColor: Color(0xFFF3E5F5),
    ),
    AacWordCategory(
      id: 'Topics › Leisure',
      label: 'Leisure',
      group: 'Topics',
      icon: Icons.sports_esports,
      color: Colors.deepPurple,
      tileColor: Color(0xFFEDE7F6),
    ),
    AacWordCategory(
      id: 'Topics › Phrases',
      label: 'Phrases',
      group: 'Topics',
      icon: Icons.chat_bubble,
      color: Colors.indigo,
      tileColor: Color(0xFFE8EAF6),
    ),
    AacWordCategory(
      id: 'Topics › Religion',
      label: 'Religion',
      group: 'Topics',
      icon: Icons.church,
      color: Colors.purple,
      tileColor: Color(0xFFF3E5F5),
    ),
    AacWordCategory(
      id: 'Topics › School',
      label: 'School',
      group: 'Topics',
      icon: Icons.school,
      color: Colors.blue,
      tileColor: Color(0xFFE3F2FD),
    ),
    AacWordCategory(
      id: 'Topics › Sport',
      label: 'Sport',
      group: 'Topics',
      icon: Icons.sports_soccer,
      color: Colors.green,
      tileColor: Color(0xFFE8F5E9),
    ),
    AacWordCategory(
      id: 'Topics › Adjectives',
      label: 'Adjectives',
      group: 'Topics',
      icon: Icons.palette,
      color: Colors.orange,
      tileColor: Color(0xFFFFF3E0),
    ),
    AacWordCategory(
      id: 'Topics › Action verbs',
      label: 'Action verbs',
      group: 'Topics',
      icon: Icons.directions_run,
      color: Colors.green,
      tileColor: Color(0xFFE8F5E9),
    ),
    AacWordCategory(
      id: 'Topics › Create',
      label: 'Create',
      group: 'Topics',
      icon: Icons.brush,
      color: Colors.pink,
      tileColor: Color(0xFFFCE4EC),
    ),
    AacWordCategory(
      id: 'Topics › Daily life',
      label: 'Daily life',
      group: 'Topics',
      icon: Icons.home,
      color: Colors.teal,
      tileColor: Color(0xFFE0F2F1),
    ),
    AacWordCategory(
      id: "Topics › Let's talk",
      label: "Let's talk",
      group: 'Topics',
      icon: Icons.forum,
      color: Colors.indigo,
      tileColor: Color(0xFFE8EAF6),
    ),
    AacWordCategory(
      id: 'Topics › Motor play',
      label: 'Motor play',
      group: 'Topics',
      icon: Icons.sports_handball,
      color: Colors.deepOrange,
      tileColor: Color(0xFFFBE9E7),
    ),
    AacWordCategory(
      id: 'Topics › Out & about',
      label: 'Out & about',
      group: 'Topics',
      icon: Icons.explore,
      color: Colors.blue,
      tileColor: Color(0xFFE3F2FD),
    ),
    AacWordCategory(
      id: 'Topics › Reading',
      label: 'Reading',
      group: 'Topics',
      icon: Icons.menu_book,
      color: Colors.brown,
      tileColor: Color(0xFFEFEBE9),
    ),
    AacWordCategory(
      id: 'Topics › Toys & games',
      label: 'Toys & games',
      group: 'Topics',
      icon: Icons.toys,
      color: Colors.amber,
      tileColor: Color(0xFFFFF8E1),
    ),
  ];

  static const groups = ['Board', 'Core', 'Topics'];

  static List<AacWordCategory> get visible {
    final basic = AacAccessController.instance.settings.vocabLevel ==
        AacVocabLevel.basic;
    return all
        .where((category) => basic ? category.inBasic : category.inIntermediate)
        .toList();
  }

  static List<String> get visibleGroups {
    return groups
        .where((group) => visible.any((category) => category.group == group))
        .toList();
  }

  static AacWordCategory byId(String id) {
    for (final category in all) {
      if (category.id == id) return category;
    }
    return myWords;
  }

  static List<AacWordCategory> inGroup(String group) {
    return visible.where((category) => category.group == group).toList();
  }
}

class AacCustomWord {
  const AacCustomWord({
    required this.id,
    required this.label,
    required this.speak,
    required this.iconCodePoint,
    required this.categoryId,
  });

  final String id;
  final String label;
  final String speak;
  final int iconCodePoint;
  final String categoryId;

  AacWordCategory get category => AacWordCategory.byId(categoryId);

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get color => category.color;

  AacItem toItem() {
    return AacItem(
      label: label,
      speak: speak,
      icon: icon,
      color: color,
      tileColor: category.background,
      customId: id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'speak': speak,
      'icon': iconCodePoint,
      'categoryId': categoryId,
    };
  }

  factory AacCustomWord.fromJson(Map<String, dynamic> json) {
    return AacCustomWord(
      id: json['id'] as String,
      label: json['label'] as String,
      speak: (json['speak'] as String?)?.trim().isNotEmpty == true
          ? json['speak'] as String
          : json['label'] as String,
      iconCodePoint: json['icon'] as int? ?? Icons.chat_bubble.codePoint,
      categoryId: json['categoryId'] as String? ?? AacWordCategory.myWords.id,
    );
  }
}

class AacCustomWordsController extends ChangeNotifier {
  AacCustomWordsController._() {
    load();
  }

  static final AacCustomWordsController instance = AacCustomWordsController._();

  static const _prefsKey = 'aac_custom_words';

  static const iconChoices = <IconData>[
    Icons.chat_bubble,
    Icons.star,
    Icons.favorite,
    Icons.person,
    Icons.home,
    Icons.pets,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.sports_soccer,
    Icons.music_note,
    Icons.school,
    Icons.work,
    Icons.directions_car,
    Icons.phone,
    Icons.tv,
    Icons.hotel,
    Icons.park,
    Icons.medical_services,
    Icons.medication,
    Icons.wc,
    Icons.water_drop,
    Icons.menu_book,
    Icons.toys,
    Icons.church,
    Icons.shopping_cart,
    Icons.beach_access,
    Icons.nightlight,
    Icons.sentiment_satisfied,
    Icons.family_restroom,
    Icons.volunteer_activism,
  ];

  List<AacCustomWord> words = [];

  List<AacItem> get asItems => words.map((word) => word.toItem()).toList();

  List<AacItem> itemsIn(String categoryId) {
    return words
        .where((word) => word.categoryId == categoryId)
        .map((word) => word.toItem())
        .toList();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      words = [];
      notifyListeners();
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      words = decoded
          .whereType<Map>()
          .map((item) => AacCustomWord.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      words = [];
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
      jsonEncode(words.map((word) => word.toJson()).toList()),
    );
  }

  Future<void> add({
    required String label,
    String? speak,
    required IconData icon,
    required String categoryId,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final spoken = (speak ?? '').trim();
    words = [
      ...words,
      AacCustomWord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: trimmed,
        speak: spoken.isEmpty ? trimmed : spoken,
        iconCodePoint: icon.codePoint,
        categoryId: categoryId,
      ),
    ];
    await _save();
  }

  Future<void> remove(String id) async {
    words = words.where((word) => word.id != id).toList();
    await _save();
  }
}
