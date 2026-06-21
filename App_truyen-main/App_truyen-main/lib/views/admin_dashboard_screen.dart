import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/comic.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<User> _users = [];
  List<Comic> _comics = [];
  
  bool _isLoadingUsers = true;
  bool _isLoadingComics = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
    _fetchComics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });
    try {
      final list = await ApiService.adminGetUsers();
      setState(() {
        _users = list;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách người dùng: $e')),
      );
    }
  }

  Future<void> _fetchComics() async {
    setState(() {
      _isLoadingComics = true;
    });
    try {
      final list = await ApiService.getComics();
      setState(() {
        _comics = list;
        _isLoadingComics = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComics = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách truyện: $e')),
      );
    }
  }

  void _showChangeRoleDialog(User user) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Text(
                'Đổi Vai Trò: ${user.email}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Độc giả (User)', style: TextStyle(color: Colors.white)),
                    value: 'user',
                    groupValue: selectedRole,
                    activeColor: Colors.indigoAccent,
                    onChanged: (val) => setDialogState(() => selectedRole = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Tác giả (Creator)', style: TextStyle(color: Colors.white)),
                    value: 'creator',
                    groupValue: selectedRole,
                    activeColor: Colors.indigoAccent,
                    onChanged: (val) => setDialogState(() => selectedRole = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Quản trị viên (Admin)', style: TextStyle(color: Colors.white)),
                    value: 'admin',
                    groupValue: selectedRole,
                    activeColor: Colors.indigoAccent,
                    onChanged: (val) => setDialogState(() => selectedRole = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final success = await ApiService.adminUpdateUserRole(user.id, selectedRole);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: Colors.green, content: Text('Cập nhật vai trò thành công!')),
                      );
                      _fetchUsers();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: Colors.redAccent, content: Text('Cập nhật thất bại.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
                  child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteComicDialog(Comic comic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Xóa Truyện Tranh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Bạn có chắc chắn muốn xóa bộ truyện "${comic.title}"? Thao tác này cũng sẽ xóa toàn bộ các chương của truyện và không thể khôi phục.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await ApiService.adminDeleteComic(comic.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.green, content: Text('Xóa truyện thành công!')),
                  );
                  _fetchComics();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.redAccent, content: Text('Xóa truyện thất bại.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.redAccent;
      case 'creator':
        return Colors.indigoAccent;
      default:
        return Colors.green;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'creator':
        return 'Tác giả';
      default:
        return 'Độc giả';
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
        title: const Text(
          'Bảng Điều Khiển Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.indigoAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Thành viên'),
            Tab(icon: Icon(Icons.auto_stories), text: 'Truyện tranh'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // USERS TAB
          RefreshIndicator(
            onRefresh: _fetchUsers,
            color: Colors.indigoAccent,
            child: _isLoadingUsers
                ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                : _users.isEmpty
                    ? const Center(child: Text('Không tìm thấy thành viên nào', style: TextStyle(color: Colors.white30)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                user.email,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  'Ngày tham gia: ${user.id != 0 ? "Thành viên chính thức" : "Mới"}',
                                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(user.role).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: _getRoleColor(user.role).withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      _getRoleText(user.role),
                                      style: TextStyle(color: _getRoleColor(user.role), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.manage_accounts, color: Colors.white54),
                                    onPressed: () => _showChangeRoleDialog(user),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // COMICS TAB
          RefreshIndicator(
            onRefresh: _fetchComics,
            color: Colors.indigoAccent,
            child: _isLoadingComics
                ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                : _comics.isEmpty
                    ? const Center(child: Text('Không tìm thấy truyện tranh nào', style: TextStyle(color: Colors.white30)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comics.length,
                        itemBuilder: (context, index) {
                          final comic = _comics[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 45,
                                  height: 60,
                                  child: comic.thumbnailPath.startsWith('/uploads') || comic.thumbnailPath.startsWith('http')
                                      ? Image.network(
                                          comic.thumbnailPath.startsWith('http')
                                              ? comic.thumbnailPath
                                              : '${ApiService.baseStorageUrl}${comic.thumbnailPath}',
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(comic.thumbnailPath),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              title: Text(
                                comic.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Thể loại: ${comic.category}',
                                  style: const TextStyle(color: Colors.indigoAccent, fontSize: 13),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _showDeleteComicDialog(comic),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
