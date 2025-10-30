# JWT Authentication Guide

## Tổng quan

Backend Marsa đã được triển khai JWT (JSON Web Token) authentication để bảo vệ các API endpoints. Tài liệu này mô tả cách sử dụng hệ thống xác thực.

## Cài đặt

### 1. Cài đặt các thư viện cần thiết

```bash
npm install jsonwebtoken
npm install -D @types/jsonwebtoken
```

### 2. Cấu hình biến môi trường

Thêm dòng sau vào file `.env`:

```env
JWT_SECRET=marsa_super_secret_key_2024_a8f3d9e1b2c4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9u0v1w2x3y4z5
```

**Lưu ý:** Trong môi trường production, hãy sử dụng một chuỗi ngẫu nhiên phức tạp và giữ bí mật.

## API Endpoints

### 1. Đăng ký người dùng (Public)

**Endpoint:** `POST /api/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "password": "securePassword123"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### 2. Đăng nhập (Public)

**Endpoint:** `POST /api/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Token có hiệu lực:** 24 giờ

### 3. Lấy thông tin profile (Protected)

**Endpoint:** `GET /api/profile`

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## Cách sử dụng JWT Token

### 1. Quy trình xác thực

1. Người dùng đăng ký tài khoản qua `/api/register`
2. Người dùng đăng nhập qua `/api/login` và nhận được JWT token
3. Lưu token ở client (localStorage, sessionStorage, hoặc memory)
4. Gửi token trong header `Authorization` cho các request tiếp theo

### 2. Format của Authorization Header

```
Authorization: Bearer <your_jwt_token>
```

Ví dụ:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTYxNjIzOTAyMiwiZXhwIjoxNjE2MzI1NDIyfQ.abc123xyz
```

### 3. Ví dụ với cURL

**Đăng nhập:**
```bash
curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"securePassword123"}'
```

**Truy cập protected route:**
```bash
curl -X GET http://localhost:3001/api/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Ví dụ với JavaScript (Fetch API)

```javascript
// Đăng nhập và lưu token
async function login(email, password) {
  const response = await fetch('http://localhost:3001/api/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });
  
  const data = await response.json();
  
  if (response.ok) {
    // Lưu token vào localStorage
    localStorage.setItem('token', data.token);
    return data;
  } else {
    throw new Error(data.error);
  }
}

// Sử dụng token để truy cập protected route
async function getProfile() {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:3001/api/profile', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  const data = await response.json();
  
  if (response.ok) {
    return data;
  } else {
    throw new Error(data.error);
  }
}
```

## Xử lý lỗi

### 401 Unauthorized
Token không được cung cấp hoặc thiếu.

**Response:**
```json
{
  "error": "Access token is required"
}
```

### 403 Forbidden
Token không hợp lệ hoặc đã hết hạn.

**Response (Token hết hạn):**
```json
{
  "error": "Token has expired"
}
```

**Response (Token không hợp lệ):**
```json
{
  "error": "Invalid token"
}
```

## Bảo vệ Routes mới

Để bảo vệ một route mới bằng JWT authentication, thêm middleware `authenticateToken` vào route:

```typescript
app.get('/api/protected-route', authenticateToken, async (req: AuthRequest, res: Response) => {
  // Truy cập user ID từ req.user.userId
  const userId = req.user?.userId;
  
  // Xử lý logic của bạn ở đây
  res.json({ message: 'This is a protected route', userId });
});
```

## Best Practices

1. **Không lưu token trong cookie** nếu không cần thiết (để tránh CSRF attacks)
2. **Luôn sử dụng HTTPS** trong production
3. **Đặt thời gian hết hạn hợp lý** cho token (hiện tại là 24h)
4. **Không lưu thông tin nhạy cảm** trong JWT payload
5. **Xử lý token hết hạn** ở phía client và yêu cầu người dùng đăng nhập lại
6. **Giữ JWT_SECRET an toàn** và không commit vào git

## Refresh Token (Tính năng tương lai)

Hiện tại hệ thống chỉ sử dụng access token. Trong tương lai, có thể triển khai refresh token để:
- Tăng cường bảo mật với access token có thời gian sống ngắn
- Cho phép người dùng duy trì phiên đăng nhập lâu hơn
- Thu hồi quyền truy cập dễ dàng hơn
