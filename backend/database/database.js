const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const serviceAccountPath1 = path.join(__dirname, '..', 'config', 'serviceAccountKey.json');
const serviceAccountPath2 = path.join(__dirname, '..', 'serviceAccountKey.json'); // Fallback for Render

let serviceAccountPath = serviceAccountPath1;
if (!fs.existsSync(serviceAccountPath) && fs.existsSync(serviceAccountPath2)) {
  serviceAccountPath = serviceAccountPath2;
}

let db = null;

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    db = admin.firestore();
    console.log('==================================================');
    console.log('  Firebase Firestore initialized from environment variable.');
    console.log('==================================================');
  } catch (err) {
    console.error('==================================================');
    console.error('  ERROR parsing FIREBASE_SERVICE_ACCOUNT environment variable:', err);
    console.error('==================================================');
  }
} else if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  db = admin.firestore();
  console.log('==================================================');
  console.log('  Firebase Firestore initialized successfully from file.');
  console.log('==================================================');
} else {
  console.error('==================================================');
  console.error('  WARNING: Firebase config file NOT FOUND!');
  console.error(`  Please place your 'serviceAccountKey.json' in:`);
  console.error(`  ${serviceAccountPath1} OR ${serviceAccountPath2}`);
  console.error('  OR set the FIREBASE_SERVICE_ACCOUNT environment variable on Render.');
  console.error('  The server will error on database queries.');
  console.error('==================================================');
}

