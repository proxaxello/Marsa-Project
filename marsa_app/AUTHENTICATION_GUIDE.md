# Authentication Implementation Guide

## Tổng quan

Ứng dụng Marsa đã triển khai hệ thống xác thực (Authentication) hoàn chỉnh sử dụng JWT (JSON Web Tokens) và BLoC pattern. Hệ thống này kết nối Flutter frontend với Node.js backend.

## Kiến trúc

### Tầng Dữ Liệu (Data Layer)

#### 1. AuthProvider (`lib/data/providers/auth_provider.dart`)

Provider chịu trách nhiệm giao tiếp trực tiếp với backend API và quản lý token trong SharedPreferences.

**Chức năng:**
- `login(email, password)` - Gọi API `/api/login`, trả về JWT token
- `register(email, password, name)` - Gọi API `/api/register`
- `saveToken(token)` - Lưu token vào SharedPreferences
- `getToken()` - Lấy token từ SharedPreferences
- `deleteToken()` - Xóa token (logout)
- `isAuthenticated()` - Kiểm tra có token hay không
- `getProfile()` - Lấy thông tin user (validate token)

**Backend URL:**
- Android Emulator: `http://10.0.2.2:3001`
- iOS Simulator: `http://localhost:3001`
- Physical Device: Sử dụng IP thực của máy chạy backend

#### 2. AuthRepository (`lib/data/repositories/auth_repository.dart`)

Repository là lớp trung gian giữa BLoC và Provider, cung cấp interface sạch cho business logic.

### Tầng Logic (Business Logic Layer)

#### 1. Auth Events (`lib/logic/blocs/auth/auth_event.dart`)

**Events:**
- `AppStarted` - Khi app khởi động, kiểm tra token
- `LoggedIn(token)` - Khi user đăng nhập thành công
- `LoggedOut` - Khi user đăng xuất
- `LoginRequested(email, password)` - Yêu cầu đăng nhập
- `RegisterRequested(email, password, name)` - Yêu cầu đăng ký

#### 2. Auth States (`lib/logic/blocs/auth/auth_state.dart`)

**States:**
- `AuthInitial` - Trạng thái ban đầu
- `AuthLoading` - Đang xử lý authentication
- `AuthAuthenticated(token, userInfo)` - Đã xác thực
- `AuthUnauthenticated` - Chưa xác thực
- `AuthFailure(error)` - Xác thực thất bại
- `RegistrationSuccess(message)` - Đăng ký thành công

#### 3. AuthBloc (`lib/logic/blocs/auth/auth_bloc.dart`)

BLoC xử lý tất cả logic authentication:

**Xử lý AppStarted:**
1. Lấy token từ SharedPreferences
2. Nếu có token, validate bằng cách gọi `/api/profile`
3. Nếu valid → `AuthAuthenticated`
4. Nếu không valid hoặc không có token → `AuthUnauthenticated`

**Xử lý LoginRequested:**
1. Emit `AuthLoading`
2. Validate input (email, password không rỗng)
3. Gọi API login
4. Lưu token
5. Lấy user profile
6. Emit `AuthAuthenticated` hoặc `AuthFailure`

**Xử lý RegisterRequested:**
1. Emit `AuthLoading`
2. Validate input (email, password, độ dài password >= 6)
3. Gọi API register
4. Emit `RegistrationSuccess`
5. Sau 500ms, emit `AuthUnauthenticated` (user cần login)

**Xử lý LoggedOut:**
1. Xóa token từ SharedPreferences
2. Emit `AuthUnauthenticated`

### Tầng Giao Diện (Presentation Layer)

#### 1. LoginScreen (`lib/presentation/screens/login_screen.dart`)

**Tính năng:**
- Form validation (email, password)
- Toggle hiển thị/ẩn password
- Loading indicator khi đang login
- Error handling với SnackBar
- Navigation tới RegistrationScreen

**BLoC Integration:**
```dart
// Dispatch login event
context.read<AuthBloc>().add(
  LoginRequested(
    email: email,
    password: password,
  ),
);

// Listen to state changes
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailure) {
      // Show error
    }
    // Navigation handled by main.dart
  },
)
```

