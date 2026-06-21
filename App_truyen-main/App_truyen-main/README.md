# do_an_truyen

link figma: https://www.figma.com/design/coVXQTp6lzhg17LrYvHgGg/%C4%90%E1%BB%93-%C3%A1n-App-truy%E1%BB%87n?node-id=0-1&p=f&t=xzI2idFB0w2XVel2-0


I. Giới thiệu

📖 Đây là một ứng dụng đọc truyện được phát triển trên nền tảng Android, giúp người dùng dễ dàng khám phá, tìm kiếm và theo dõi truyện yêu thích. Ứng dụng được thiết kế nhằm mang lại trải nghiệm đọc truyện mượt mà, hiện đại và tiện lợi.

II. Tính năng chính

1. Trang chủ
   
📊 Hiển thị danh sách các truyện phổ biến nhất.

❤️ Truyện yêu thích: Danh sách truyện mà người dùng đã đánh dấu yêu thích.

📚 Tìm kiếm: chức năng tìm kiếm giúp truy cập đến truyện muốn tìm

3. Quản lý tài khoản

🚪 Đăng xuất tài khoản.

# Comic App (MVVM)

Ứng dụng đọc truyện tranh sử dụng SQLite và mô hình MVVM.


## Cấu trúc thư mục
- `lib/models/`: Chứa các mô hình dữ liệu (Comic, Chapter, User).
- `lib/services/`: Chứa các dịch vụ (DatabaseHelper, FileHelper).
- `lib/viewmodels/`: Chứa các ViewModel.
- `lib/views/`: Chứa các màn hình giao diện (View).
- `lib/widgets/`: Chứa các widget tái sử dụng.
- `assets/`: Chứa file tĩnh (ảnh bìa, file PDF).

## Cách chạy
1. Thêm file ảnh bìa và PDF vào `assets/thumbnails/` và `assets/chapters/`.
2. Chạy lệnh:flutter pub get
             flutter run
3. ## Thêm truyện mới
- Thêm file ảnh bìa và PDF vào thư mục `assets/`.
- Cập nhật hàm `_addSampleData()` trong `main.dart` để thêm truyện mới

  ![image](https://github.com/user-attachments/assets/ac64045d-771a-460a-9222-2c3ccfb03cba)

