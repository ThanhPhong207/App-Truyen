const fs = require('fs');
const path = require('path');
const Database = require('./database');
const bcrypt = require('bcryptjs');

const FLUTTER_ASSETS_DIR = path.join(__dirname, '..', '..', 'App_truyen-main', 'App_truyen-main', 'assets');
const FLUTTER_THUMBNAILS = path.join(FLUTTER_ASSETS_DIR, 'thumbnails');
const FLUTTER_CHAPTERS = path.join(FLUTTER_ASSETS_DIR, 'chapters');

const PUBLIC_DIR = path.join(__dirname, '..', 'public');
const UPLOADS_THUMBNAILS = path.join(PUBLIC_DIR, 'uploads', 'thumbnails');
const UPLOADS_CHAPTERS = path.join(PUBLIC_DIR, 'uploads', 'chapters');

// Ensure destination directories exist
fs.mkdirSync(UPLOADS_THUMBNAILS, { recursive: true });
fs.mkdirSync(UPLOADS_CHAPTERS, { recursive: true });

function copyFiles(srcDir, destDir) {
  if (!fs.existsSync(srcDir)) {
    console.warn(`Source directory does not exist: ${srcDir}`);
    return;
  }
  
  const files = fs.readdirSync(srcDir);
  let count = 0;
  
  files.forEach(file => {
    const srcPath = path.join(srcDir, file);
    const destPath = path.join(destDir, file);
    
    // Copy only if it's a file
    if (fs.statSync(srcPath).isFile()) {
      fs.copyFileSync(srcPath, destPath);
      count++;
    }
  });
  console.log(`Copied ${count} files from ${path.basename(srcDir)} to ${path.relative(__dirname, destDir)}`);
}

