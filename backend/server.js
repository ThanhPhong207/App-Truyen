const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const { router: authRouter } = require('./routes/auth');
const comicsRouter = require('./routes/comics');
const creatorRouter = require('./routes/creator');
const adminRouter = require('./routes/admin');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Serve Static Files from Public Directory
// This allows downloading PDF files and viewing images via:
// http://localhost:3000/uploads/thumbnails/filename.jpg
// http://localhost:3000/uploads/chapters/filename.pdf
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.use('/api/auth', authRouter);
app.use('/api/comics', comicsRouter);
app.use('/api/creator', creatorRouter);
app.use('/api/admin', adminRouter);

// Base route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Comic App REST API',
    endpoints: {
      auth: {
        register: 'POST /api/auth/register',
        login: 'POST /api/auth/login',
        me: 'GET /api/auth/me (requires Authorization: Bearer <token>)'
      },
      comics: {
        list: 'GET /api/comics?category=...&search=...',
        detail: 'GET /api/comics/:id',
        favorites: 'GET /api/comics/favorites',
        toggleFavorite: 'PUT /api/comics/:id/favorite (body: { isFavorite: true/false })',
        chapters: 'GET /api/comics/:id/chapters'
      }
    }
  });
});

// Start Server
app.listen(PORT, () => {
  console.log(`==================================================`);
  console.log(`  Comic App Backend Server running on port ${PORT}`);
  console.log(`  Local URL: http://localhost:${PORT}`);
  console.log(`  Static uploads directory served at http://localhost:${PORT}/uploads`);
  console.log(`==================================================`);
});
