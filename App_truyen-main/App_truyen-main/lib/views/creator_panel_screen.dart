import 'dart:io';
import 'package:flutter/material.dart';
import '../models/comic.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import 'creator_upload_comic_screen.dart';
import 'creator_add_chapter_screen.dart';

class CreatorPanelScreen extends StatefulWidget {
  const CreatorPanelScreen({Key? key}) : super(key: key);

  @override
  State<CreatorPanelScreen> createState() => _CreatorPanelScreenState();
}

class _CreatorPanelScreenState extends State<CreatorPanelScreen> {
  List<Comic> _myComics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyComics();
  }

  Future<void> _fetchMyComics() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await ApiService.getMyComics();
      setState(() {
        _myComics = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải truyện: $e')),
      );
    }
  }

  void _showChaptersBottomSheet(Comic comic) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return FutureBuilder<List<Chapter>>(
                  future: ApiService.getChapters(comic.id),
                  builder: (context, snapshot) {
                    final chapters = snapshot.data ?? [];
                    final loading = snapshot.connectionState == ConnectionState.waiting;

                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  comic.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context); // Close bottom sheet
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreatorAddChapterScreen(comic: comic),
                                ),
                              );
                              if (result == true) {
                                _fetchMyComics();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm chương mới (PDF)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Danh sách chương đã đăng:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: loading
                                ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                                : chapters.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Chưa có chương nào được đăng.',
                                          style: TextStyle(color: Colors.white30),
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: scrollController,
                                        itemCount: chapters.length,
                                        itemBuilder: (context, index) {
                                          final ch = chapters[index];
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0F172A),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              leading: const Icon(Icons.menu_book, color: Colors.indigoAccent),
                                              title: Text(
                                                'Chương ${ch.chapterNumber}',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                ch.chapterPath,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.white30, fontSize: 12),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Truyện Của Tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMyComics,
        color: Colors.indigoAccent,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
            : _myComics.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_stories_outlined, size: 80, color: Colors.white24),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa đăng bộ truyện nào.',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreatorUploadComicScreen()),
                            );
                            if (result == true) {
                              _fetchMyComics();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Đăng truyện ngay'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _myComics.length,
                    itemBuilder: (context, index) {
                      final comic = _myComics[index];
                      return GestureDetector(
                        onTap: () => _showChaptersBottomSheet(comic),
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
                                  child: comic.thumbnailPath.startsWith('/uploads') || comic.thumbnailPath.startsWith('http')
                                      ? Image.network(
                                          comic.thumbnailPath.startsWith('http')
                                              ? comic.thumbnailPath
                                              : '${ApiService.baseStorageUrl}${comic.thumbnailPath}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: const Color(0xFF334155),
                                            child: const Icon(Icons.book, size: 40, color: Colors.white30),
                                          ),
                                        )
                                      : Image.file(
                                          File(comic.thumbnailPath),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: const Color(0xFF334155),
                                            child: const Icon(Icons.book, size: 40, color: Colors.white30),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comic.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comic.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.indigoAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatorUploadComicScreen()),
          );
          if (result == true) {
            _fetchMyComics();
          }
        },
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
