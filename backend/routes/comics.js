const express = require('express');
const router = express.Router();
const Database = require('../database/database');

// @route   GET api/comics
// @desc    Get all comics (optional search and category filters)
// @access  Public
router.get('/', async (req, res) => {
  try {
    let comics = await Database.Comics.getAll();
    const { search, category } = req.query;

    // Filter by category
    if (category && category !== 'Tất cả') {
      comics = comics.filter(c => c.category.trim().toLowerCase() === category.trim().toLowerCase());
    }

    // Filter by search query
    if (search) {
      comics = comics.filter(c => c.title.toLowerCase().includes(search.toLowerCase()));
    }

    res.json(comics);
  } catch (err) {
    console.error('Get comics error:', err);
    res.status(500).json({ message: 'Lỗi server khi tải danh sách truyện' });
  }
});

// @route   GET api/comics/favorites
// @desc    Get all favorite comics
// @access  Public
router.get('/favorites', async (req, res) => {
  try {
    const comics = await Database.Comics.getAll();
    const favorites = comics.filter(c => c.isFavorite === 1);
    res.json(favorites);
  } catch (err) {
    console.error('Get favorites error:', err);
    res.status(500).json({ message: 'Lỗi server khi tải danh sách truyện yêu thích' });
  }
});

// @route   GET api/comics/:id
// @desc    Get comic by ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const comic = await Database.Comics.getById(req.params.id);
    if (!comic) {
      return res.status(404).json({ message: 'Không tìm thấy truyện' });
    }
    res.json(comic);
  } catch (err) {
    console.error('Get comic details error:', err);
    res.status(500).json({ message: 'Lỗi server khi tải chi tiết truyện' });
  }
});

// @route   PUT api/comics/:id/favorite
// @desc    Toggle favorite status of a comic
// @access  Public
router.put('/:id/favorite', async (req, res) => {
  const { isFavorite } = req.body;
  
  if (isFavorite === undefined) {
    return res.status(400).json({ message: 'Vui lòng truyền trạng thái isFavorite' });
  }

  try {
    const comic = await Database.Comics.getById(req.params.id);
    if (!comic) {
      return res.status(404).json({ message: 'Không tìm thấy truyện' });
    }

    const updatedComic = await Database.Comics.toggleFavorite(req.params.id, isFavorite);
    res.json(updatedComic);
  } catch (err) {
    console.error('Toggle favorite error:', err);
    res.status(500).json({ message: 'Lỗi server khi cập nhật trạng thái yêu thích' });
  }
});

// @route   GET api/comics/:id/chapters
// @desc    Get all chapters for a comic
// @access  Public
router.get('/:id/chapters', async (req, res) => {
  try {
    const comic = await Database.Comics.getById(req.params.id);
    if (!comic) {
      return res.status(404).json({ message: 'Không tìm thấy truyện' });
    }

    const chapters = await Database.Chapters.getByComicId(req.params.id);
    res.json(chapters);
  } catch (err) {
    console.error('Get chapters error:', err);
    res.status(500).json({ message: 'Lỗi server khi tải danh sách chương' });
  }
});

module.exports = router;
