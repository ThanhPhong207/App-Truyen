import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/comic.dart';
import '../services/api_service.dart';
import 'package:path/path.dart' as path;

class CreatorAddChapterScreen extends StatefulWidget {
  final Comic comic;

  const CreatorAddChapterScreen({Key? key, required this.comic}) : super(key: key);

  @override
  State<CreatorAddChapterScreen> createState() => _CreatorAddChapterScreenState();
}

class _CreatorAddChapterScreenState extends State<CreatorAddChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _chapterController = TextEditingController();
  
  File? _selectedPdf;
  bool _isUploading = false;

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPdf = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn file: $e')),
      );
    }
  }

  Future<void> _submitChapter() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Vui lòng chọn file chương PDF!'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final success = await ApiService.uploadChapter(
        widget.comic.id,
        int.parse(_chapterController.text.trim()),
        _selectedPdf!,
      );

      setState(() {
        _isUploading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Đăng chương mới thành công!'),
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Đăng chương thất bại. Vui lòng thử lại.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Lỗi: $e'),
        ),
      );
    }
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
        title: Text(
          'Đăng Chương: ${widget.comic.title}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Book Banner Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 60,
                            height: 80,
                            child: widget.comic.thumbnailPath.startsWith('/uploads') || widget.comic.thumbnailPath.startsWith('http')
                                ? Image.network(
                                    widget.comic.thumbnailPath.startsWith('http')
                                        ? widget.comic.thumbnailPath
                                        : '${ApiService.baseStorageUrl}${widget.comic.thumbnailPath}',
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(widget.comic.thumbnailPath),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.comic.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Thể loại: ${widget.comic.category}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Chapter Number Input
                  TextFormField(
                    controller: _chapterController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Số thứ tự chương (Ví dụ: 6)',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      prefixIcon: const Icon(Icons.bookmark_outline, color: Colors.indigoAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập số thứ tự chương';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Vui lòng nhập một số hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // PDF File Picker Box
                  GestureDetector(
                    onTap: _pickPdf,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedPdf != null
                              ? Colors.indigoAccent
                              : Colors.white.withOpacity(0.08),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedPdf != null ? Icons.picture_as_pdf : Icons.upload_file_outlined,
                            size: 64,
                            color: _selectedPdf != null ? Colors.redAccent : Colors.indigoAccent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedPdf != null
                                ? path.basename(_selectedPdf!.path)
                                : 'Chọn tệp PDF chương truyện',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: _selectedPdf != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedPdf != null
                                ? 'Nhấp để thay đổi tệp'
                                : 'Chỉ hỗ trợ file định dạng .pdf',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isUploading ? null : _submitChapter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'ĐĂNG CHƯƠNG',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.indigoAccent),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải file PDF lên server...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
