class AllahName {
  final int number;
  final String name;
  final String transliteration;
  final String meaning;

  AllahName({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.meaning,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      number: json['number'],
      name: json['name'],
      transliteration: json['transliteration'],
      meaning: json['en']['meaning'],
    );
  }
}
