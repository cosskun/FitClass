import 'dart:convert';

class ProgressPhoto {
  final String id;
  final DateTime date;
  final String imagePath;
  final String note;

  ProgressPhoto({
    required this.id,
    required this.date,
    required this.imagePath,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
      'note': note,
    };
  }

  factory ProgressPhoto.fromMap(Map<String, dynamic> map) {
    return ProgressPhoto(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      imagePath: map['imagePath'] as String,
      note: map['note'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory ProgressPhoto.fromJson(String source) => ProgressPhoto.fromMap(json.decode(source));
}
