# Comic App REST API Backend

Đây là phần backend hoàn chỉnh cho ứng dụng đọc truyện tranh (Comic App), được viết bằng **Node.js** và **Express**. 

Backend sử dụng một hệ thống lưu trữ dữ liệu dạng JSON file (không cần cài đặt cơ sở dữ liệu cồng kềnh, hoạt động 100% ổn định trên Windows/macOS/Linux) cùng với các tính năng mã hóa mật khẩu, JWT authentication và quản lý phục vụ tệp tin tĩnh (hình ảnh thumbnail và file PDF chương).

## 🚀 Công nghệ sử dụng
- **Node.js** & **Express** làm Web API Framework.
- **Bcryptjs** để mã hóa bảo mật mật khẩu (Không dùng thư viện biên dịch C++, tránh lỗi cài đặt trên Windows).
- **Jsonwebtoken (JWT)** để xác thực phiên đăng nhập của người dùng.
- **Morgan** & **CORS** để ghi log và cho phép thiết bị di động truy cập chéo.

---

## 📁 Cấu trúc thư mục backend
```text
backend/
├── config/
├── database/
│   ├── data/            # Thư mục lưu trữ database JSON (users, comics, chapters)
│   ├── database.js      # Lớp truy xuất cơ sở dữ liệu
│   └── seed.js          # Script đồng bộ copy assets từ Flutter & thêm dữ liệu mẫu
├── public/
│   └── uploads/
│       ├── chapters/    # Lưu trữ các file PDF chương truyện
│       └── thumbnails/  # Lưu trữ ảnh bìa truyện
├── routes/
│   ├── auth.js          # Các API liên quan tới Đăng nhập/Đăng ký/Profile
│   └── comics.js        # Các API liên quan tới Truyện & Chương truyện
├── package.json
├── server.js            # Điểm khởi chạy Express server
└── README.md
```

---

## 🛠️ Hướng dẫn cài đặt và chạy thử

### Bước 1: Di chuyển vào thư mục backend
Mở terminal và di chuyển vào thư mục backend:
```bash
cd backend
```

### Bước 2: Cài đặt thư viện dependencies
```bash
npm install
```

### Bước 3: Đồng bộ dữ liệu mẫu (Seeding)
Chạy lệnh seeder để tự động sao chép toàn bộ các tệp tin PDF và hình ảnh thumbnail từ thư mục assets của Flutter sang thư mục `public/uploads` của backend, đồng thời tạo tài khoản mẫu và danh sách truyện tương ứng:
```bash
npm run seed
```

### Bước 4: Khởi chạy Server
Khởi động máy chủ backend tại cổng `3000`:
```bash
npm start
```
Khi chạy thành công, màn hình sẽ hiển thị:
```text
==================================================
  Comic App Backend Server running on port 3000
  Local URL: http://localhost:3000
  Static uploads directory served at http://localhost:3000/uploads
==================================================
```

---

## 📱 Cấu hình kết nối từ ứng dụng Flutter
Trong mã nguồn Flutter, tệp cấu hình chính nằm tại:
`lib/services/api_service.dart`

Bạn cần chú ý cấu hình IP `baseUrl` và `baseStorageUrl` cho phù hợp:
- **Nếu chạy trên máy ảo Android (Android Emulator):** Giữ nguyên mặc định `http://10.0.2.2:3000/api` (Android tự động định tuyến `10.0.2.2` về localhost của máy tính).
- **Nếu chạy trên máy ảo iOS (iOS Simulator):** Đổi IP thành `http://localhost:3000/api`.
- **Nếu chạy trên thiết bị di động thật (Physical Device):** Thay đổi thành địa chỉ IP Wi-Fi cục bộ của máy tính đang chạy server (Ví dụ: `http://192.168.1.35:3000/api`). Chú ý điện thoại và máy tính phải kết nối chung một mạng Wi-Fi.

---

## 🔑 Tài khoản thử nghiệm mặc định
Sau khi chạy lệnh `npm run seed`, hệ thống đã tạo sẵn một tài khoản test để bạn thử đăng nhập:
- **Email:** `example@example.com`
- **Mật khẩu:** `123456`

---

## 📡 Danh sách các API Endpoints công bố

### 1. Xác thực người dùng (Authentication)
| Phương thức | Endpoint | Mô tả | Body yêu cầu |
|:---:|:---|:---|:---|
| **POST** | `/api/auth/register` | Đăng ký tài khoản mới | `{ "email": "...", "password": "..." }` |
| **POST** | `/api/auth/login` | Đăng nhập tài khoản | `{ "email": "...", "password": "..." }` |
| **GET** | `/api/auth/me` | Lấy profile user hiện tại | Cần Header `Authorization: Bearer <Token>` |

### 2. Quản lý Truyện & Chương (Comics & Chapters)
| Phương thức | Endpoint | Mô tả |
|:---:|:---|:---|
| **GET** | `/api/comics` | Lấy danh sách toàn bộ truyện (Hỗ trợ query `?category=Hành động` hoặc `?search=One Piece`) |
| **GET** | `/api/comics/favorites` | Lấy danh sách truyện yêu thích |
| **GET** | `/api/comics/:id` | Lấy chi tiết truyện theo ID |
| **PUT** | `/api/comics/:id/favorite` | Thay đổi trạng thái yêu thích (Body: `{ "isFavorite": true }`) |
| **GET** | `/api/comics/:id/chapters` | Lấy danh sách chương của truyện theo ID truyện |

### 3. Phục vụ tài nguyên tĩnh (Static Files)
- **Ảnh Thumbnail:** `http://<IP-SERVER>:3000/uploads/thumbnails/<tên_ảnh>.jpg`
- **Tài liệu PDF:** `http://<IP-SERVER>:3000/uploads/chapters/<tên_chương>.pdf`
