// src/services/api.js
const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
export const BASE_URL = isLocal ? 'http://localhost:3000/api' : 'https://app-truyen-backend.onrender.com/api';
export const STORAGE_URL = isLocal ? 'http://localhost:3000' : 'https://app-truyen-backend.onrender.com';

const getHeaders = () => {
  const token = localStorage.getItem('auth_token');
  const headers = {
    'Content-Type': 'application/json',
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return headers;
};

export const api = {
  // AUTH API
  login: async (email, password) => {
    const res = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Đăng nhập thất bại');
    
    localStorage.setItem('auth_token', data.token);
    localStorage.setItem('auth_user', JSON.stringify(data.user));
    return data;
  },

  register: async (email, password) => {
    const res = await fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Đăng ký thất bại');
    
    localStorage.setItem('auth_token', data.token);
    localStorage.setItem('auth_user', JSON.stringify(data.user));
    return data;
  },

  socialLogin: async (email, provider) => {
    const res = await fetch(`${BASE_URL}/auth/social-login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, provider }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Đăng nhập nhanh thất bại');
    
    localStorage.setItem('auth_token', data.token);
    localStorage.setItem('auth_user', JSON.stringify(data.user));
    return data;
  },

  updateDisplayName: async (displayName) => {
    const res = await fetch(`${BASE_URL}/auth/update-name`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ displayName }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Cập nhật tên thất bại');
    
    localStorage.setItem('auth_user', JSON.stringify(data.user));
    return data.user;
  },

  getCurrentUser: async () => {
    const token = localStorage.getItem('auth_token');
    if (!token) return null;
    try {
      const res = await fetch(`${BASE_URL}/auth/me`, {
        method: 'GET',
        headers: getHeaders(),
      });
      const data = await res.json();
      if (!res.ok) {
        localStorage.removeItem('auth_token');
        localStorage.removeItem('auth_user');
        return null;
      }
      localStorage.setItem('auth_user', JSON.stringify(data));
      return data;
    } catch (e) {
      console.error(e);
      return null;
    }
  },

  becomeCreator: async () => {
    const res = await fetch(`${BASE_URL}/auth/become-creator`, {
      method: 'PUT',
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Đăng ký tác giả thất bại');
    localStorage.setItem('auth_user', JSON.stringify(data.user));
    return data.user;
  },

  logout: () => {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('auth_user');
  },

  // COMICS API
  getComics: async (category, search) => {
    const query = new URLSearchParams();
    if (category && category !== 'Tất cả') query.append('category', category);
    if (search) query.append('search', search);

    const res = await fetch(`${BASE_URL}/comics?${query.toString()}`, {
      method: 'GET',
      headers: getHeaders(),
    });
    if (!res.ok) throw new Error('Không thể lấy danh sách truyện');
    return res.json();
  },

  getFavoriteComics: async () => {
    const res = await fetch(`${BASE_URL}/comics/favorites`, {
      method: 'GET',
      headers: getHeaders(),
    });
    if (!res.ok) throw new Error('Không thể lấy danh sách truyện yêu thích');
    return res.json();
  },

  toggleFavorite: async (comicId, isFavorite) => {
    const res = await fetch(`${BASE_URL}/comics/${comicId}/favorite`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ isFavorite }),
    });
    if (!res.ok) throw new Error('Không thể cập nhật yêu thích');
    return res.json();
  },

  // CHAPTERS API
  getChapters: async (comicId) => {
    const res = await fetch(`${BASE_URL}/comics/${comicId}/chapters`, {
      method: 'GET',
      headers: getHeaders(),
    });
    if (!res.ok) throw new Error('Không thể lấy danh sách chương');
    return res.json();
  },

  // CREATOR API
  getMyComics: async () => {
    const res = await fetch(`${BASE_URL}/creator/my-comics`, {
      method: 'GET',
      headers: getHeaders(),
    });
    if (!res.ok) throw new Error('Không thể lấy danh sách truyện của bạn');
    return res.json();
  },

  uploadComic: async (title, category, thumbnailFile) => {
    const token = localStorage.getItem('auth_token');
    const formData = new FormData();
    formData.append('title', title);
    formData.append('category', category);
    formData.append('thumbnail', thumbnailFile);

    const headers = {};
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const res = await fetch(`${BASE_URL}/creator/comics`, {
      method: 'POST',
      headers: headers, // Do NOT set Content-Type, browser will set it with boundary
      body: formData,
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Tải lên truyện thất bại');
    return data;
  },

  uploadChapter: async (comicId, chapterNumber, pdfFile) => {
    const token = localStorage.getItem('auth_token');
    const formData = new FormData();
    formData.append('chapterNumber', chapterNumber);
    formData.append('pdf', pdfFile);

    const headers = {};
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const res = await fetch(`${BASE_URL}/creator/comics/${comicId}/chapters`, {
      method: 'POST',
      headers: headers,
      body: formData,
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Tải lên chương thất bại');
    return data;
  }
};
