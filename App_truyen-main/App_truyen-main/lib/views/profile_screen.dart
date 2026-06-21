// lib/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'creator_panel_screen.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Color _getRoleColor(String role) {
    if (role == 'admin') return Colors.redAccent;
    if (role == 'creator') return Colors.indigoAccent;
    return Colors.green;
  }

  String _getRoleText(String role) {
    if (role == 'admin') return 'Quản trị viên';
    if (role == 'creator') return 'Tác giả';
    return 'Độc giả';
  }

  void _showBecomeCreatorDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Đăng Ký Làm Tác Giả',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Sau khi trở thành Tác giả, bạn có thể tự đăng truyện mới và cập nhật các chương truyện (PDF) cho mọi độc giả đọc trên ứng dụng. Bạn có muốn tiếp tục?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await authViewModel.becomeCreator();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Chúc mừng! Bạn đã đăng ký làm tác giả thành công.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(authViewModel.errorMessage ?? 'Đăng ký thất bại.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
              child: const Text('Đăng ký ngay', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Cá Nhân',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: const Color(0xFF0F172A),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // User Profile card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.indigoAccent,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundImage: AssetImage('assets/images/AVT.jpg'),
                        backgroundColor: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email != null ? user!.email.split('@')[0] : 'Độc giả',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? 'Chưa đăng nhập',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user?.role ?? 'user').withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getRoleColor(user?.role ?? 'user').withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        _getRoleText(user?.role ?? 'user'),
                        style: TextStyle(
                          color: _getRoleColor(user?.role ?? 'user'),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions menu list
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    // ADMIN OPTIONS
                    if (user?.role == 'admin') ...[
                      _buildActionTile(
                        icon: Icons.admin_panel_settings_outlined,
                        iconColor: Colors.redAccent,
                        title: 'Quản trị hệ thống (Admin)',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminDashboardScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    ],

                    // CREATOR OPTIONS
                    if (user?.role == 'creator' || user?.role == 'admin') ...[
                      _buildActionTile(
                        icon: Icons.rate_review_outlined,
                        iconColor: Colors.indigoAccent,
                        title: 'Quản lý truyện của tôi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreatorPanelScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    ],

                    // REGISTER CREATOR OPTION
                    if (user?.role == 'user') ...[
                      _buildActionTile(
                        icon: Icons.border_color_outlined,
                        iconColor: Colors.greenAccent,
                        title: 'Đăng ký làm người viết truyện',
                        onTap: () => _showBecomeCreatorDialog(context, authViewModel),
                      ),
                      Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    ],

                    _buildActionTile(
                      icon: Icons.edit_outlined,
                      title: 'Chỉnh sửa thông tin',
                      onTap: () {},
                    ),
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    _buildActionTile(
                      icon: Icons.history,
                      title: 'Lịch sử đọc truyện',
                      onTap: () {},
                    ),
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    _buildActionTile(
                      icon: Icons.security_outlined,
                      title: 'Bảo mật tài khoản',
                      onTap: () {},
                    ),
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    _buildActionTile(
                      icon: Icons.info_outline,
                      title: 'Về ứng dụng',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    authViewModel.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Đăng Xuất',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    Color iconColor = Colors.indigoAccent,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}