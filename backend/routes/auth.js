const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Database = require('../database/database');

const JWT_SECRET = process.env.JWT_SECRET || 'comic_app_secret_key_123';

// @route   POST api/auth/register
// @desc    Register a user
// @access  Public
router.post('/register', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin' });
  }

  // Validate Gmail address format
  const emailRegex = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: 'Đăng ký phải sử dụng tài khoản Gmail hợp lệ (VD: example@gmail.com)' });
  }

  try {
    // Check for existing user
    const existingUser = await Database.Users.getByEmail(email);
    if (existingUser) {
      return res.status(400).json({ message: 'Email đã tồn tại' });
    }

    // Encrypt password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insert user
    const newUser = await Database.Users.insert({
      email,
      password: hashedPassword,
      role: 'user',
      displayName: '',
      provider: 'local'
    });

    // Create JWT Token (include role)
    const token = jwt.sign(
      { id: newUser.id, email: newUser.email, role: newUser.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(201).json({
      token,
      user: {
        id: newUser.id,
        email: newUser.email,
        role: newUser.role,
        displayName: newUser.displayName || '',
        provider: newUser.provider || 'local'
      }
    });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ message: 'Lỗi server khi đăng ký' });
  }
});

// @route   POST api/auth/login
// @desc    Authenticate user & get token
// @access  Public
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin' });
  }

  try {
    // Check for user
    const user = await Database.Users.getByEmail(email);
    if (!user) {
      return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng' });
    }

    // Check if user registered via social login and has no password set
    if (user.provider !== 'local' && !user.password) {
      return res.status(400).json({ message: `Tài khoản này được đăng nhập bằng ${user.provider}. Vui lòng chọn Đăng nhập nhanh.` });
    }

    // Validate password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng' });
    }

    // Create JWT Token (include role)
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        displayName: user.displayName || '',
        provider: user.provider || 'local'
      }
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Lỗi server khi đăng nhập' });
  }
});

// @route   POST api/auth/social-login
// @desc    Quick Login/Register via Google/Facebook
// @access  Public
router.post('/social-login', async (req, res) => {
  const { email, provider } = req.body;

  if (!email || !provider) {
    return res.status(400).json({ message: 'Thiếu thông tin đăng nhập nhanh' });
  }

  try {
    let user = await Database.Users.getByEmail(email);
    let isNewUser = false;

    if (!user) {
      // Auto register the user if they don't exist yet
      user = await Database.Users.insert({
        email: email,
        password: '', // Empty password for social logins
        role: 'user',
        displayName: '', // Empty display name, will force set-name screen in frontend
        provider: provider
      });
      isNewUser = true;
    }

    // Create JWT Token
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        displayName: user.displayName || '',
        provider: user.provider || provider
      },
      isNewUser: isNewUser || !(user.displayName)
    });
  } catch (err) {
    console.error('Social Login error:', err);
    res.status(500).json({ message: 'Lỗi server khi đăng nhập nhanh' });
  }
});

// Middleware to authenticate JWT token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ message: 'Không có token, quyền truy cập bị từ chối' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
    }
    req.user = user;
    next();
  });
}

// @route   GET api/auth/me
// @desc    Get current user profile
// @access  Private
router.get('/me', authenticateToken, async (req, res) => {
  const user = await Database.Users.getById(req.user.id);
  if (!user) {
    return res.status(404).json({ message: 'Không tìm thấy người dùng' });
  }
  res.json({
    id: user.id,
    email: user.email,
    role: user.role,
    displayName: user.displayName || '',
    provider: user.provider || 'local',
    createdAt: user.createdAt
  });
});

// @route   PUT api/auth/update-name
// @desc    Update current user displayName
// @access  Private
router.put('/update-name', authenticateToken, async (req, res) => {
  const { displayName } = req.body;
  
  if (!displayName || displayName.trim() === '') {
    return res.status(400).json({ message: 'Vui lòng cung cấp tên hợp lệ' });
  }

  try {
    const updatedUser = await Database.Users.updateDisplayName(req.user.id, displayName.trim());
    if (!updatedUser) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }
    res.json({
      message: 'Cập nhật tên thành công!',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        role: updatedUser.role,
        displayName: updatedUser.displayName,
        provider: updatedUser.provider || 'local'
      }
    });
  } catch (err) {
    console.error('Update name error:', err);
    res.status(500).json({ message: 'Lỗi server khi cập nhật tên' });
  }
});

// @route   PUT api/auth/become-creator
// @desc    Request/update current user role to creator
// @access  Private
router.put('/become-creator', authenticateToken, async (req, res) => {
  const updatedUser = await Database.Users.updateRole(req.user.id, 'creator');
  if (!updatedUser) {
    return res.status(404).json({ message: 'Không tìm thấy người dùng' });
  }
  res.json({
    message: 'Đăng ký làm người viết truyện thành công!',
    user: {
      id: updatedUser.id,
      email: updatedUser.email,
      role: updatedUser.role,
      displayName: updatedUser.displayName || '',
      provider: updatedUser.provider || 'local'
    }
  });
});

module.exports = {
  router,
  authenticateToken
};