async function runSeed() {
  console.log('--- Starting Database Seeding ---');
  
  // 1. Copy assets
  console.log('Copying asset files...');
  copyFiles(FLUTTER_THUMBNAILS, UPLOADS_THUMBNAILS);
  copyFiles(FLUTTER_CHAPTERS, UPLOADS_CHAPTERS);
  
  // 2. Clear previous data
  await Database.clearAllData();
  console.log('Cleared database data.');

  // 3. Create default admin/test user
  const hashedPassword = await bcrypt.hash('123456', 10);
  await Database.Users.insert({
    email: 'example@example.com',
    password: hashedPassword,
    role: 'admin'
  });
  console.log('Added default admin user: example@example.com / 123456');

  // 4. Seed Comics
  console.log('Seeding comics...');
  const comicData = [
    { id: 1, title: 'One Piece', category: 'Hành động', thumbnailPath: '/uploads/thumbnails/one_piece.jpg', isFavorite: 1 },
    { id: 2, title: 'Naruto', category: 'Phiêu lưu', thumbnailPath: '/uploads/thumbnails/naruto.jpg', isFavorite: 0 },
    { id: 3, title: 'Attack on Titan', category: 'Kinh dị', thumbnailPath: '/uploads/thumbnails/aot.jpg', isFavorite: 1 },
    { id: 4, title: 'Demon Slayer', category: 'Hành động', thumbnailPath: '/uploads/thumbnails/demon_slayer.jpg', isFavorite: 0 },
    { id: 5, title: 'Overlord', category: 'Phiêu lưu', thumbnailPath: '/uploads/thumbnails/overlord.jpg', isFavorite: 0 },
    { id: 6, title: 'Boruto', category: 'Hành động', thumbnailPath: '/uploads/thumbnails/boruto.jpg', isFavorite: 0 },
    { id: 7, title: 'Charlotte', category: 'hành động', thumbnailPath: '/uploads/thumbnails/charlotte.jpg', isFavorite: 0 },
    { id: 8, title: 'Chuyển Sinh Thành Liễu Đột Biến', category: 'Phiêu lưu', thumbnailPath: '/uploads/thumbnails/cs_lieu.jpg', isFavorite: 0 },
    { id: 9, title: 'My Cute Deskmate', category: 'Phiêu lưu', thumbnailPath: '/uploads/thumbnails/my_cute_deskmate.jpg', isFavorite: 0 },
    { id: 10, title: 'Hướng dẫn sinh tồn trong học viện', category: 'hành động', thumbnailPath: '/uploads/thumbnails/st_hoc_vien.jpg', isFavorite: 0 }
  ];

  for (const comic of comicData) {
    await Database.Comics.insert(comic);
  }
  console.log(`Successfully seeded ${comicData.length} comics.`);

  // 5. Seed Chapters
  console.log('Seeding chapters...');
  const chapters = [
    // One Piece (Comic ID 1)
    { comicId: 1, chapterNumber: 1, chapterPath: '/uploads/chapters/one_piece_ch1.pdf' },
    { comicId: 1, chapterNumber: 2, chapterPath: '/uploads/chapters/one_piece_ch2.pdf' },
    { comicId: 1, chapterNumber: 3, chapterPath: '/uploads/chapters/one_piece_ch3.pdf' },
    { comicId: 1, chapterNumber: 4, chapterPath: '/uploads/chapters/one_piece_ch4.pdf' },
    { comicId: 1, chapterNumber: 5, chapterPath: '/uploads/chapters/one_piece_ch5.pdf' },

    // Naruto (Comic ID 2)
    { comicId: 2, chapterNumber: 1, chapterPath: '/uploads/chapters/naruto_ch1.pdf' },
    { comicId: 2, chapterNumber: 2, chapterPath: '/uploads/chapters/naruto_ch2.pdf' },
    { comicId: 2, chapterNumber: 3, chapterPath: '/uploads/chapters/naruto_ch3.pdf' },
    { comicId: 2, chapterNumber: 4, chapterPath: '/uploads/chapters/naruto_ch4.pdf' },
    { comicId: 2, chapterNumber: 5, chapterPath: '/uploads/chapters/naruto_ch5.pdf' },

    // Attack on Titan (Comic ID 3)
    { comicId: 3, chapterNumber: 1, chapterPath: '/uploads/chapters/aot_ch1.pdf' },
    { comicId: 3, chapterNumber: 2, chapterPath: '/uploads/chapters/aot_ch2.pdf' },
    { comicId: 3, chapterNumber: 3, chapterPath: '/uploads/chapters/aot_ch3.pdf' },

    // Demon Slayer (Comic ID 4)
    { comicId: 4, chapterNumber: 1, chapterPath: '/uploads/chapters/demon_slayer_ch1.pdf' },
    { comicId: 4, chapterNumber: 2, chapterPath: '/uploads/chapters/demon_slayer_ch2.pdf' },
    { comicId: 4, chapterNumber: 3, chapterPath: '/uploads/chapters/demon_slayer_ch3.pdf' },

    // Overlord (Comic ID 5)
    { comicId: 5, chapterNumber: 1, chapterPath: '/uploads/chapters/overlord_ch1.pdf' },
    { comicId: 5, chapterNumber: 2, chapterPath: '/uploads/chapters/overlord_ch2.pdf' },
    { comicId: 5, chapterNumber: 3, chapterPath: '/uploads/chapters/overlord_ch3.pdf' },

    // Boruto (Comic ID 6)
    { comicId: 6, chapterNumber: 1, chapterPath: '/uploads/chapters/boruto_ch1.pdf' },
    { comicId: 6, chapterNumber: 2, chapterPath: '/uploads/chapters/boruto_ch2.pdf' },
    { comicId: 6, chapterNumber: 3, chapterPath: '/uploads/chapters/boruto_ch3.pdf' },

    // Charlotte (Comic ID 7)
    { comicId: 7, chapterNumber: 1, chapterPath: '/uploads/chapters/charlotte_ch1.pdf' },
    { comicId: 7, chapterNumber: 2, chapterPath: '/uploads/chapters/charlotte_ch2.pdf' },
    { comicId: 7, chapterNumber: 3, chapterPath: '/uploads/chapters/charlotte_ch3.pdf' },

    // Cs Lieu (Comic ID 8)
    { comicId: 8, chapterNumber: 1, chapterPath: '/uploads/chapters/cs_lieu_ch1.pdf' },
    { comicId: 8, chapterNumber: 2, chapterPath: '/uploads/chapters/cs_lieu_ch2.pdf' },
    { comicId: 8, chapterNumber: 3, chapterPath: '/uploads/chapters/cs_lieu_ch3.pdf' },

    // My Cute Deskmate (Comic ID 9)
    { comicId: 9, chapterNumber: 1, chapterPath: '/uploads/chapters/my_cute_deskmate_ch1.pdf' },
    { comicId: 9, chapterNumber: 2, chapterPath: '/uploads/chapters/my_cute_deskmate_ch2.pdf' },
    { comicId: 9, chapterNumber: 3, chapterPath: '/uploads/chapters/my_cute_deskmate_ch3.pdf' },

    // St Hoc Vien (Comic ID 10)
    { comicId: 10, chapterNumber: 1, chapterPath: '/uploads/chapters/st_hoc_vien_ch1.pdf' },
    { comicId: 10, chapterNumber: 2, chapterPath: '/uploads/chapters/st_hoc_vien_ch2.pdf' },
    { comicId: 10, chapterNumber: 3, chapterPath: '/uploads/chapters/st_hoc_vien_ch3.pdf' }
  ];

  for (const ch of chapters) {
    await Database.Chapters.insert(ch);
  }
  console.log(`Successfully seeded ${chapters.length} chapters.`);
  console.log('--- Database Seeding Complete ---');
}

runSeed().catch(err => {
  console.error('Seeding failed with error:', err);
});