#### 2. RegistrationScreen (`lib/presentation/screens/registration_screen.dart`)

**Tính năng:**
- Form validation (email, password, confirm password)
- Name field (optional)
- Password strength validation (>= 6 characters)
- Password match validation
- Loading indicator khi đang register
- Success/Error handling với SnackBar
- Auto navigate back to login sau register thành công

**BLoC Integration:**
```dart
// Dispatch register event
context.read<AuthBloc>().add(
  RegisterRequested(
    email: email,
    password: password,
    name: name,
  ),
);

// Listen to state changes
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is RegistrationSuccess) {
      // Show success, navigate back
    }
    if (state is AuthFailure) {
      // Show error
    }
  },
)
```

#### 3. Main App (`lib/main.dart`)

**Khởi tạo:**
```dart
void main() async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Create Dio for API calls
  final dio = Dio();
  
  // Create AuthProvider and AuthRepository
  final authProvider = AuthProvider(dio, prefs);
  final authRepository = AuthRepository(authProvider);
  
  // Provide repositories and blocs
  runApp(MarsaApp(authRepository: authRepository, ...));
}
```

**BLoC Provider:**
```dart
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc(
    context.read<AuthRepository>(),
  )..add(const AppStarted()), // Check auth on startup
),
```

**Routing Logic:**
```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, authState) {
    // Show splash while checking
    if (authState is AuthInitial || authState is AuthLoading) {
      return SplashScreen();
    }
    
    // Show main app if authenticated
    if (authState is AuthAuthenticated) {
      return MainScreen();
    }
    
    // Show login if not authenticated
    return LoginScreen();
  },
)
```

## Luồng Hoạt Động

### 1. App Startup Flow

```
App Start
   ↓
AppStarted Event
   ↓
AuthBloc checks token
   ↓
   ├─ Token exists → Validate with /api/profile
   │     ├─ Valid → AuthAuthenticated → MainScreen
   │     └─ Invalid → AuthUnauthenticated → LoginScreen
   │
   └─ No token → AuthUnauthenticated → LoginScreen
```

### 2. Login Flow

```
User enters credentials
   ↓
LoginRequested Event
   ↓
AuthLoading State (show loading)
   ↓
Call /api/login
   ↓
   ├─ Success
   │    ↓
   │  Save token
   │    ↓
   │  Get profile
   │    ↓
   │  AuthAuthenticated State
   │    ↓
   │  Navigate to MainScreen (automatic)
   │
   └─ Failure
        ↓
      AuthFailure State
        ↓
      Show error SnackBar
```

### 3. Registration Flow

```
User enters details
   ↓
RegisterRequested Event
   ↓
AuthLoading State (show loading)
   ↓
Call /api/register
   ↓
   ├─ Success
   │    ↓
   │  RegistrationSuccess State
   │    ↓
   │  Show success message
   │    ↓
   │  Wait 500ms
   │    ↓
   │  AuthUnauthenticated State
   │    ↓
   │  Navigate back to LoginScreen
   │
   └─ Failure
        ↓
      AuthFailure State
        ↓
      Show error SnackBar
```

### 4. Logout Flow

```
User clicks logout
   ↓
LoggedOut Event
   ↓
Delete token from SharedPreferences
   ↓
AuthUnauthenticated State
   ↓
Navigate to LoginScreen (automatic)
```

## Bảo mật

### 1. Token Storage

- Token được lưu trong `SharedPreferences` với key `auth_token`
- SharedPreferences là secure storage trên cả Android và iOS
- Token không bao giờ được log hoặc expose

### 2. Token Validation

- Token được validate mỗi khi app khởi động
- Gọi `/api/profile` để kiểm tra token còn valid
- Nếu token expired (401/403), tự động xóa và yêu cầu login lại

### 3. Password Handling

- Password không bao giờ được lưu local
- Password được gửi qua HTTPS (trong production)
- Minimum password length: 6 characters

### 4. Error Messages

- Error messages từ backend được hiển thị cho user
- Không expose sensitive information trong error messages

## Testing

### Unit Tests

