// lib/models/chapter.dart
class Chapter {
  final int id;
  final int comicId;
  final int chapterNumber;
  final String chapterPath;

  Chapter({
    required this.id,
    required this.comicId,
    required this.chapterNumber,
    required this.chapterPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comicId': comicId,
      'chapterNumber': chapterNumber,
      'chapterPath': chapterPath,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      comicId: map['comicId'],
      chapterNumber: map['chapterNumber'],
      chapterPath: map['chapterPath'],
    );
  }
}