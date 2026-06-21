import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comic.dart';
import '../viewmodels/comic_list_viewmodel.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../services/api_service.dart';

class ComicTile extends StatelessWidget {
  final Comic comic;
  final VoidCallback onTap;

  const ComicTile({required this.comic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate 800
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: comic.thumbnailPath.startsWith('/uploads') || comic.thumbnailPath.startsWith('http')
                  ? Image.network(
                      comic.thumbnailPath.startsWith('http')
                          ? comic.thumbnailPath
                          : '${ApiService.baseStorageUrl}${comic.thumbnailPath}',
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 55,
                        height: 55,
                        color: const Color(0xFF334155),
                        child: const Icon(Icons.book, color: Colors.white60),
                      ),
                    )
                  : Image.file(
                      File(comic.thumbnailPath),
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 55,
                        height: 55,
                        color: const Color(0xFF334155),
                        child: const Icon(Icons.book, color: Colors.white60),
                      ),
                    ),
            ),
            title: Text(
              comic.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  comic.category,
                  style: const TextStyle(color: Colors.indigoAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            trailing: Consumer2<ComicListViewModel, FavoriteViewModel>(
              builder: (context, comicListVM, favoriteVM, child) {
                return IconButton(
                  icon: Icon(
                    comic.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: comic.isFavorite ? Colors.redAccent : Colors.white38,
                  ),
                  onPressed: () async {
                    await comicListVM.toggleFavorite(comic);
                    await favoriteVM.fetchFavoriteComics();
                  },
                );
              },
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}