const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Database = require('../database/database');
const { authenticateToken } = require('./auth');

// Middleware to ensure the user is a creator or admin
async function isCreator(req, res, next) {
  try {
    const dbUser = await Database.Users.getById(req.user.id);
    if (!dbUser || (dbUser.role !== 'creator' && dbUser.role !== 'admin')) {
      return res.status(403).json({ message: 'Quyền truy cập bị từ chối: Chỉ người viết truyện mới có quyền này.' });
    }
    req.user.role = dbUser.role; // Sync role
    next();
  } catch (err) {
    res.status(500).json({ message: 'Lỗi xác định quyền tác giả.' });
  }
}

// Multer storage configuration for comic thumbnails
const thumbnailStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = path.join(__dirname, '..', 'public', 'uploads', 'thumbnails');
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'cover-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const uploadThumbnail = multer({ storage: thumbnailStorage });

// Multer storage configuration for chapter PDFs
const chapterStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = path.join(__dirname, '..', 'public', 'uploads', 'chapters');
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'chapter-' + uniqueSuffix + '.pdf');
  }
});
const uploadChapter = multer({ storage: chapterStorage });

// @route   GET api/creator/my-comics
// @desc    Get all comics created by the authenticated creator
// @access  Private (Creator/Admin)
router.get('/my-comics', authenticateToken, isCreator, async (req, res) => {
  try {
    const allComics = await Database.Comics.getAll();
    const comics = allComics.filter(c => c.creatorId === req.user.id);
    res.json(comics);
  } catch (err) {
    console.error('Get my comics error:', err);
    res.status(500).json({ message: 'Lỗi server khi tải truyện của bạn' });
  }
});

// @route   POST api/creator/comics
// @desc    Create a new comic (upload thumbnail cover)
// @access  Private (Creator/Admin)
router.post('/comics', authenticateToken, isCreator, uploadThumbnail.single('thumbnail'), async (req, res) => {
  try {
    const { title, category } = req.body;

    if (!title || !category) {
      return res.status(400).json({ message: 'Vui lòng cung cấp tiêu đề và thể loại truyện' });
    }

    if (!req.file) {
      return res.status(400).json({ message: 'Vui lòng tải lên ảnh bìa truyện' });
    }

    const thumbnailPath = '/uploads/thumbnails/' + req.file.filename;

    const newComic = await Database.Comics.insert({
      title,
      category,
      thumbnailPath,
      creatorId: req.user.id
    });

    res.status(201).json(newComic);
  } catch (err) {
    console.error('Create comic error:', err);
    res.status(500).json({ message: 'Lỗi server khi tạo truyện mới' });
  }
});

// @route   POST api/creator/comics/:id/chapters
// @desc    Add a chapter to a comic (upload chapter PDF)
// @access  Private (Creator/Admin)
router.post('/comics/:id/chapters', authenticateToken, isCreator, uploadChapter.single('pdf'), async (req, res) => {
  try {
    const comicId = parseInt(req.params.id);
    const { chapterNumber } = req.body;

    if (!chapterNumber) {
      return res.status(400).json({ message: 'Vui lòng cung cấp số chương' });
    }

    if (!req.file) {
      return res.status(400).json({ message: 'Vui lòng tải lên file PDF của chương' });
    }

    const comic = await Database.Comics.getById(comicId);
    if (!comic) {
      return res.status(404).json({ message: 'Không tìm thấy truyện để thêm chương' });
    }

    // Verify ownership
    if (comic.creatorId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Quyền truy cập bị từ chối: Bạn không sở hữu bộ truyện này' });
    }

    const chapterPath = '/uploads/chapters/' + req.file.filename;

    const newChapter = await Database.Chapters.insert({
      comicId,
      chapterNumber: parseInt(chapterNumber),
      chapterPath
    });

    res.status(201).json(newChapter);
  } catch (err) {
    console.error('Add chapter error:', err);
    res.status(500).json({ message: 'Lỗi server khi thêm chương mới' });
  }
});

module.exports = router;
