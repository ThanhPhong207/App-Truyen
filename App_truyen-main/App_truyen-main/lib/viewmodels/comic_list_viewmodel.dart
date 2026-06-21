// lib/viewmodels/comic_list_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/comic.dart';
import '../services/api_service.dart';

class ComicListViewModel with ChangeNotifier {
  List<Comic> _comics = [];
  List<Comic> _filteredComics = [];
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  List<Comic> get comics => _filteredComics;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final Set<String> allCats = {'Tất cả'};
    for (var comic in _comics) {
      if (comic.category.isNotEmpty) {
        String cat = comic.category.trim();
        // Chuẩn hóa chữ hoa chữ thường cho đồng bộ
        if (cat.toLowerCase() == 'hành động') {
          cat = 'Hành động';
        } else if (cat.toLowerCase() == 'phiêu lưu') {
          cat = 'Phiêu lưu';
        } else if (cat.toLowerCase() == 'kinh dị') {
          cat = 'Kinh dị';
        } else {
          cat = cat[0].toUpperCase() + cat.substring(1).toLowerCase();
        }
        allCats.add(cat);
      }
    }
    return allCats.toList();
  }

  ComicListViewModel() {
    fetchComics();
  }

  Future<void> fetchComics() async {
    _comics = await ApiService.getComics();
    _applyFilter();
  }

  void searchComics(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
  }

  void _applyFilter() {
    List<Comic> temp = _comics;

    // Lọc theo thể loại
    if (_selectedCategory != 'Tất cả') {
      temp = temp.where((comic) => comic.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase()).toList();
    }

    // Lọc theo tìm kiếm
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((comic) => comic.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    _filteredComics = temp;
    notifyListeners();
  }

  Future<void> toggleFavorite(Comic comic) async {
    try {
      await ApiService.toggleFavorite(comic.id, !comic.isFavorite);
      await fetchComics(); // Load lại danh sách truyện có trạng thái mới
    } catch (e) {
      print('toggleFavorite error in viewmodel: $e');
    }
  }
}