const Database = {
  Users: {
    getAll: async () => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('users').get();
      return snapshot.docs.map(doc => doc.data());
    },
    
    getById: async (id) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('users').where('id', '==', parseInt(id)).limit(1).get();
      if (snapshot.empty) return null;
      return snapshot.docs[0].data();
    },
    
    getByEmail: async (email) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('users').where('email', '==', email.toLowerCase()).limit(1).get();
      if (snapshot.empty) return null;
      return snapshot.docs[0].data();
    },
    
    insert: async (user) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const usersSnapshot = await db.collection('users').get();
      const users = usersSnapshot.docs.map(doc => doc.data());
      
      const nextId = users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1;
      
      const newUser = {
        id: nextId,
        email: user.email,
        password: user.password || '',
        role: user.role || 'user',
        displayName: user.displayName || '',
        provider: user.provider || 'local',
        createdAt: new Date().toISOString()
      };
      
      await db.collection('users').doc(nextId.toString()).set(newUser);
      return newUser;
    },

    updateRole: async (id, role) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const docRef = db.collection('users').doc(id.toString());
      const doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({ role });
        return { ...doc.data(), role };
      }
      
      // Fallback in case document ID is different from numeric ID
      const snapshot = await db.collection('users').where('id', '==', parseInt(id)).limit(1).get();
      if (!snapshot.empty) {
        const matchedDoc = snapshot.docs[0];
        await matchedDoc.ref.update({ role });
        return { ...matchedDoc.data(), role };
      }
      return null;
    },

    updateDisplayName: async (id, displayName) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const docRef = db.collection('users').doc(id.toString());
      const doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({ displayName });
        return { ...doc.data(), displayName };
      }
      
      const snapshot = await db.collection('users').where('id', '==', parseInt(id)).limit(1).get();
      if (!snapshot.empty) {
        const matchedDoc = snapshot.docs[0];
        await matchedDoc.ref.update({ displayName });
        return { ...matchedDoc.data(), displayName };
      }
      return null;
    }
  },

  Comics: {
    getAll: async () => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('comics').get();
      return snapshot.docs.map(doc => doc.data());
    },
    
    getById: async (id) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('comics').where('id', '==', parseInt(id)).limit(1).get();
      if (snapshot.empty) return null;
      return snapshot.docs[0].data();
    },
    
    insert: async (comic) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const comicsSnapshot = await db.collection('comics').get();
      const comics = comicsSnapshot.docs.map(doc => doc.data());
      
      const nextId = comic.id !== undefined && comic.id !== null && comic.id !== 0 
        ? comic.id 
        : (comics.length > 0 ? Math.max(...comics.map(c => c.id)) + 1 : 1);

      const newComic = {
        id: nextId,
        title: comic.title,
        thumbnailPath: comic.thumbnailPath,
        category: comic.category,
        isFavorite: comic.isFavorite === true || comic.isFavorite === 1 ? 1 : 0,
        creatorId: comic.creatorId ? parseInt(comic.creatorId) : null
      };
      
      await db.collection('comics').doc(nextId.toString()).set(newComic);
      return newComic;
    },

    toggleFavorite: async (id, isFavorite) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const docRef = db.collection('comics').doc(id.toString());
      const doc = await docRef.get();
      const val = isFavorite ? 1 : 0;
      if (doc.exists) {
        await docRef.update({ isFavorite: val });
        return { ...doc.data(), isFavorite: val };
      }
      
      const snapshot = await db.collection('comics').where('id', '==', parseInt(id)).limit(1).get();
      if (!snapshot.empty) {
        const matchedDoc = snapshot.docs[0];
        await matchedDoc.ref.update({ isFavorite: val });
        return { ...matchedDoc.data(), isFavorite: val };
      }
      return null;
    },

    delete: async (id) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const docRef = db.collection('comics').doc(id.toString());
      const doc = await docRef.get();
      let deleted = false;
      
      if (doc.exists) {
        await docRef.delete();
        deleted = true;
      } else {
        const snapshot = await db.collection('comics').where('id', '==', parseInt(id)).limit(1).get();
        if (!snapshot.empty) {
          await snapshot.docs[0].ref.delete();
          deleted = true;
        }
      }
      
      if (deleted) {
        // Cascade delete chapters
        const chaptersSnapshot = await db.collection('chapters').where('comicId', '==', parseInt(id)).get();
        const batch = db.batch();
        chaptersSnapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        await batch.commit();
      }
      return deleted;
    },

    clearAll: async () => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('comics').get();
      const batch = db.batch();
      snapshot.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    }
  },

  Chapters: {
    getAll: async () => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('chapters').get();
      return snapshot.docs.map(doc => doc.data());
    },
    
    getById: async (id) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('chapters').where('id', '==', parseInt(id)).limit(1).get();
      if (snapshot.empty) return null;
      return snapshot.docs[0].data();
    },

    getByComicId: async (comicId) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('chapters').where('comicId', '==', parseInt(comicId)).get();
      const chapters = snapshot.docs.map(doc => doc.data());
      return chapters.sort((a, b) => a.chapterNumber - b.chapterNumber);
    },
    
    insert: async (chapter) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const chaptersSnapshot = await db.collection('chapters').get();
      const chapters = chaptersSnapshot.docs.map(doc => doc.data());
      
      const nextId = chapter.id !== undefined && chapter.id !== null && chapter.id !== 0 
        ? chapter.id 
        : (chapters.length > 0 ? Math.max(...chapters.map(c => c.id)) + 1 : 1);

      const newChapter = {
        id: nextId,
        comicId: parseInt(chapter.comicId),
        chapterNumber: parseInt(chapter.chapterNumber),
        chapterPath: chapter.chapterPath
      };
      
      await db.collection('chapters').doc(nextId.toString()).set(newChapter);
      return newChapter;
    },

    delete: async (id) => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const docRef = db.collection('chapters').doc(id.toString());
      const doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
        return true;
      }
      
      const snapshot = await db.collection('chapters').where('id', '==', parseInt(id)).limit(1).get();
      if (!snapshot.empty) {
        await snapshot.docs[0].ref.delete();
        return true;
      }
      return false;
    },

    clearAll: async () => {
      if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
      const snapshot = await db.collection('chapters').get();
      const batch = db.batch();
      snapshot.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    }
  },

  clearAllData: async () => {
    if (!db) throw new Error('Firestore not initialized. Missing serviceAccountKey.json');
    const collections = ['users', 'comics', 'chapters'];
    for (const col of collections) {
      const snapshot = await db.collection(col).get();
      const batch = db.batch();
      snapshot.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    }
  }
};

module.exports = Database;
