// lib/viewmodels/comic_detail_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';

class ComicDetailViewModel with ChangeNotifier {
  List<Chapter> _chapters = [];
  bool _isLoading = false;

  List<Chapter> get chapters => _chapters;
  bool get isLoading => _isLoading;

  Future<void> fetchChapters(int comicId) async {
    _isLoading = true;
    notifyListeners();

    _chapters = await ApiService.getChapters(comicId);
    _isLoading = false;
    notifyListeners();
  }
}