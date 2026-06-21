import 'dart:io';
import 'package:flutter/material.dart';
import '../models/comic.dart';
import '../services/api_service.dart';
import 'comic_detail_screen.dart';

class EndOfComicScreen extends StatefulWidget {
  final Comic comic;

  const EndOfComicScreen({Key? key, required this.comic}) : super(key: key);

  @override
  State<EndOfComicScreen> createState() => _EndOfComicScreenState();
}

class _EndOfComicScreenState extends State<EndOfComicScreen> {
  List<Comic> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final list = await ApiService.getComics(category: widget.comic.category);
      // Lọc bỏ truyện hiện tại khỏi danh sách gợi ý
      setState(() {
        _suggestions = list.where((item) => item.id != widget.comic.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hoàn thành',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Celebration/Thank you Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.indigoAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: Colors.indigoAccent,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'CẢM ƠN BẠN ĐÃ ĐỌC!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'Bạn đã đọc hết chương cuối cùng hiện có của bộ truyện "${widget.comic.title}".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Promise of future chapters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Text(
                'Truyện sẽ tiếp tục ra chương mới sớm nhất. Hãy thêm truyện vào mục Yêu thích để nhận thông báo ngay khi có chương mới nhé! 📚',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.indigoAccent,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Suggested Comics Header
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gợi ý cùng thể loại (${widget.comic.category})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Suggestion list
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                : _suggestions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Không có truyện gợi ý nào khác ở thể loại này.',
                          style: TextStyle(color: Colors.white30),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final sug = _suggestions[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComicDetailScreen(comic: sug),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: sug.thumbnailPath.startsWith('/uploads') || sug.thumbnailPath.startsWith('http')
                                          ? Image.network(
                                              sug.thumbnailPath.startsWith('http')
                                                  ? sug.thumbnailPath
                                                  : '${ApiService.baseStorageUrl}${sug.thumbnailPath}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: const Color(0xFF334155),
                                                child: const Icon(Icons.book, size: 40, color: Colors.white30),
                                              ),
                                            )
                                          : Image.file(
                                              File(sug.thumbnailPath),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: const Color(0xFF334155),
                                                child: const Icon(Icons.book, size: 40, color: Colors.white30),
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        sug.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
