// lib/models/comic.dart
class Comic {
  final int id;
  final String title;
  final String thumbnailPath;
  final String category;
  final bool isFavorite;

  Comic({
    required this.id,
    required this.title,
    required this.thumbnailPath,
    required this.category,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnailPath': thumbnailPath,
      'category': category,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Comic.fromMap(Map<String, dynamic> map) {
    return Comic(
      id: map['id'],
      title: map['title'],
      thumbnailPath: map['thumbnailPath'],
      category: map['category'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}