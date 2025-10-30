# Folder Management API Guide

## Tổng quan

Backend Marsa đã được triển khai các API endpoints để quản lý thư mục từ vựng của người dùng. Tất cả các endpoints này đều được bảo vệ bằng JWT authentication.

## Database Schema

### Model Folder

```prisma
model Folder {
  id        Int      @id @default(autoincrement())
  name      String
  userId    Int
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
}
```

**Quan hệ:**
- Mỗi Folder thuộc về một User
- Khi User bị xóa, tất cả Folders của user đó cũng bị xóa (Cascade)

## API Endpoints

### 1. Lấy danh sách thư mục (Protected)

**Endpoint:** `GET /api/folders`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Business English",
    "userId": 1,
    "createdAt": "2024-01-01T00:00:00.000Z"
  },
  {
    "id": 2,
    "name": "Travel Phrases",
    "userId": 1,
    "createdAt": "2024-01-02T00:00:00.000Z"
  }
]
```

**Mô tả:**
- Trả về danh sách tất cả thư mục của người dùng hiện tại
- Thư mục được sắp xếp theo thời gian tạo (mới nhất trước)
- Chỉ trả về thư mục thuộc về người dùng đã xác thực

### 2. Tạo thư mục mới (Protected)

**Endpoint:** `POST /api/folders`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Business English"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "name": "Business English",
  "userId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

**Validation:**
- `name` là bắt buộc và không được để trống
- Khoảng trắng ở đầu và cuối sẽ được tự động loại bỏ

**Error Responses:**

**400 Bad Request** - Thiếu tên thư mục:
```json
{
  "error": "Folder name is required"
}
```

### 3. Xóa thư mục (Protected)

**Endpoint:** `DELETE /api/folders/:folderId`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**URL Parameters:**
- `folderId` (number): ID của thư mục cần xóa

**Response (204 No Content):**
Không có body, chỉ trả về status code 204

**Error Responses:**

**400 Bad Request** - ID không hợp lệ:
```json
{
  "error": "Invalid folder ID"
}
```

**403 Forbidden** - Không có quyền xóa:
```json
{
  "error": "You do not have permission to delete this folder"
}
```

**404 Not Found** - Thư mục không tồn tại:
```json
{
  "error": "Folder not found"
}
```

## Ví dụ sử dụng

### 1. Với cURL

**Lấy danh sách thư mục:**
```bash
curl -X GET http://localhost:3001/api/folders \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Tạo thư mục mới:**
```bash
curl -X POST http://localhost:3001/api/folders \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"name":"Business English"}'
```

**Xóa thư mục:**
```bash
curl -X DELETE http://localhost:3001/api/folders/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 2. Với JavaScript (Fetch API)

```javascript
// Lấy token từ localStorage (sau khi đăng nhập)
const token = localStorage.getItem('token');

// Lấy danh sách thư mục
async function getFolders() {
  const response = await fetch('http://localhost:3001/api/folders', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  if (response.ok) {
    const folders = await response.json();
    console.log('Folders:', folders);
    return folders;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Tạo thư mục mới
async function createFolder(name) {
  const response = await fetch('http://localhost:3001/api/folders', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ name }),
  });
  
  if (response.ok) {
    const newFolder = await response.json();
    console.log('Created folder:', newFolder);
    return newFolder;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Xóa thư mục
async function deleteFolder(folderId) {
  const response = await fetch(`http://localhost:3001/api/folders/${folderId}`, {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  if (response.ok) {
    console.log('Folder deleted successfully');
    return true;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Sử dụng
async function main() {
  try {
    // Tạo thư mục
    const newFolder = await createFolder('Business English');
    
    // Lấy danh sách
    const folders = await getFolders();
    
    // Xóa thư mục
    await deleteFolder(newFolder.id);
  } catch (error) {
    console.error('Error:', error.message);
  }
}
```

### 3. Với TypeScript + Axios

```typescript
import axios from 'axios';

const API_BASE_URL = 'http://localhost:3001';

// Tạo axios instance với token
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`,
  },
});

interface Folder {
  id: number;
  name: string;
  userId: number;
  createdAt: string;
}

// Lấy danh sách thư mục
export async function getFolders(): Promise<Folder[]> {
  const response = await api.get<Folder[]>('/api/folders');
  return response.data;
}

// Tạo thư mục mới
export async function createFolder(name: string): Promise<Folder> {
  const response = await api.post<Folder>('/api/folders', { name });
  return response.data;
}

// Xóa thư mục
export async function deleteFolder(folderId: number): Promise<void> {
  await api.delete(`/api/folders/${folderId}`);
}
```

## Bảo mật

### Kiểm tra quyền sở hữu

Tất cả các API endpoints đều thực hiện kiểm tra quyền sở hữu:

1. **GET /api/folders**: Chỉ trả về thư mục của người dùng hiện tại
2. **POST /api/folders**: Tự động gắn userId từ token vào thư mục mới
3. **DELETE /api/folders/:id**: Kiểm tra xem thư mục có thuộc về người dùng không trước khi xóa

### Cascade Delete

Khi một User bị xóa, tất cả Folders của user đó sẽ tự động bị xóa nhờ vào `onDelete: Cascade` trong schema.

## Testing

### Test Flow cơ bản

1. Đăng ký tài khoản mới
2. Đăng nhập và lưu token
3. Tạo một số thư mục
4. Lấy danh sách thư mục
5. Xóa một thư mục
6. Xác nhận thư mục đã bị xóa

### Test Cases

**Test 1: Tạo thư mục thành công**
```bash
# Đăng nhập
TOKEN=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  | jq -r '.token')

# Tạo thư mục
curl -X POST http://localhost:3001/api/folders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Folder"}'
```

**Test 2: Không thể tạo thư mục không có tên**
```bash
curl -X POST http://localhost:3001/api/folders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":""}'
# Expected: 400 Bad Request
```

**Test 3: Không thể xóa thư mục của người khác**
```bash
# User A tạo thư mục
TOKEN_A=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"userA@example.com","password":"password123"}' \
  | jq -r '.token')

FOLDER_ID=$(curl -X POST http://localhost:3001/api/folders \
  -H "Authorization: Bearer $TOKEN_A" \
  -H "Content-Type: application/json" \
  -d '{"name":"User A Folder"}' \
  | jq -r '.id')

# User B cố gắng xóa thư mục của User A
TOKEN_B=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"userB@example.com","password":"password123"}' \
  | jq -r '.token')

curl -X DELETE http://localhost:3001/api/folders/$FOLDER_ID \
  -H "Authorization: Bearer $TOKEN_B"
# Expected: 403 Forbidden
```

## Tính năng tương lai

Các tính năng có thể được thêm vào sau:

1. **Update Folder**: `PUT /api/folders/:id` - Đổi tên thư mục
2. **Folder Statistics**: Thêm số lượng từ vựng trong mỗi thư mục
3. **Folder Sharing**: Chia sẻ thư mục với người dùng khác
4. **Folder Ordering**: Cho phép người dùng sắp xếp thứ tự thư mục
5. **Folder Colors/Icons**: Thêm màu sắc hoặc icon cho thư mục
6. **Nested Folders**: Hỗ trợ thư mục con

## Migration

Migration đã được tạo tự động bằng lệnh:
```bash
npx prisma migrate dev --name add_folder_model
```

File migration: `prisma/migrations/[timestamp]_add_folder_model/migration.sql`
