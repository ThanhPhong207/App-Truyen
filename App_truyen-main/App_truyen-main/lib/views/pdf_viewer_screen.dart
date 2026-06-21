import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import '../models/chapter.dart';
import '../models/comic.dart';
import '../viewmodels/pdf_viewer_viewmodel.dart';
import 'end_of_comic_screen.dart';

class PDFViewerScreen extends StatefulWidget {
  final List<Chapter> chapters;
  final int currentIndex;
  final Comic comic;

  const PDFViewerScreen({
    Key? key,
    required this.chapters,
    required this.currentIndex,
    required this.comic,
  }) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late int currentIndex;
  Key pdfViewKey = UniqueKey(); // Key để rebuild PDFView
  int totalPages = 0;
  int currentPage = 0;
  bool isAtEnd = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChapter();
    });
  }

  void _loadChapter() {
    final chapter = widget.chapters[currentIndex];

    // Đổi key để buộc PDFView rebuild và reset trạng thái trang
    setState(() {
      pdfViewKey = UniqueKey();
      totalPages = 0;
      currentPage = 0;
      isAtEnd = false;
    });

    Provider.of<PDFViewerViewModel>(context, listen: false)
        .loadChapter(chapter.chapterPath, 'Chương ${chapter.chapterNumber}');
  }

  void _goToPreviousChapter() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _loadChapter();
    }
  }

  void _goToNextChapter() {
    if (currentIndex < widget.chapters.length - 1) {
      setState(() {
        currentIndex++;
      });
      _loadChapter();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EndOfComicScreen(comic: widget.comic),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PDFViewerViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  color: Colors.indigoAccent,
                  disabledColor: Colors.white24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: currentIndex > 0 ? _goToPreviousChapter : null,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Text(
                    viewModel.chapterTitle ?? 'Chương',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  color: Colors.indigoAccent,
                  disabledColor: Colors.white24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: currentIndex < widget.chapters.length - 1
                      ? _goToNextChapter
                      : null,
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: viewModel.isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.indigoAccent),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải PDF từ server...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : viewModel.chapterPath != null
                  ? Listener(
                      onPointerMove: (pointerMoveEvent) {
                        // pointerMoveEvent.delta.dy < 0 nghĩa là người dùng đang vuốt ngón tay lên (để cuộn tiếp xuống dưới)
                        if (isAtEnd && pointerMoveEvent.delta.dy < -15) {
                          _goToNextChapter();
                        }
                        // pointerMoveEvent.delta.dy > 0 nghĩa là người dùng đang vuốt ngón tay xuống (để cuộn ngược lên trên)
                        else if (currentPage == 0 && pointerMoveEvent.delta.dy > 15) {
                          _goToPreviousChapter();
                        }
                      },
                      child: PDFView(
                        key: pdfViewKey,
                        filePath: viewModel.chapterPath!,
                        swipeHorizontal: false, // Cuộn dọc (lướt lên xuống) thay vì lật ngang
                        pageSnap: false,        // Cuộn liên tục mượt mà, không bị gián đoạn từng trang
                        autoSpacing: true,      // Tự động căn chỉnh khoảng cách trang
                        pageFling: false,       // Tắt hiệu ứng fling giật trang của PDF mặc định
                        onRender: (_pages) {
                          setState(() {
                            totalPages = _pages ?? 0;
                          });
                        },
                        onPageChanged: (page, total) {
                          setState(() {
                            currentPage = page ?? 0;
                            // Xác định nếu người đọc đã cuộn đến trang cuối cùng
                            isAtEnd = (currentPage == (total ?? 0) - 1);
                          });
                        },
                        onError: (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text('Không thể mở file PDF: $error', style: const TextStyle(color: Colors.white))),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Không thể tải nội dung chương này.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
          bottomNavigationBar: isAtEnd
              ? Container(
                  color: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _goToNextChapter,
                    icon: Icon(
                      currentIndex < widget.chapters.length - 1
                          ? Icons.navigate_next
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      currentIndex < widget.chapters.length - 1
                          ? 'ĐỌC CHƯƠNG TIẾP THEO'
                          : 'HOÀN THÀNH BỘ TRUYỆN',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
