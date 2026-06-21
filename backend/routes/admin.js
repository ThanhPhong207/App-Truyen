const express = require('express');
const router = express.Router();
const Database = require('../database/database');
const { authenticateToken } = require('./auth');

// Middleware to ensure the user is an admin
async function isAdmin(req, res, next) {
  try {
    const dbUser = await Database.Users.getById(req.user.id);
    if (!dbUser || dbUser.role !== 'admin') {
      return res.status(403).json({ message: 'Quyền truy cập bị từ chối: Chỉ quản trị viên (Admin) mới có quyền này.' });
    }
    next();
  } catch (err) {
    res.status(500).json({ message: 'Lỗi xác định quyền Admin.' });
  }
}

// @route   GET api/admin/users
// @desc    Get all users list
// @access  Private (Admin)
router.get('/users', authenticateToken, isAdmin, async (req, res) => {
  try {
    const allUsers = await Database.Users.getAll();
    const users = allUsers.map(u => ({
      id: u.id,
      email: u.email,
      role: u.role,
      createdAt: u.createdAt
    }));
    res.json(users);
  } catch (err) {
    console.error('Admin get users error:', err);
    res.status(500).json({ message: 'Lỗi server khi lấy danh sách người dùng' });
  }
});

// @route   PUT api/admin/users/:id/role
// @desc    Update role of a user (user, creator, admin)
// @access  Private (Admin)
router.put('/users/:id/role', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { role } = req.body;
    if (!role || !['user', 'creator', 'admin'].includes(role)) {
      return res.status(400).json({ message: 'Vai trò không hợp lệ' });
    }

    const updatedUser = await Database.Users.updateRole(req.params.id, role);
    if (!updatedUser) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }

    res.json({
      message: 'Cập nhật vai trò người dùng thành công',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        role: updatedUser.role
      }
    });
  } catch (err) {
    console.error('Admin update user role error:', err);
    res.status(500).json({ message: 'Lỗi server khi cập nhật vai trò người dùng' });
  }
});

// @route   DELETE api/admin/comics/:id
// @desc    Delete a comic and cascade delete its chapters
// @access  Private (Admin)
router.delete('/comics/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const deleted = await Database.Comics.delete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ message: 'Không tìm thấy truyện để xóa' });
    }
    res.json({ message: 'Đã xóa truyện và tất cả các chương liên quan thành công' });
  } catch (err) {
    console.error('Admin delete comic error:', err);
    res.status(500).json({ message: 'Lỗi server khi xóa truyện' });
  }
});

// @route   DELETE api/admin/chapters/:id
// @desc    Delete a chapter
// @access  Private (Admin)
router.delete('/chapters/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const deleted = await Database.Chapters.delete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ message: 'Không tìm thấy chương để xóa' });
    }
    res.json({ message: 'Đã xóa chương thành công' });
  } catch (err) {
    console.error('Admin delete chapter error:', err);
    res.status(500).json({ message: 'Lỗi server khi xóa chương' });
  }
});

module.exports = router;
