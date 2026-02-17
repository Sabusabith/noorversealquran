class Surah {
  final int number;
  final String nameAr;
  final String nameEn;
  final String tName;
  final int numberOfAyahs;
  final String revelationType;
  final int rukus;
  final int order;

  Surah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.tName,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.rukus,
    required this.order,
  });

  factory Surah.fromJson(Map<String, dynamic> json, int number) {
    return Surah(
      number: number,
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      tName: json['tname'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
      rukus: json['rukus'],
      order: json['order'],
    );
  }
}
