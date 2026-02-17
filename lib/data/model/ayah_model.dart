class Ayah {
  final int number;
  final String text;

  Ayah({required this.number, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(number: json['number'] as int, text: json['text'] as String);
  }
}
