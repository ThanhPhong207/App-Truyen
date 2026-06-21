import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/comic_list_viewmodel.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../widgets/comic_tile.dart';
import 'comic_detail_screen.dart';
import '../services/api_service.dart';

class MainScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ComicListViewModel, FavoriteViewModel>(
      builder: (context, comicListViewModel, favoriteViewModel, child) {
        // Lấy danh sách truyện nổi bật (ví dụ 4 truyện đầu tiên)
        final featuredComics = comicListViewModel.comics.take(4).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A), // Slate 900
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            title: const Text(
              'Thư Viện',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0F172A),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm truyện...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: Colors.indigoAccent),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: (value) => comicListViewModel.searchComics(value),
                      ),
                    ),
                  ),

                  // Category Chips (Horizontal Scrollable)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: comicListViewModel.categories.length,
                        itemBuilder: (context, index) {
                          final category = comicListViewModel.categories[index];
                          final isSelected = comicListViewModel.selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => comicListViewModel.selectCategory(category),
                              selectedColor: Colors.indigoAccent,
                              backgroundColor: const Color(0xFF1E293B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? Colors.indigoAccent : Colors.white.withOpacity(0.06),
                                ),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Featured Slider / Hot Section
                  if (featuredComics.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        'Truyện Nổi Bật',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: featuredComics.length,
                        itemBuilder: (context, index) {
                          final comic = featuredComics[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComicDetailScreen(comic: comic),
                                ),
                              ),
                              child: Container(
                                width: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      // Image
                                      Positioned.fill(
                                        child: comic.thumbnailPath.startsWith('/uploads') || comic.thumbnailPath.startsWith('http')
                                            ? Image.network(
                                                comic.thumbnailPath.startsWith('http')
                                                    ? comic.thumbnailPath
                                                    : '${ApiService.baseStorageUrl}${comic.thumbnailPath}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: const Color(0xFF1E293B),
                                                  child: const Icon(Icons.book, size: 50, color: Colors.white30),
                                                ),
                                              )
                                            : Image.file(
                                                File(comic.thumbnailPath),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: const Color(0xFF1E293B),
                                                  child: const Icon(Icons.book, size: 50, color: Colors.white30),
                                                ),
                                              ),
                                      ),
                                      // Gradient Overlay
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.85),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Title & Category Badge
                                      Positioned(
                                        left: 16,
                                        bottom: 16,
                                        right: 16,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.indigoAccent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                comic.category,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              comic.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Favorite Section
                  if (favoriteViewModel.favoriteComics.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Text(
                        'Truyện Yêu Thích',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      height: 165,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: favoriteViewModel.favoriteComics.length,
                        itemBuilder: (context, index) {
                          final comic = favoriteViewModel.favoriteComics[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComicDetailScreen(comic: comic),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: comic.thumbnailPath.startsWith('/uploads') || comic.thumbnailPath.startsWith('http')
                                        ? Image.network(
                                            comic.thumbnailPath.startsWith('http')
                                                ? comic.thumbnailPath
                                                : '${ApiService.baseStorageUrl}${comic.thumbnailPath}',
                                            width: 100,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 100,
                                              height: 110,
                                              color: const Color(0xFF1E293B),
                                              child: const Icon(Icons.book, color: Colors.white30),
                                            ),
                                          )
                                        : Image.file(
                                            File(comic.thumbnailPath),
                                            width: 100,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 100,
                                              height: 110,
                                              color: const Color(0xFF1E293B),
                                              child: const Icon(Icons.book, color: Colors.white30),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 100,
                                    child: Text(
                                      comic.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Text(
                                    comic.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // All Comics Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      'Tất Cả Truyện',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Comics List
                  comicListViewModel.comics.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.library_books_outlined, size: 48, color: Colors.white.withOpacity(0.3)),
                                const SizedBox(height: 12),
                                Text(
                                  'Không tìm thấy truyện nào',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24.0),
                          itemCount: comicListViewModel.comics.length,
                          itemBuilder: (context, index) {
                            final comic = comicListViewModel.comics[index];
                            return ComicTile(
                              comic: comic,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComicDetailScreen(comic: comic),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}