```dart
// Test AuthBloc
test('emits AuthAuthenticated when login succeeds', () async {
  // Arrange
  when(() => authRepository.login(any(), any()))
      .thenAnswer((_) async => 'fake_token');
  
  // Act
  authBloc.add(LoginRequested(
    email: 'test@example.com',
    password: 'password123',
  ));
  
  // Assert
  await expectLater(
    authBloc.stream,
    emitsInOrder([
      AuthLoading(),
      AuthAuthenticated(token: 'fake_token'),
    ]),
  );
});
```

### Integration Tests

```dart
testWidgets('login flow works end-to-end', (tester) async {
  // Pump app
  await tester.pumpWidget(MyApp());
  
  // Enter credentials
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.enterText(find.byType(TextField).last, 'password123');
  
  // Tap login
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  
  // Verify navigation to MainScreen
  expect(find.byType(MainScreen), findsOneWidget);
});
```

## Troubleshooting

### 1. Cannot connect to backend

**Problem:** `Network error: Failed host lookup`

**Solutions:**
- Android Emulator: Use `10.0.2.2` instead of `localhost`
- iOS Simulator: Use `localhost`
- Physical Device: Use actual IP address of your computer
- Check backend is running on port 3001
- Check firewall settings

### 2. Token not persisting

**Problem:** User logged out after app restart

**Solutions:**
- Check SharedPreferences is initialized in `main()`
- Verify `AppStarted` event is dispatched on app start
- Check token is being saved after successful login

### 3. Invalid token error

**Problem:** Token expired or invalid

**Solutions:**
- Backend JWT expiration is set to 24h
- Token is automatically deleted when invalid
- User will be redirected to login screen

### 4. Registration succeeds but can't login

**Problem:** User registered but login fails

**Solutions:**
- Check backend is returning correct response
- Verify email/password match what was registered
- Check backend database for user record

## Best Practices

1. **Always validate input** before sending to backend
2. **Handle all error cases** gracefully
3. **Show loading indicators** during async operations
4. **Use BlocListener** for side effects (navigation, snackbars)
5. **Use BlocBuilder** for UI updates
6. **Keep business logic in BLoC**, not in UI
7. **Test authentication flows** thoroughly
8. **Never log sensitive data** (passwords, tokens)

## Future Enhancements

1. **Biometric Authentication** - Fingerprint/Face ID
2. **Remember Me** - Optional persistent login
3. **Social Login** - Google, Facebook, Apple
4. **Password Reset** - Forgot password flow
5. **Email Verification** - Verify email after registration
6. **Refresh Tokens** - Auto-refresh expired tokens
7. **Multi-device Support** - Manage multiple sessions
8. **Security Questions** - Additional account recovery

## API Endpoints Used

### POST /api/register
```json
Request:
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe" // optional
}

Response (201):
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### POST /api/login
```json
Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

### GET /api/profile
```
Headers:
Authorization: Bearer <token>

Response (200):
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.4      # BLoC pattern
  equatable: ^2.0.5         # Value equality
  dio: ^5.4.2               # HTTP client
  shared_preferences: ^2.2.2 # Local storage
```

## File Structure

```
lib/
├── data/
│   ├── providers/
│   │   └── auth_provider.dart          # API calls & token storage
│   └── repositories/
│       └── auth_repository.dart        # Repository interface
├── logic/
│   └── blocs/
│       └── auth/
│           ├── auth_event.dart         # Authentication events
│           ├── auth_state.dart         # Authentication states
│           └── auth_bloc.dart          # Authentication logic
└── presentation/
    └── screens/
        ├── login_screen.dart           # Login UI
        ├── registration_screen.dart    # Registration UI
        └── main_screen.dart            # Main app (after auth)
```

## Conclusion

Hệ thống authentication đã được triển khai hoàn chỉnh với:
- ✅ Clean architecture (Provider → Repository → BLoC → UI)
- ✅ JWT token management
- ✅ Secure token storage
- ✅ Auto token validation on app start
- ✅ Complete login/register flows
- ✅ Error handling
- ✅ Loading states
- ✅ Automatic navigation based on auth state

Task 2.2 đã hoàn thành! 🎉
