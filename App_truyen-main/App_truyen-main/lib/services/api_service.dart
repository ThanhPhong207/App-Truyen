import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comic.dart';
import '../models/chapter.dart';
import '../models/user.dart';

class ApiService {
  // CONFIGURATION
  static const String baseUrl = 'https://app-truyen-backend.onrender.com/api';
  static const String baseStorageUrl = 'https://app-truyen-backend.onrender.com';

  // Shared Preferences Keys
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'auth_user_email';
  static const String _userIdKey = 'auth_user_id';
  static const String _userRoleKey = 'auth_user_role';
  static const String _userDisplayNameKey = 'auth_user_display_name';
  static const String _userProviderKey = 'auth_user_provider';

  // AUTHENTICATION GETTERS & SETTERS
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveSession(String token, int userId, String email, String role, {String displayName = '', String provider = 'local'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userDisplayNameKey, displayName);
    await prefs.setString(_userProviderKey, provider);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userDisplayNameKey);
    await prefs.remove(_userProviderKey);
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // AUTH API
  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];
        
        await saveSession(
          token, 
          userData['id'], 
          userData['email'], 
          userData['role'] ?? 'user',
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? 'local',
        );
        return User(
          id: userData['id'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? 'local',
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<User?> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        await saveSession(
          token, 
          userData['id'], 
          userData['email'], 
          userData['role'] ?? 'user',
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? 'local',
        );
        return User(
          id: userData['id'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? 'local',
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> socialLogin(String email, String provider) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/social-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'provider': provider}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];
        final isNewUser = data['isNewUser'] ?? false;
        
        await saveSession(
          token, 
          userData['id'], 
          userData['email'], 
          userData['role'] ?? 'user',
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? provider,
        );
        return {
          'user': User(
            id: userData['id'],
            email: userData['email'],
            role: userData['role'] ?? 'user',
            displayName: userData['displayName'] ?? '',
            provider: userData['provider'] ?? provider,
          ),
          'isNewUser': isNewUser
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng nhập nhanh thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<User?> updateDisplayName(String displayName) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-name'),
        headers: headers,
        body: jsonEncode({'displayName': displayName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDisplayNameKey, userData['displayName'] ?? '');

        return User(
          id: userData['id'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? 'local',
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Cập nhật tên thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User(
          id: userData['id'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? 'local',
        );
      }
      return null;
    } catch (e) {
      print('getCurrentUser error: $e');
      return null;
    }
  }

  static Future<User?> becomeCreator() async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/become-creator'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userRoleKey, userData['role']);
        
        return User(
          id: userData['id'],
          email: userData['email'],
          role: userData['role'],
          displayName: userData['displayName'] ?? '',
          provider: userData['provider'] ?? 'local',
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể đăng ký làm tác giả');
      }
    } catch (e) {
      rethrow;
    }
  }

  // COMICS API
  static Future<List<Comic>> getComics({String? category, String? search}) async {
    try {
      final queryParameters = <String, String>{};
      if (category != null && category != 'Tất cả') {
        queryParameters['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/comics').replace(queryParameters: queryParameters);
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Comic.fromMap(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách truyện');
      }
    } catch (e) {
      print('getComics error: $e');
      return [];
    }
  }

  static Future<List<Comic>> getFavoriteComics() async {
    try {
      final uri = Uri.parse('$baseUrl/comics/favorites');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Comic.fromMap(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách truyện yêu thích');
      }
    } catch (e) {
      print('getFavoriteComics error: $e');
      return [];
    }
  }

  static Future<void> toggleFavorite(int comicId, bool isFavorite) async {
    try {
      final uri = Uri.parse('$baseUrl/comics/$comicId/favorite');
      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'isFavorite': isFavorite}),
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể cập nhật trạng thái yêu thích');
      }
    } catch (e) {
      print('toggleFavorite error: $e');
      rethrow;
    }
  }

  // CHAPTERS API
  static Future<List<Chapter>> getChapters(int comicId) async {
    try {
      final uri = Uri.parse('$baseUrl/comics/$comicId/chapters');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Chapter.fromMap(item)).toList();
      } else {
        throw Exception('Không thể tải danh sách chương');
      }
    } catch (e) {
      print('getChapters error: $e');
      return [];
    }
  }

  // CREATOR API
  static Future<List<Comic>> getMyComics() async {
    try {
      final uri = Uri.parse('$baseUrl/creator/my-comics');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Comic.fromMap(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách truyện của bạn');
      }
    } catch (e) {
      print('getMyComics error: $e');
      return [];
    }
  }

  static Future<bool> uploadComic(String title, String category, File thumbnail) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/creator/comics');
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields['title'] = title;
      request.fields['category'] = category;
      
      final stream = http.ByteStream(thumbnail.openRead());
      final length = await thumbnail.length();
      final multipartFile = http.MultipartFile(
        'thumbnail',
        stream,
        length,
        filename: path.basename(thumbnail.path),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print('uploadComic error: $e');
      return false;
    }
  }

  static Future<bool> uploadChapter(int comicId, int chapterNumber, File pdf) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/creator/comics/$comicId/chapters');
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields['chapterNumber'] = chapterNumber.toString();
      
      final stream = http.ByteStream(pdf.openRead());
      final length = await pdf.length();
      final multipartFile = http.MultipartFile(
        'pdf',
        stream,
        length,
        filename: path.basename(pdf.path),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print('uploadChapter error: $e');
      return false;
    }
  }

  // ADMIN API
  static Future<List<User>> adminGetUsers() async {
    try {
      final uri = Uri.parse('$baseUrl/admin/users');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => User.fromMap(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách người dùng');
      }
    } catch (e) {
      print('adminGetUsers error: $e');
      return [];
    }
  }

  static Future<bool> adminUpdateUserRole(int userId, String role) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/users/$userId/role');
      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'role': role}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('adminUpdateUserRole error: $e');
      return false;
    }
  }

  static Future<bool> adminDeleteComic(int comicId) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/comics/$comicId');
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      print('adminDeleteComic error: $e');
      return false;
    }
  }

  static Future<bool> adminDeleteChapter(int chapterId) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/chapters/$chapterId');
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      print('adminDeleteChapter error: $e');
      return false;
    }
  }

  // PDF DOWNLOAD & CACHING HELPERS
  static Future<String> getLocalPdfPath(String relativePdfUrl) async {
    try {
      final url = relativePdfUrl.startsWith('http') 
          ? relativePdfUrl 
          : '$baseStorageUrl$relativePdfUrl';
          
      final fileName = path.basename(url);
      final cacheDir = await getTemporaryDirectory();
      final localPath = path.join(cacheDir.path, 'downloaded_chapters', fileName);
      final file = File(localPath);

      if (await file.exists()) {
        print('Using cached PDF: $localPath');
        return localPath;
      }

      print('Downloading PDF from: $url');
      await Directory(path.dirname(localPath)).create(recursive: true);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('PDF downloaded successfully and saved to: $localPath');
        return localPath;
      } else {
        throw Exception('Failed to download PDF: HTTP Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      rethrow;
    }
  }
}
