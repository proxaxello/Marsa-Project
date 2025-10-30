# Marsa App - Authentication Guide

## Tình trạng hiện tại

App Marsa yêu cầu đăng nhập với backend API tại `http://10.0.2.2:3001` (cho Android emulator).

## ⚠️ Giải pháp tạm thời (Development Mode)

Để test Dictionary screen và các tính năng khác **KHÔNG CẦN BACKEND**, tôi đã bypass authentication:

### Thay đổi trong `auth_bloc.dart`:
```dart
// Auto-authenticate khi app khởi động
emit(const AuthAuthenticated(token: 'test_token_for_development'));
```

**Điều này cho phép:**
- ✅ Vào app ngay lập tức không cần đăng nhập
- ✅ Test Dictionary screen với database local
- ✅ Test tất cả tính năng offline
- ✅ Không cần chạy backend server

## 🔧 Khi nào cần Backend?

Backend chỉ cần thiết cho:
- Đăng ký tài khoản mới
- Đăng nhập với tài khoản
- Đồng bộ dữ liệu giữa các thiết bị
- AI Tutor (nếu dùng API từ server)

## 📝 Cách hoạt động của Authentication

### 1. **Login Flow** (Khi có backend)
```
User nhập email/password
    ↓
POST /api/login
    ↓
Server trả về JWT token
    ↓
Lưu token vào SharedPreferences
    ↓
Dùng token cho các API calls khác
```

### 2. **Register Flow** (Khi có backend)
```
User nhập email/password/name
    ↓
POST /api/register
    ↓
Server tạo tài khoản
    ↓
User phải login lại
```

### 3. **Token Validation**
```
App khởi động
    ↓
Kiểm tra token trong SharedPreferences
    ↓
Nếu có token → GET /api/profile để validate
    ↓
Nếu valid → Vào app
Nếu invalid → Xóa token, yêu cầu login
```

## 🚀 Cách setup Backend (Nếu cần)

### Backend cần có các endpoints:

#### 1. POST /api/register
```json
Request:
{
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name" // optional
}

Response (201):
{
  "message": "User registered successfully"
}

Error (400):
{
  "error": "Email already exists"
}
```

#### 2. POST /api/login
```json
Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

Error (401):
{
  "error": "Invalid credentials"
}
```

#### 3. GET /api/profile
```json
Headers:
Authorization: Bearer <token>

Response (200):
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "User Name"
}

Error (401):
{
  "error": "Invalid or expired token"
}
```

## 🔐 Tài khoản Test (Nếu có backend)

Nếu bạn setup backend, tạo tài khoản test:

```
Email: test@marsa.com
Password: test123456
Name: Test User
```

## 📱 Cách test app KHÔNG CẦN backend

### Hiện tại (Development Mode):
1. ✅ Mở app → Tự động vào MainScreen
2. ✅ Nhấn tab Dictionary → Xem Neo-Brutalism UI
3. ✅ Thêm/xóa/tìm kiếm từ → Hoạt động với SQLite local
4. ✅ Favorite, category filter → Hoạt động offline
5. ✅ Text-to-speech → Hoạt động offline

### Các tính năng hoạt động OFFLINE:
- ✅ Dictionary (SQLite)
- ✅ Flashcards (SQLite)
- ✅ Practice modes
- ✅ Voice Lab (local recording)
- ✅ Settings

### Các tính năng CẦN backend:
- ❌ Login/Register
- ❌ Sync data across devices
- ❌ AI Tutor (nếu dùng server API)
- ❌ Leaderboard (nếu có)

## 🔄 Cách BẬT LẠI authentication (Khi có backend)

### Bước 1: Sửa `auth_bloc.dart`
Xóa dòng bypass và uncomment code gốc:

```dart
// XÓA DÒNG NÀY:
emit(const AuthAuthenticated(token: 'test_token_for_development'));
return;

// UNCOMMENT CODE GỐC:
final token = await _authRepository.getToken();
if (token != null && token.isNotEmpty) {
  try {
    final userInfo = await _authRepository.getProfile();
    emit(AuthAuthenticated(token: token, userInfo: userInfo));
  } catch (e) {
    await _authRepository.deleteToken();
    emit(const AuthUnauthenticated());
  }
} else {
  emit(const AuthUnauthenticated());
}
```

### Bước 2: Cấu hình Backend URL

Sửa `auth_provider.dart`:

```dart
// Cho Android Emulator:
static const String baseUrl = 'http://10.0.2.2:3001';

// Cho iOS Simulator:
static const String baseUrl = 'http://localhost:3001';

// Cho Physical Device (thay YOUR_IP):
static const String baseUrl = 'http://YOUR_IP:3001';
```

### Bước 3: Rebuild app
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## 📊 Database Structure

App sử dụng SQLite local cho:

### Dictionary Table
```sql
CREATE TABLE dictionary (
  id INTEGER PRIMARY KEY,
  word TEXT NOT NULL,
  meaning TEXT NOT NULL,
  example_sentence TEXT,
  example_translation TEXT,
  category TEXT,
  difficulty TEXT,
  is_favorite INTEGER DEFAULT 0,
  folder_id INTEGER
);
```

### Folders Table
```sql
CREATE TABLE folders (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TEXT
);
```

## 🎯 Tóm tắt

### Để test Dictionary screen NGAY BÂY GIỜ:
1. ✅ App đã được bypass authentication
2. ✅ Rebuild app đang chạy
3. ✅ Mở app → Tự động vào
4. ✅ Nhấn tab Dictionary (icon sách)
5. ✅ Enjoy Neo-Brutalism UI! 🎨

### Khi cần production:
1. Setup backend với 3 endpoints trên
2. Uncomment code authentication gốc
3. Rebuild app
4. Test login/register flow

---

**Lưu ý**: Development mode hiện tại CHỈ để test UI và tính năng offline. Không dùng cho production!
