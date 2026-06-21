// lib/viewmodels/pdf_viewer_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class PDFViewerViewModel with ChangeNotifier {
  String? _chapterPath;
  String? _chapterTitle;
  bool _isLoading = false;

  String? get chapterPath => _chapterPath;
  String? get chapterTitle => _chapterTitle;
  bool get isLoading => _isLoading;

  Future<void> loadChapter(String path, String title) async {
    _isLoading = true;
    _chapterPath = null;
    _chapterTitle = title;
    notifyListeners();

    try {
      if (path.startsWith('/uploads') || path.startsWith('http')) {
        final localPath = await ApiService.getLocalPdfPath(path);
        _chapterPath = localPath;
      } else {
        _chapterPath = path;
      }
    } catch (e) {
      print('Error loading/downloading chapter PDF: $e');
      _chapterPath = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
