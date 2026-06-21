// src/App.jsx
import React, { useState, useEffect } from 'react';
import { 
  BookOpen, 
  Search, 
  Heart, 
  User as UserIcon, 
  LogOut, 
  Menu, 
  X, 
  Plus, 
  FileText, 
  ChevronRight, 
  ChevronLeft, 
  Sparkles, 
  Lock, 
  Mail, 
  Info,
  Award,
  Upload,
  ArrowLeft,
  BookMarked,
  Eye,
  FileCheck,
  Send,
  Calendar,
  Layers,
  Star,
  Users
} from 'lucide-react';
import { api, STORAGE_URL } from './services/api';

export default function App() {
  const [currentView, setCurrentView] = useState('home'); // home, login, register, set-name, detail, read, creator
  const [user, setUser] = useState(null);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  
  // App state
  const [comics, setComics] = useState([]);
  const [favoriteComics, setFavoriteComics] = useState([]);
  const [selectedComic, setSelectedComic] = useState(null);
  const [selectedChapter, setSelectedChapter] = useState(null);
  const [chapters, setChapters] = useState([]);
  const [categoryFilter, setCategoryFilter] = useState('Tất cả');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Navigation / UI
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [sidebarTab, setSidebarTab] = useState('library'); // library, favorites
  const [socialDialog, setSocialDialog] = useState({ open: false, provider: '' });
  const [socialEmail, setSocialEmail] = useState('');
  const [authModal, setAuthModal] = useState({ open: false, mode: 'login' });

  // Form states
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [nickname, setNickname] = useState('');
  
  // Creator states
  const [myComics, setMyComics] = useState([]);
  const [newComicTitle, setNewComicTitle] = useState('');
  const [newComicCategory, setNewComicCategory] = useState('Hành động');
  const [newComicThumbnail, setNewComicThumbnail] = useState(null);
  const [newChapterComicId, setNewChapterComicId] = useState('');
  const [newChapterNumber, setNewChapterNumber] = useState('');
  const [newChapterPdf, setNewChapterPdf] = useState(null);
  const [loading, setLoading] = useState(false);

  const categories = ['Tất cả', 'Hành động', 'Tình cảm', 'Kỳ ảo', 'Hài hước', 'Đời thường', 'Kinh dị'];

  useEffect(() => {
    checkAuth();
    loadComics();
  }, []);

  useEffect(() => {
    if (sidebarTab === 'library') {
      loadComics();
    } else if (sidebarTab === 'favorites') {
      loadFavorites();
    }
  }, [sidebarTab, categoryFilter, searchQuery]);

  const checkAuth = async () => {
    const currentUser = await api.getCurrentUser();
    if (currentUser) {
      setUser(currentUser);
      if (!currentUser.displayName) {
        setCurrentView('set-name');
      }
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    try {
      const data = await api.login(loginEmail, loginPassword);
      setUser(data.user);
      setAuthModal({ open: false, mode: 'login' });
      if (!data.user.displayName) {
        setCurrentView('set-name');
      } else {
        setCurrentView('home');
        setSidebarTab('library');
      }
    } catch (err) {
      setErrorMessage(err.message);
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    
    // Check Gmail format
    if (!regEmail.endsWith('@gmail.com')) {
      setErrorMessage('Đăng ký phải sử dụng tài khoản Gmail hợp lệ (VD: example@gmail.com)');
      return;
    }

    try {
      const data = await api.register(regEmail, regPassword);
      setUser(data.user);
      setAuthModal({ open: false, mode: 'register' });
      setCurrentView('set-name');
    } catch (err) {
      setErrorMessage(err.message);
    }
  };

  const handleSocialLogin = async (provider) => {
    setSocialDialog({ open: true, provider });
    setSocialEmail(provider === 'Google' ? 'demo_google@gmail.com' : 'demo_facebook@gmail.com');
  };

  const submitSocialLogin = async () => {
    setErrorMessage('');
    setSocialDialog({ open: false, provider: '' });
    try {
      const data = await api.socialLogin(socialEmail, socialDialog.provider.toLowerCase());
      setUser(data.user);
      if (data.isNewUser || !data.user.displayName) {
        setCurrentView('set-name');
      } else {
        setCurrentView('home');
        setSidebarTab('library');
      }
    } catch (err) {
      setErrorMessage(err.message);
    }
  };

  const handleSetName = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    if (!nickname.trim()) {
      setErrorMessage('Biệt danh không được để trống');
      return;
    }
    try {
      const updatedUser = await api.updateDisplayName(nickname);
      setUser(updatedUser);
      setCurrentView('home');
      setSidebarTab('library');
    } catch (err) {
      setErrorMessage(err.message);
    }
  };

  const handleLogout = () => {
    api.logout();
    setUser(null);
    setCurrentView('home');
    setSidebarTab('library');
    // clear forms
    setLoginEmail('');
    setLoginPassword('');
    setRegEmail('');
    setRegPassword('');
    setNickname('');
  };

  const loadComics = async () => {
    try {
      const data = await api.getComics(categoryFilter === 'Tất cả' ? null : categoryFilter, searchQuery);
      setComics(data);
    } catch (err) {
      console.error(err);
    }
  };

  const loadFavorites = async () => {
    try {
      const data = await api.getFavoriteComics();
      setFavoriteComics(data);
    } catch (err) {
      console.error(err);
    }
  };

  const loadMyComics = async () => {
    try {
      const data = await api.getMyComics();
      setMyComics(data);
    } catch (err) {
      console.error(err);
    }
  };

  const handleToggleFavorite = async (e, comic) => {
    e.stopPropagation();
    if (!user) {
      setCurrentView('login');
      return;
    }
    const isFav = favoriteComics.some(c => c.id === comic.id) || comic.isFavorite === 1;
    try {
      await api.toggleFavorite(comic.id, !isFav);
      if (sidebarTab === 'favorites') {
        loadFavorites();
      } else {
        loadComics();
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleSelectComic = async (comic) => {
    setSelectedComic(comic);
    setCurrentView('detail');
    try {
      const chapterData = await api.getChapters(comic.id);
      setChapters(chapterData);
    } catch (err) {
      console.error(err);
    }
  };

  const handleReadChapter = (chapter) => {
    setSelectedChapter(chapter);
    setCurrentView('read');
  };

  const handleBecomeCreator = async () => {
    setErrorMessage('');
    try {
      const updatedUser = await api.becomeCreator();
      setUser(updatedUser);
    } catch (err) {
      setErrorMessage(err.message);
    }
  };

  const handleCreateComic = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');
    if (!newComicTitle.trim()) {
      setErrorMessage('Tiêu đề truyện không được trống');
      return;
    }
    if (!newComicThumbnail) {
      setErrorMessage('Vui lòng chọn ảnh bìa cho truyện');
      return;
    }

    setLoading(true);
    try {
      await api.uploadComic(newComicTitle, newComicCategory, newComicThumbnail);
      setSuccessMessage('Đăng truyện mới thành công! Mọi người có thể đọc truyện ngay bây giờ.');
      setNewComicTitle('');
      setNewComicThumbnail(null);
      document.getElementById('comic-thumbnail-input').value = '';
      loadMyComics();
    } catch (err) {
      setErrorMessage(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateChapter = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');
    if (!newChapterComicId) {
      setErrorMessage('Vui lòng chọn truyện để thêm chương');
      return;
    }
    if (!newChapterNumber) {
      setErrorMessage('Vui lòng nhập số chương');
      return;
    }
    if (!newChapterPdf) {
      setErrorMessage('Vui lòng chọn file PDF chương truyện');
      return;
    }

    setLoading(true);
    try {
      await api.uploadChapter(newChapterComicId, newChapterNumber, newChapterPdf);
      setSuccessMessage(`Tải lên Chương ${newChapterNumber} thành công!`);
      setNewChapterNumber('');
      setNewChapterPdf(null);
      document.getElementById('chapter-pdf-input').value = '';
      
      if (selectedComic && selectedComic.id === parseInt(newChapterComicId)) {
        const chapterData = await api.getChapters(selectedComic.id);
        setChapters(chapterData);
      }
    } catch (err) {
      setErrorMessage(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#f4f4f4] text-slate-800 flex flex-col">
      {/* SOCIAL DIALOG */}
      {socialDialog.open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-[6px] p-4">
          <div className="bg-white w-full max-w-md rounded-lg p-6 shadow-2xl border border-slate-200">
            <div className="flex items-center gap-3 mb-4">
              <Sparkles className={`w-6 h-6 ${socialDialog.provider === 'Google' ? 'text-rose-500' : 'text-blue-500'}`} />
              <h3 className="text-lg font-bold text-slate-800">Đăng nhập nhanh với {socialDialog.provider}</h3>
            </div>
            <p className="text-slate-500 text-xs mb-4">
              Nhập email giả lập để bắt đầu trải nghiệm nhanh như các ứng dụng cao cấp.
            </p>
            <div className="mb-4">
              <label className="block text-xs font-semibold text-slate-500 mb-2">Email {socialDialog.provider}</label>
              <input 
                type="email"
                className="w-full px-3 py-2 rounded qq-input text-sm"
                value={socialEmail}
                onChange={(e) => setSocialEmail(e.target.value)}
              />
              <span className="text-[11px] text-orange-500 italic mt-2 block">
                * Nếu là tài khoản mới, hệ thống tự tạo và chuyển tới màn đặt tên.
              </span>
            </div>
            <div className="flex justify-end gap-3">
              <button 
                onClick={() => setSocialDialog({ open: false, provider: '' })}
                className="px-4 py-2 rounded text-xs text-slate-400 hover:text-slate-600 transition-colors"
              >
                Hủy
              </button>
              <button 
                onClick={submitSocialLogin}
                className="px-5 py-2 rounded text-xs btn-qq-accent"
              >
                Xác nhận
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 1. HEADER (WHITE BASE like TRUYENQQ) */}
      <header className="qq-header">
        <div className="main-container h-20 flex items-center justify-between gap-4">
          {/* Logo with Penguin/Book design */}
          <div 
            onClick={() => { setCurrentView('home'); setSidebarTab('library'); }}
            className="flex items-center gap-2 cursor-pointer flex-shrink-0"
          >
            <div className="w-10 h-10 rounded-full bg-slate-900 flex items-center justify-center text-white">
              <span className="text-lg font-bold">🐧</span>
            </div>
            <div className="flex flex-col">
              <span className="font-black text-xl tracking-tight text-slate-800 leading-none">
                TRUYEN<span className="text-[#df853b]">WEB</span>
              </span>
              <span className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-1">Đọc truyện PDF</span>
            </div>
          </div>

          {/* Search bar in the center */}
          <div className="hidden sm:flex items-center max-w-lg w-full relative">
            <input 
              type="text" 
              placeholder="Bạn muốn tìm truyện gì..."
              className="w-full pl-4 pr-12 py-2 rounded-l-full rounded-r-none qq-input text-sm h-10"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            <button 
              onClick={loadComics}
              className="absolute right-0 top-0 h-10 px-4 bg-[#df853b] hover:bg-[#c97129] text-white rounded-r-full flex items-center justify-center transition-colors border-none"
            >
              <Search className="w-4 h-4" />
            </button>
          </div>

          {/* Auth options / Account display */}
          <div className="flex items-center gap-3">
            {user ? (
              <div className="flex items-center gap-3">
                <div className="hidden md:flex flex-col text-right">
                  <span className="text-xs font-bold text-slate-700">{user.displayName || 'Tác giả mới'}</span>
                  <span className="text-[9px] text-orange-500 font-bold uppercase">{user.role}</span>
                </div>
                <div className="w-8 h-8 rounded-full bg-orange-100 border border-orange-200 text-orange-500 flex items-center justify-center font-bold text-xs uppercase">
                  {user.displayName ? user.displayName[0] : 'U'}
                </div>
                <button 
                  onClick={handleLogout}
                  className="p-1.5 rounded-lg bg-slate-100 hover:bg-rose-50 text-slate-500 hover:text-rose-500 transition-colors"
                  title="Đăng xuất"
                >
                  <LogOut className="w-4 h-4" />
                </button>
              </div>
            ) : (
              <div className="flex items-center gap-2">
                <button 
                  onClick={() => { setAuthModal({ open: true, mode: 'register' }); setErrorMessage(''); setSuccessMessage(''); }}
                  className="px-4 py-2 text-xs font-bold btn-qq-primary"
                >
                  Đăng ký
                </button>
                <button 
                  onClick={() => { setAuthModal({ open: true, mode: 'login' }); setErrorMessage(''); setSuccessMessage(''); }}
                  className="px-4 py-2 text-xs font-bold btn-qq-accent"
                >
                  Đăng nhập
                </button>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* 2. MENU BAR (ORANGE BAR like TRUYENQQ) */}
      <nav className="qq-menu-bar py-1 shadow-inner">
        <div className="main-container flex items-center justify-between overflow-x-auto scrollbar-none">
          <div className="flex items-center gap-1 md:gap-2">
            <button 
              onClick={() => { setCurrentView('home'); setSidebarTab('library'); setCategoryFilter('Tất cả'); }}
              className={`px-4 py-2.5 text-sm font-bold rounded hover:bg-black/15 transition-colors ${
                currentView === 'home' && sidebarTab === 'library' && categoryFilter === 'Tất cả' ? 'bg-black/15' : ''
              }`}
            >
              Trang Chủ
            </button>
            <button 
              onClick={() => { setCurrentView('home'); setSidebarTab('library'); setCategoryFilter('Hành động'); }}
              className={`px-4 py-2.5 text-sm font-bold rounded hover:bg-black/15 transition-colors ${
                categoryFilter === 'Hành động' ? 'bg-black/15' : ''
              }`}
            >
              Hành động
            </button>
            <button 
              onClick={() => { setCurrentView('home'); setSidebarTab('library'); setCategoryFilter('Tình cảm'); }}
              className={`px-4 py-2.5 text-sm font-bold rounded hover:bg-black/15 transition-colors ${
                categoryFilter === 'Tình cảm' ? 'bg-black/15' : ''
              }`}
            >
              Tình cảm
            </button>
            <button 
              onClick={() => { setCurrentView('home'); setSidebarTab('library'); setCategoryFilter('Kỳ ảo'); }}
              className={`px-4 py-2.5 text-sm font-bold rounded hover:bg-black/15 transition-colors ${
                categoryFilter === 'Kỳ ảo' ? 'bg-black/15' : ''
              }`}
            >
              Kỳ ảo
            </button>
            
            {user && (
              <>
                <button 
                  onClick={() => { setCurrentView('home'); setSidebarTab('favorites'); }}
                  className={`px-4 py-2.5 text-sm font-bold rounded hover:bg-black/15 transition-colors ${
                    sidebarTab === 'favorites' && currentView === 'home' ? 'bg-black/15' : ''
                  }`}
                >
                  Truyện Yêu Thích
                </button>
                <button 
                  onClick={() => { setCurrentView('creator'); loadMyComics(); }}
                  className={`px-4 py-2.5 text-sm font-bold rounded hover:bg-black/15 transition-colors ${
                    currentView === 'creator' ? 'bg-black/15' : ''
                  }`}
                >
                  Đăng Truyện Mới (Creator)
                </button>
              </>
            )}
          </div>
          
          <div className="hidden lg:flex items-center gap-2 pr-2">
            <span className="text-[11px] bg-white/20 px-2 py-0.5 rounded font-black text-white uppercase tracking-wider animate-pulse">
              HOT
            </span>
            <span className="text-xs text-white/90">Hỗ trợ đọc PDF tốc độ cao</span>
          </div>
        </div>
      </nav>

      {/* MOBILE SEARCH BAR */}
      <div className="sm:hidden p-3 bg-white border-b border-slate-200">
        <div className="relative flex items-center">
          <input 
            type="text" 
            placeholder="Bạn muốn tìm truyện gì..."
            className="w-full pl-4 pr-10 py-2 rounded-full qq-input text-xs h-9"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
          <button 
            onClick={loadComics}
            className="absolute right-0 top-0 h-9 px-3 bg-[#df853b] hover:bg-[#c97129] text-white rounded-r-full flex items-center justify-center border-none"
          >
            <Search className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* 3. MAIN SECTION */}
      <main className="flex-1 py-4 md:py-6">
        <div className="main-container space-y-4">

          {/* 3.1 ALERT NOTICE BOX */}
          <div className="qq-alert-box p-3 rounded text-xs md:text-sm font-medium flex items-center gap-2">
            <span className="font-bold text-red-600">Thông báo:</span>
            <span>comicweb.com đã chuyển sang tên miền mới là <strong className="text-green-600 font-bold">comicwebko.com</strong> - Đạo hữu 4 phương mau mau lưu lại để không đi nhầm nhà nhé!</span>
          </div>

          {/* 3.2 COMMUNITY BAR (ORANGE BAR like TRUYENQQ) */}
          <div className="qq-community-bar p-3 rounded flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center gap-2 text-xs md:text-sm font-bold">
              <Users className="w-4 h-4" />
              <span>CỘNG ĐỒNG COMICWEB:</span>
            </div>
            <div className="flex flex-wrap gap-2">
              <a href="https://facebook.com" target="_blank" rel="noreferrer" className="px-3 py-1 text-xs btn-social bg-[#1877f2] flex items-center gap-1 font-bold">
                <span className="font-extrabold mr-1">f</span> Facebook
              </a>
              <a href="https://facebook.com/groups" target="_blank" rel="noreferrer" className="px-3 py-1 text-xs btn-social bg-[#0c87ef] flex items-center gap-1">
                Group FB
              </a>
              <a href="https://discord.com" target="_blank" rel="noreferrer" className="px-3 py-1 text-xs btn-social bg-[#5865f2] flex items-center gap-1">
                Discord
              </a>
              <a href="https://telegram.org" target="_blank" rel="noreferrer" className="px-3 py-1 text-xs btn-social bg-[#29b6f6] flex items-center gap-1">
                Telegram
              </a>
            </div>
          </div>

          {/* 3.3 AUTH MODAL (POPUPS IN CENTER like TRUYENQQ) */}
          {authModal.open && (
            <div 
              className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-[6px] p-4 animate-fade-in"
              onClick={() => setAuthModal({ open: false, mode: 'login' })}
            >
              <div 
                className="bg-white w-full max-w-md rounded shadow-2xl border border-slate-200 overflow-hidden flex flex-col"
                onClick={(e) => e.stopPropagation()}
              >
                {/* Header */}
                <div className="p-4 text-center border-b border-slate-100 relative">
                  <h3 className="text-lg font-bold text-slate-800 tracking-wide uppercase">
                    {authModal.mode === 'login' ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ'}
                  </h3>
                  <button 
                    onClick={() => setAuthModal({ open: false, mode: 'login' })}
                    className="absolute right-4 top-4 text-slate-400 hover:text-slate-600"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>

                {/* Content */}
                <div className="p-6 space-y-4">
                  {errorMessage && (
                    <div className="bg-rose-50 border border-rose-200 text-rose-600 px-4 py-2 rounded text-xs text-center">
                      {errorMessage}
                    </div>
                  )}

                  {/* Google Login button */}
                  <button 
                    type="button"
                    onClick={() => {
                      setAuthModal({ open: false, mode: 'login' });
                      handleSocialLogin('Google');
                    }}
                    className="w-full py-2.5 bg-[#d34836] hover:bg-[#c13b2a] text-white rounded font-bold text-xs flex items-center justify-center gap-2 transition-colors border-none"
                  >
                    <span className="font-extrabold text-sm">G</span> Đăng nhập với Google
                  </button>

                  {/* Form */}
                  <form 
                    onSubmit={authModal.mode === 'login' ? handleLogin : handleRegister}
                    className="space-y-4"
                  >
                    <div>
                      <label className="block text-xs font-bold text-slate-600 mb-1">Email</label>
                      <input 
                        type="email"
                        required
                        placeholder={authModal.mode === 'register' ? 'Gmail hợp lệ: vd@gmail.com' : 'Email của bạn...'}
                        className="w-full px-3 py-2 rounded border border-slate-200 focus:outline-none focus:border-[#df853b] text-sm"
                        value={authModal.mode === 'login' ? loginEmail : regEmail}
                        onChange={(e) => authModal.mode === 'login' ? setLoginEmail(e.target.value) : setRegEmail(e.target.value)}
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-slate-600 mb-1">Mật khẩu</label>
                      <input 
                        type="password"
                        required
                        placeholder="Mật khẩu của bạn..."
                        className="w-full px-3 py-2 rounded border border-slate-200 focus:outline-none focus:border-[#df853b] text-sm"
                        value={authModal.mode === 'login' ? loginPassword : regPassword}
                        onChange={(e) => authModal.mode === 'login' ? setLoginPassword(e.target.value) : setRegPassword(e.target.value)}
                      />
                    </div>

                    {/* Footer buttons row */}
                    <div className="flex items-center justify-between pt-4 border-t border-slate-100">
                      {/* Left links */}
                      <div className="text-xs space-x-1">
                        {authModal.mode === 'login' ? (
                          <>
                            <button 
                              type="button"
                              onClick={() => { setAuthModal({ ...authModal, mode: 'register' }); setErrorMessage(''); }}
                              className="text-[#4a90e2] hover:underline font-bold"
                            >
                              Đăng ký
                            </button>
                            <span className="text-slate-300">|</span>
                            <button 
                              type="button"
                              onClick={() => alert('Chức năng quên mật khẩu đang được phát triển')}
                              className="text-slate-500 hover:underline"
                            >
                              Quên mật khẩu
                            </button>
                          </>
                        ) : (
                          <button 
                            type="button"
                            onClick={() => { setAuthModal({ ...authModal, mode: 'login' }); setErrorMessage(''); }}
                            className="text-[#4a90e2] hover:underline font-bold"
                          >
                            Đăng nhập ngay
                          </button>
                        )}
                      </div>

                      {/* Right action buttons */}
                      <div className="flex items-center gap-2">
                        <button 
                          type="submit"
                          className="px-4 py-2 bg-[#df853b] hover:bg-[#c97129] text-white rounded text-xs font-bold transition-all border-none"
                        >
                          {authModal.mode === 'login' ? 'Đăng nhập' : 'Đăng ký'}
                        </button>
                        <button 
                          type="button"
                          onClick={() => setAuthModal({ open: false, mode: 'login' })}
                          className="px-4 py-2 bg-[#4a90e2] hover:bg-[#3b7ec4] text-white rounded text-xs font-bold transition-all border-none"
                        >
                          Hủy
                        </button>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          )}

          {/* 3.5 SET NAME PAGE */}
          {currentView === 'set-name' && (
            <div className="max-w-md mx-auto bg-white rounded border border-slate-200 p-6 md:p-8 shadow my-6 animate-fade-in">
              <div className="text-center mb-6">
                <h2 className="text-xl font-bold text-slate-800 uppercase">Chào mừng bạn!</h2>
                <p className="text-xs text-slate-400 mt-1">Hãy đặt biệt hiệu/bút danh để bắt đầu đọc và đăng truyện.</p>
                <div className="w-12 h-1 bg-[#df853b] mx-auto mt-2 rounded"></div>
              </div>

              {errorMessage && (
                <div className="bg-rose-50 border border-rose-200 text-rose-600 px-4 py-2 rounded text-xs mb-4 text-center">
                  {errorMessage}
                </div>
              )}

              <form onSubmit={handleSetName} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Biệt danh của bạn</label>
                  <input 
                    type="text" 
                    required
                    placeholder="Nhập nickname..."
                    className="w-full px-3 py-2.5 rounded qq-input text-sm"
                    value={nickname}
                    onChange={(e) => setNickname(e.target.value)}
                  />
                </div>

                <button type="submit" className="w-full py-2.5 rounded btn-qq-accent text-sm font-bold shadow-sm">
                  Hoàn tất & Bắt đầu
                </button>
              </form>
            </div>
          )}

          {/* 3.6 COMICS MAIN GRID (HOME) */}
          {currentView === 'home' && (
            <div className="bg-white rounded border border-slate-200 p-4 md:p-6 space-y-6 animate-fade-in shadow-sm">
              {/* Starred Category Header */}
              <div className="flex items-center justify-between border-b border-slate-200 pb-3">
                <h2 className="text-lg font-bold text-red-600 uppercase flex items-center gap-1">
                  <Star className="w-4 h-4 fill-red-600 text-red-600" />
                  {sidebarTab === 'favorites' ? 'Danh sách truyện yêu thích' : `${categoryFilter} - Truyện Mới Cập Nhật`}
                </h2>
                {sidebarTab === 'favorites' && (
                  <button 
                    onClick={() => setSidebarTab('library')}
                    className="text-xs text-[#df853b] font-bold hover:underline"
                  >
                    Xem tất cả truyện
                  </button>
                )}
              </div>

              {/* Grid content */}
              {((sidebarTab === 'library' ? comics : favoriteComics).length === 0) ? (
                <div className="py-16 text-center text-slate-400 text-sm">
                  <BookOpen className="w-12 h-12 mx-auto text-slate-300 mb-3" />
                  <span>Không tìm thấy tác phẩm nào phù hợp.</span>
                </div>
              ) : (
                <div className="comics-grid">
                  {(sidebarTab === 'library' ? comics : favoriteComics).map((comic) => {
                    const isFav = favoriteComics.some(c => c.id === comic.id) || comic.isFavorite === 1;
                    const thumbUrl = comic.thumbnailPath.startsWith('http') 
                      ? comic.thumbnailPath 
                      : `${STORAGE_URL}${comic.thumbnailPath}`;

                    return (
                      <div 
                        key={comic.id}
                        onClick={() => handleSelectComic(comic)}
                        className="qq-card cursor-pointer flex flex-col group"
                      >
                        {/* Thumbnail wrapper */}
                        <div className="relative aspect-[3/4] overflow-hidden bg-slate-100">
                          <img 
                            src={thumbUrl} 
                            alt={comic.title}
                            className="w-full h-full object-cover"
                            onError={(e) => {
                              e.target.src = 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500';
                            }}
                          />
                          {/* Time & Hot badges like TruyenQQ */}
                          <div className="absolute top-2 left-2 flex flex-col gap-1 pointer-events-none">
                            <span className="px-1.5 py-0.5 bg-[#4a90e2] text-white text-[8px] font-bold rounded">
                              Hot
                            </span>
                            <span className="px-1.5 py-0.5 bg-[#df853b] text-white text-[8px] font-bold rounded">
                              Mới
                            </span>
                          </div>

                          {/* Heart bookmark button */}
                          <button
                            onClick={(e) => handleToggleFavorite(e, comic)}
                            className="absolute top-2 right-2 w-7 h-7 rounded-full bg-white/90 shadow flex items-center justify-center text-slate-500 hover:text-red-500 transition-colors"
                          >
                            <Heart className={`w-3.5 h-3.5 ${isFav ? 'fill-red-500 text-red-500' : ''}`} />
                          </button>
                        </div>

                        {/* Text section */}
                        <div className="p-2.5 flex-1 flex flex-col justify-between">
                          <h3 className="font-bold text-slate-800 text-xs md:text-sm line-clamp-2 leading-tight group-hover:text-[#df853b] transition-colors">
                            {comic.title}
                          </h3>
                          
                          {/* Latest chapter link like TruyenQQ */}
                          <div className="mt-2 pt-1.5 border-t border-slate-100 flex items-center justify-between text-[11px] text-[#4a90e2] font-semibold hover:underline">
                            <span>Chương mới nhất</span>
                            <span className="bg-slate-100 text-slate-600 px-1 py-0.2 rounded text-[10px]">
                              {comic.category}
                            </span>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          )}

          {/* 3.7 COMIC DETAIL PAGE */}
          {currentView === 'detail' && selectedComic && (
            <div className="bg-white rounded border border-slate-200 p-4 md:p-6 space-y-6 animate-fade-in shadow-sm">
              {/* Breadcrumb like screenshot */}
              <div className="text-xs text-slate-500 font-medium pb-2 border-b border-slate-100 mb-4 flex items-center gap-1.5">
                <span className="cursor-pointer hover:text-[#df853b] font-bold" onClick={() => setCurrentView('home')}>Trang Chủ</span>
                <span className="text-slate-400">/</span>
                <span className="text-slate-700 font-bold">{selectedComic.title}</span>
              </div>

              <div className="flex flex-col md:flex-row gap-8 items-start">
                {/* Left side cover image */}
                <div className="w-52 md:w-56 aspect-[3/4] rounded-lg overflow-hidden bg-slate-100 flex-shrink-0 shadow-lg border border-slate-200/80 mx-auto md:mx-0">
                  <img 
                    src={selectedComic.thumbnailPath.startsWith('http') ? selectedComic.thumbnailPath : `${STORAGE_URL}${selectedComic.thumbnailPath}`} 
                    alt={selectedComic.title} 
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      e.target.src = 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500';
                    }}
                  />
                </div>

                {/* Right side information grid */}
                <div className="flex-1 space-y-5 w-full">
                  <div>
                    <h1 className="text-2xl font-bold text-slate-800 tracking-tight leading-tight text-center md:text-left">
                      {selectedComic.title}
                    </h1>
                  </div>

                  {/* Metadata table like TruyenQQ screenshot */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-2.5 text-sm">
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">👤 Tác giả</span>
                      <span className="text-slate-850 font-bold">{selectedComic.author || 'TruyenQQ'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">📅 Ngày tạo</span>
                      <span className="text-slate-850 font-bold">{selectedComic.createdAt ? new Date(selectedComic.createdAt).toLocaleDateString('vi-VN') : '25/10/2016'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">👥 Nhóm dịch</span>
                      <span className="text-slate-850 font-bold">{selectedComic.translator || 'PNM Shinobi'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">📋 Tổng số chap</span>
                      <span className="text-slate-850 font-bold">{chapters.length || '0'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">📶 Tình trạng</span>
                      <span className="text-slate-850 font-bold">{selectedComic.status || 'Đang ra'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">🚼 Độ tuổi</span>
                      <span className="text-slate-850 font-bold">{selectedComic.ageRating || '13+'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">👍 Lượt thích</span>
                      <span className="text-slate-850 font-bold">{selectedComic.likesCount || '6,104'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 border-b border-dashed border-slate-100 md:border-none">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">🖤 Lượt theo dõi</span>
                      <span className="text-slate-850 font-bold">{selectedComic.followersCount || '28,886'}</span>
                    </div>
                    <div className="flex items-center gap-4 py-0.5 md:col-span-2">
                      <span className="w-28 text-slate-500 font-medium flex items-center gap-1.5">👁️ Lượt xem</span>
                      <span className="text-slate-850 font-bold">{selectedComic.viewsCount || '34,988,902'}</span>
                    </div>
                  </div>

                  {/* Category tags with orange borders */}
                  <div className="flex flex-wrap justify-center md:justify-start gap-2 pt-1">
                    <span className="px-3 py-1 bg-white border border-orange-300 text-orange-500 text-xs font-semibold rounded hover:bg-orange-50 cursor-pointer">
                      {selectedComic.category}
                    </span>
                    <span className="px-3 py-1 bg-white border border-orange-300 text-orange-500 text-xs font-semibold rounded hover:bg-orange-50 cursor-pointer">
                      Action
                    </span>
                    <span className="px-3 py-1 bg-white border border-orange-300 text-orange-500 text-xs font-semibold rounded hover:bg-orange-50 cursor-pointer">
                      Adventure
                    </span>
                    <span className="px-3 py-1 bg-white border border-orange-300 text-orange-500 text-xs font-semibold rounded hover:bg-orange-50 cursor-pointer">
                      Supernatural
                    </span>
                  </div>

                  {/* Big action buttons row */}
                  <div className="flex flex-wrap justify-center md:justify-start gap-3 pt-3">
                    <button 
                      onClick={() => chapters.length > 0 && handleReadChapter(chapters[0])}
                      disabled={chapters.length === 0}
                      className="px-6 py-3 bg-[#82b54b] hover:bg-[#719f40] text-white font-bold rounded flex items-center gap-1.5 text-sm transition-colors border-none disabled:opacity-50 cursor-pointer"
                    >
                      <BookOpen className="w-4 h-4" /> Đọc từ đầu
                    </button>
                    <button 
                      onClick={(e) => handleToggleFavorite(e, selectedComic)}
                      className="px-6 py-3 bg-[#e74c3c] hover:bg-[#d63b2b] text-white font-bold rounded flex items-center gap-1.5 text-sm transition-colors border-none cursor-pointer"
                    >
                      <Heart className="w-4 h-4 fill-white text-white" /> Theo dõi
                    </button>
                    <button 
                      onClick={() => alert('Cảm ơn bạn đã thích tác phẩm này!')}
                      className="px-6 py-3 bg-[#a824db] hover:bg-[#951fc5] text-white font-bold rounded flex items-center gap-1.5 text-sm transition-colors border-none cursor-pointer"
                    >
                      👍 Thích
                    </button>
                  </div>
                </div>
              </div>

              {/* Description box */}
              <div className="pt-6 border-t border-slate-200 space-y-2">
                <h2 className="text-base font-bold text-slate-800 flex items-center gap-1.5">
                  <Info className="w-4.5 h-4.5 text-[#df853b]" /> Giới Thiệu
                </h2>
                <p className="text-slate-650 text-sm leading-relaxed whitespace-pre-line pl-1">
                  {selectedComic.description || 'Truyện tranh hấp dẫn, định dạng PDF chất lượng cao, cập nhật liên tục các tập mới nhất phục vụ độc giả.'}
                </p>
              </div>

              {/* Chapters list */}
              <div className="space-y-3 pt-6 border-t border-slate-200">
                <h2 className="text-base font-bold text-slate-800 flex items-center gap-1.5">
                  <FileText className="w-4.5 h-4.5 text-[#df853b]" />
                  Danh Sách Chương ({chapters.length})
                </h2>

                {chapters.length === 0 ? (
                  <p className="text-xs text-slate-400 py-6 text-center">Chưa có tập nào được tải lên cho truyện này.</p>
                ) : (
                  <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-2">
                    {chapters.map((chap, idx) => (
                      <div 
                        key={chap.id}
                        onClick={() => handleReadChapter(chap)}
                        className="p-3 bg-slate-50 rounded border border-slate-200 hover:border-[#df853b] cursor-pointer flex items-center justify-between text-xs font-semibold hover:bg-slate-100 transition-all"
                      >
                        <span className="text-slate-700 font-bold">Chương {chap.chapterNumber}</span>
                        <ChevronRight className="w-3.5 h-3.5 text-slate-400" />
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* 3.8 COMIC READER (PDF VIEW) */}
          {currentView === 'read' && selectedComic && selectedChapter && (
            <div className="bg-white rounded border border-slate-200 p-4 md:p-6 space-y-4 animate-fade-in shadow-sm">
              <div className="flex items-center justify-between border-b border-slate-200 pb-3 gap-4">
                <button 
                  onClick={() => { handleSelectComic(selectedComic); }}
                  className="flex items-center gap-1 text-xs font-bold text-slate-500 hover:text-[#df853b]"
                >
                  <ArrowLeft className="w-3.5 h-3.5" /> Chi tiết truyện
                </button>

                <div className="text-center min-w-0">
                  <h2 className="font-bold text-slate-800 text-sm truncate">{selectedComic.title}</h2>
                  <span className="text-[10px] text-[#df853b] font-bold">Chương {selectedChapter.chapterNumber}</span>
                </div>

                <div className="flex items-center gap-1.5">
                  <button 
                    onClick={() => {
                      const currentIdx = chapters.findIndex(c => c.id === selectedChapter.id);
                      if (currentIdx > 0) {
                        setSelectedChapter(chapters[currentIdx - 1]);
                      }
                    }}
                    disabled={chapters.findIndex(c => c.id === selectedChapter.id) === 0}
                    className="p-1 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded disabled:opacity-30 transition-all border border-slate-200"
                  >
                    <ChevronLeft className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => {
                      const currentIdx = chapters.findIndex(c => c.id === selectedChapter.id);
                      if (currentIdx < chapters.length - 1) {
                        setSelectedChapter(chapters[currentIdx + 1]);
                      }
                    }}
                    disabled={chapters.findIndex(c => c.id === selectedChapter.id) === chapters.length - 1}
                    className="p-1 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded disabled:opacity-30 transition-all border border-slate-200"
                  >
                    <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Reader PDF Frame */}
              <div className="border border-slate-200 rounded overflow-hidden bg-slate-50 flex flex-col">
                <iframe 
                  src={selectedChapter.chapterPath.startsWith('http') ? selectedChapter.chapterPath : `${STORAGE_URL}${selectedChapter.chapterPath}`} 
                  title={`Chương ${selectedChapter.chapterNumber}`}
                  className="w-full border-none"
                  style={{ height: '78vh' }}
                />
                <div className="p-3 bg-slate-100/50 text-center border-t border-slate-200 flex justify-between items-center px-4 text-xs">
                  <span className="text-slate-500 text-[10px]">Trình đọc PDF tích hợp trên web</span>
                  <a 
                    href={selectedChapter.chapterPath.startsWith('http') ? selectedChapter.chapterPath : `${STORAGE_URL}${selectedChapter.chapterPath}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-[#df853b] hover:underline font-bold flex items-center gap-1"
                  >
                    <Eye className="w-3.5 h-3.5" /> Mở trong tab mới toàn màn hình
                  </a>
                </div>
              </div>
            </div>
          )}

          {/* 3.9 CREATOR PANEL (2 COLUMNS) */}
          {currentView === 'creator' && (
            <div className="bg-white rounded border border-slate-200 p-4 md:p-6 space-y-6 animate-fade-in shadow-sm">
              {user.role !== 'creator' && user.role !== 'admin' ? (
                <div className="max-w-md mx-auto text-center py-10 space-y-4">
                  <div className="w-16 h-16 rounded-full bg-orange-50 border border-orange-200 flex items-center justify-center mx-auto text-orange-500">
                    <Award className="w-8 h-8" />
                  </div>
                  <h2 className="text-lg font-bold text-slate-800 uppercase">Đăng ký làm Tác giả</h2>
                  <p className="text-xs text-slate-500 leading-relaxed">
                    Kích hoạt tính năng Creator để có quyền đăng truyện mới lên trang chủ và đăng tải các tệp chương PDF truyện của riêng bạn.
                  </p>

                  {errorMessage && (
                    <div className="bg-rose-50 border border-rose-200 text-rose-600 px-4 py-2 rounded text-xs text-center">
                      {errorMessage}
                    </div>
                  )}

                  <button 
                    onClick={handleBecomeCreator}
                    className="w-full py-2.5 rounded btn-qq-accent text-xs font-bold"
                  >
                    Kích Hoạt Tài Khoản Creator
                  </button>
                </div>
              ) : (
                // Creator Panel Dashboard
                <div className="space-y-6">
                  <div>
                    <h1 className="text-xl font-bold text-slate-800 uppercase border-b border-slate-200 pb-3">Bảng Quản Trị Tác Giả</h1>
                    <p className="text-xs text-slate-400 mt-1">Đăng truyện mới hoặc cập nhật tập chương PDF để hiển thị trực tiếp lên trang chủ.</p>
                  </div>

                  {errorMessage && (
                    <div className="bg-rose-50 border border-rose-200 text-rose-600 px-4 py-2 rounded text-xs text-center">
                      {errorMessage}
                    </div>
                  )}
                  {successMessage && (
                    <div className="bg-emerald-50 border border-emerald-200 text-emerald-600 px-4 py-2 rounded text-xs text-center">
                      {successMessage}
                    </div>
                  )}

                  {/* 2 columns layout on web */}
                  <div className="flex flex-col lg:flex-row gap-6 items-stretch">
                    
                    {/* Left: My Comics list */}
                    <div className="flex-1 rounded border border-slate-200 p-4 flex flex-col bg-slate-50/50 min-h-[300px]">
                      <h2 className="text-xs font-bold text-slate-700 mb-3 flex items-center gap-1.5 border-b border-slate-200 pb-2">
                        <Layers className="w-4 h-4 text-[#df853b]" />
                        Truyện của tôi đã đăng ({myComics.length})
                      </h2>

                      {myComics.length === 0 ? (
                        <div className="flex-1 flex flex-col items-center justify-center text-center py-10 text-xs text-slate-400">
                          Chưa có truyện nào. Sử dụng form bên phải để đăng tác phẩm đầu tiên!
                        </div>
                      ) : (
                        <div className="space-y-2.5 overflow-y-auto max-h-[420px] pr-1">
                          {myComics.map((c) => (
                            <div key={c.id} className="p-2.5 bg-white rounded border border-slate-200 flex gap-3 items-center">
                              <div className="w-10 h-14 bg-slate-100 rounded overflow-hidden flex-shrink-0">
                                <img 
                                  src={c.thumbnailPath.startsWith('http') ? c.thumbnailPath : `${STORAGE_URL}${c.thumbnailPath}`} 
                                  alt={c.title} 
                                  className="w-full h-full object-cover"
                                />
                              </div>
                              <div className="flex-1 min-w-0">
                                <h3 className="font-bold text-slate-800 text-xs truncate">{c.title}</h3>
                                <span className="text-[9px] bg-orange-50 text-orange-600 px-1.5 py-0.2 rounded font-bold mt-1 inline-block border border-orange-100">
                                  {c.category}
                                </span>
                              </div>
                              <button
                                onClick={() => {
                                  setNewChapterComicId(c.id.toString());
                                  setSuccessMessage('');
                                  setErrorMessage('');
                                  const el = document.getElementById('chapter-form-anchor');
                                  if (el) el.scrollIntoView({ behavior: 'smooth' });
                                }}
                                className="px-2 py-1 bg-[#df853b]/10 hover:bg-[#df853b] text-[#df853b] hover:text-white rounded text-[10px] font-bold transition-all border border-[#df853b]/20"
                              >
                                + Thêm chương
                              </button>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>

                    {/* Right: upload forms */}
                    <div className="w-full lg:w-[450px] space-y-6">
                      
                      {/* Form Add Comic */}
                      <div className="rounded border border-slate-200 p-4 bg-white">
                        <h2 className="text-xs font-bold text-slate-700 mb-3 flex items-center gap-1 border-b border-slate-200 pb-2">
                          <Plus className="w-3.5 h-3.5 text-[#df853b]" /> Đăng truyện mới
                        </h2>
                        <form onSubmit={handleCreateComic} className="space-y-3">
                          <div className="grid grid-cols-2 gap-3">
                            <div>
                              <label className="block text-[10px] font-bold text-slate-500 mb-1">Tên truyện</label>
                              <input 
                                type="text" 
                                required
                                placeholder="Nhập tên..."
                                className="w-full px-2.5 py-1.5 rounded qq-input text-xs"
                                value={newComicTitle}
                                onChange={(e) => setNewComicTitle(e.target.value)}
                              />
                            </div>
                            <div>
                              <label className="block text-[10px] font-bold text-slate-500 mb-1">Thể loại</label>
                              <select 
                                className="w-full px-2.5 py-1.5 rounded qq-input text-xs bg-white"
                                value={newComicCategory}
                                onChange={(e) => setNewComicCategory(e.target.value)}
                              >
                                {categories.slice(1).map(cat => (
                                  <option key={cat} value={cat}>{cat}</option>
                                ))}
                              </select>
                            </div>
                          </div>

                          <div>
                            <label className="block text-[10px] font-bold text-slate-500 mb-1">Hình ảnh bìa</label>
                            <input 
                              id="comic-thumbnail-input"
                              type="file" 
                              accept="image/*"
                              required
                              className="w-full px-2 py-1 rounded qq-input text-xs file:mr-2 file:py-0.5 file:px-2 file:rounded file:border-0 file:text-[9px] file:bg-[#df853b] file:text-white cursor-pointer"
                              onChange={(e) => setNewComicThumbnail(e.target.files[0])}
                            />
                          </div>

                          <button 
                            type="submit" 
                            disabled={loading}
                            className="w-full py-2 rounded btn-qq-accent text-xs font-bold shadow-sm"
                          >
                            {loading ? 'Đang tạo...' : 'Tạo Truyện Mới'}
                          </button>
                        </form>
                      </div>

                      {/* Form Add Chapter */}
                      <div id="chapter-form-anchor" className="rounded border border-slate-200 p-4 bg-white">
                        <h2 className="text-xs font-bold text-slate-700 mb-3 flex items-center gap-1 border-b border-slate-200 pb-2">
                          <Upload className="w-3.5 h-3.5 text-[#df853b]" /> Thêm chương mới (tải lên PDF)
                        </h2>
                        <form onSubmit={handleCreateChapter} className="space-y-3">
                          <div className="grid grid-cols-2 gap-3">
                            <div>
                              <label className="block text-[10px] font-bold text-slate-500 mb-1">Chọn truyện</label>
                              <select 
                                required
                                className="w-full px-2.5 py-1.5 rounded qq-input text-xs bg-white"
                                value={newChapterComicId}
                                onChange={(e) => setNewChapterComicId(e.target.value)}
                              >
                                <option value="">-- Chọn --</option>
                                {myComics.map(c => (
                                  <option key={c.id} value={c.id}>{c.title}</option>
                                ))}
                              </select>
                            </div>
                            <div>
                              <label className="block text-[10px] font-bold text-slate-500 mb-1">Tập chương số</label>
                              <input 
                                type="number" 
                                required
                                min="1"
                                placeholder="Ví dụ: 1"
                                className="w-full px-2.5 py-1.5 rounded qq-input text-xs"
                                value={newChapterNumber}
                                onChange={(e) => setNewChapterNumber(e.target.value)}
                              />
                            </div>
                          </div>

                          <div>
                            <label className="block text-[10px] font-bold text-slate-500 mb-1">File PDF nội dung chương</label>
                            <input 
                              id="chapter-pdf-input"
                              type="file" 
                              accept="application/pdf"
                              required
                              className="w-full px-2 py-1 rounded qq-input text-xs file:mr-2 file:py-0.5 file:px-2 file:rounded file:border-0 file:text-[9px] file:bg-[#df853b] file:text-white cursor-pointer"
                              onChange={(e) => setNewChapterPdf(e.target.files[0])}
                            />
                          </div>

                          <button 
                            type="submit" 
                            disabled={loading || myComics.length === 0}
                            className="w-full py-2 rounded btn-qq-accent text-xs font-bold shadow-sm"
                          >
                            {loading ? 'Đang lưu...' : 'Tải lên chương PDF'}
                          </button>
                        </form>
                      </div>

                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

        </div>
      </main>

      {/* 4. FOOTER (like TRUYENQQ) */}
      <footer className="bg-slate-900 text-slate-400 py-6 mt-8 border-t-4 border-[#df853b]">
        <div className="main-container text-center space-y-2">
          <p className="text-white text-sm font-bold">🐧 TRUYENWEB - Đọc truyện tranh PDF trực tuyến chất lượng cao</p>
          <p className="text-xs">Mọi thông tin và hình ảnh trên website đều được sưu tầm từ internet và do thành viên tải lên. Chúng tôi không chịu trách nhiệm bản quyền.</p>
          <p className="text-[11px] text-slate-500 pt-2">© 2026 ComicWeb - Phiên bản lấy cảm hứng từ TruyenQQ.</p>
        </div>
      </footer>
    </div>
  );
}
