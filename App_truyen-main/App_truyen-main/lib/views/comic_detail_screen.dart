// lib/views/comic_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comic.dart';
import '../viewmodels/comic_detail_viewmodel.dart';
import 'pdf_viewer_screen.dart';
import '../services/api_service.dart';

class ComicDetailScreen extends StatelessWidget {
  final Comic comic;

  const ComicDetailScreen({required this.comic});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ComicDetailViewModel>(context, listen: false);
    viewModel.fetchChapters(comic.id);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          comic.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comic Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF1E293B),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail cover card
                Container(
                  width: 110,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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
                ),
                const SizedBox(width: 20),
                // Comic Details Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comic.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigoAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          comic.category,
                          style: const TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Consumer<ComicDetailViewModel>(
                        builder: (context, viewModel, child) {
                          final hasChapters = viewModel.chapters.isNotEmpty;
                          return ElevatedButton.icon(
                            onPressed: hasChapters
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PDFViewerScreen(
                                          chapters: viewModel.chapters,
                                          currentIndex: 0,
                                          comic: comic,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('ĐỌC NGAY'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chapters Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: Text(
              'Danh sách chương',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Chapters list
          Expanded(
            child: Consumer<ComicDetailViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.indigoAccent));
                }
                if (viewModel.chapters.isEmpty) {
                  return Center(
                    child: Text(
                      'Hiện tại chưa có chương nào.',
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: viewModel.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = viewModel.chapters[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          'Chương ${chapter.chapterNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerScreen(
                                chapters: viewModel.chapters,
                                currentIndex: index,
                                comic: comic,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}