// lib/viewmodels/favorite_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/comic.dart';
import '../services/api_service.dart';

class FavoriteViewModel with ChangeNotifier {
  List<Comic> _favoriteComics = [];

  List<Comic> get favoriteComics => _favoriteComics;

  FavoriteViewModel() {
    fetchFavoriteComics();
  }

  Future<void> fetchFavoriteComics() async {
    _favoriteComics = await ApiService.getFavoriteComics();
    notifyListeners();
  }

  Future<void> toggleFavorite(Comic comic) async {
    try {
      await ApiService.toggleFavorite(comic.id, !comic.isFavorite);
      await fetchFavoriteComics();
    } catch (e) {
      print('toggleFavorite error in FavoriteViewModel: $e');
    }
  }
}