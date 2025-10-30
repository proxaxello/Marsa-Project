# Marsa Backend API Reference

## Tổng quan

Backend API cho ứng dụng học từ vựng Marsa. Tất cả các endpoints được bảo vệ (trừ đăng ký và đăng nhập) đều yêu cầu JWT authentication.

**Base URL:** `http://localhost:3001`

## Authentication

Tất cả các protected endpoints yêu cầu JWT token trong header:

```
Authorization: Bearer <your_jwt_token>
```

## API Endpoints Summary

### User Management

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/register` | ❌ | Đăng ký tài khoản mới |
| POST | `/api/login` | ❌ | Đăng nhập và nhận JWT token |
| GET | `/api/profile` | ✅ | Lấy thông tin profile người dùng |
| GET | `/api/users` | ❌ | Lấy danh sách tất cả users (dev only) |

### Folder Management

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/folders` | ✅ | Lấy danh sách thư mục của user |
| POST | `/api/folders` | ✅ | Tạo thư mục mới |
| DELETE | `/api/folders/:folderId` | ✅ | Xóa thư mục |

### Word Management

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/folders/:folderId/words` | ✅ | Lấy danh sách từ trong thư mục |
| POST | `/api/folders/:folderId/words` | ✅ | Thêm từ mới vào thư mục |
| DELETE | `/api/words/:wordId` | ✅ | Xóa từ vựng |

### Voice Lab

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/lessons` | ✅ | Lấy danh sách tất cả bài học |
| GET | `/api/lessons/:lessonId/phrases` | ✅ | Lấy danh sách câu/từ trong bài học |

## Detailed Endpoints

### 1. User Registration

**POST** `/api/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "password": "securePassword123"
}
```

**Response (201):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### 2. User Login

**POST** `/api/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
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

### 3. Get User Profile

**GET** `/api/profile`

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### 4. Get All Folders

**GET** `/api/folders`

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
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

### 5. Create Folder

**POST** `/api/folders`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Business English"
}
```

**Response (201):**
```json
{
  "id": 1,
  "name": "Business English",
  "userId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### 6. Delete Folder

**DELETE** `/api/folders/:folderId`

**Headers:**
```
Authorization: Bearer <token>
```

**Response (204):** No Content

### 7. Get Words in Folder

**GET** `/api/folders/:folderId/words`

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
[
  {
    "id": 1,
    "text": "hello",
    "meaning": "xin chào",
    "folderId": 1,
    "createdAt": "2024-01-01T00:00:00.000Z"
  },
  {
    "id": 2,
    "text": "goodbye",
    "meaning": "tạm biệt",
    "folderId": 1,
    "createdAt": "2024-01-02T00:00:00.000Z"
  }
]
```

### 8. Add Word to Folder

**POST** `/api/folders/:folderId/words`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "text": "hello",
  "meaning": "xin chào"
}
```

**Response (201):**
```json
{
  "id": 1,
  "text": "hello",
  "meaning": "xin chào",
  "folderId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### 9. Delete Word

**DELETE** `/api/words/:wordId`

**Headers:**
```
Authorization: Bearer <token>
```

**Response (204):** No Content

### 10. Get All Lessons

**GET** `/api/lessons`

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
[
  {
    "id": 1,
    "title": "Basic Greetings",
    "description": "Learn essential greeting phrases in English",
    "difficulty": "Beginner",
    "createdAt": "2024-01-01T00:00:00.000Z"
  },
  {
    "id": 2,
    "title": "At the Restaurant",
    "description": "Common phrases used when dining out",
    "difficulty": "Intermediate",
    "createdAt": "2024-01-02T00:00:00.000Z"
  }
]
```

### 11. Get Phrases in Lesson

**GET** `/api/lessons/:lessonId/phrases`

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
[
  {
    "id": 1,
    "text": "Hello, how are you?",
    "lessonId": 1,
    "createdAt": "2024-01-01T00:00:00.000Z"
  },
  {
    "id": 2,
    "text": "Good morning!",
    "lessonId": 1,
    "createdAt": "2024-01-01T00:00:01.000Z"
  }
]
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Email and password are required"
}
```

### 401 Unauthorized
```json
{
  "error": "Access token is required"
}
```

### 403 Forbidden
```json
{
  "error": "You do not have permission to delete this folder"
}
```

### 404 Not Found
```json
{
  "error": "Folder not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Failed to fetch folders"
}
```

## Complete Workflow Example

```bash
# 1. Register
curl -X POST http://localhost:3001/api/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","name":"John","password":"pass123"}'

# 2. Login and get token
TOKEN=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass123"}' \
  | jq -r '.token')

# 3. Get profile
curl -X GET http://localhost:3001/api/profile \
  -H "Authorization: Bearer $TOKEN"

# 4. Create folder
FOLDER_ID=$(curl -X POST http://localhost:3001/api/folders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Business English"}' \
  | jq -r '.id')

# 5. Add words to folder
curl -X POST http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"meeting","meaning":"cuộc họp"}'

curl -X POST http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"deadline","meaning":"hạn chót"}'

# 6. Get all words in folder
curl -X GET http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN"

# 7. Get all folders
curl -X GET http://localhost:3001/api/folders \
  -H "Authorization: Bearer $TOKEN"
```

## Database Schema

```
User
├── id: Int (PK)
├── email: String (unique)
├── password: String (hashed)
├── name: String?
├── createdAt: DateTime
├── updatedAt: DateTime
└── folders: Folder[]

Folder
├── id: Int (PK)
├── name: String
├── userId: Int (FK → User.id)
├── createdAt: DateTime
└── words: Word[]

Word
├── id: Int (PK)
├── text: String
├── meaning: String
├── folderId: Int (FK → Folder.id)
└── createdAt: DateTime

Lesson
├── id: Int (PK)
├── title: String
├── description: String
├── difficulty: String
├── createdAt: DateTime
└── phrases: Phrase[]

Phrase
├── id: Int (PK)
├── text: String
├── lessonId: Int (FK → Lesson.id)
└── createdAt: DateTime
```

## Security Features

- ✅ Password hashing with bcrypt (10 rounds)
- ✅ JWT authentication with 24h expiration
- ✅ Ownership verification for all protected resources
- ✅ Cascade delete (User → Folders → Words)
- ✅ Input validation and sanitization
- ✅ Secure error messages (no sensitive data leakage)

## Rate Limiting (Future)

Currently no rate limiting is implemented. For production, consider:
- Login attempts: 5 per 15 minutes
- API calls: 100 per minute per user
- Registration: 3 per hour per IP

## CORS (Future)

Currently CORS is not configured. For production with frontend:

```typescript
import cors from 'cors';

app.use(cors({
  origin: 'https://your-frontend-domain.com',
  credentials: true
}));
```

## Environment Variables

Required in `.env`:

```env
PORT=3001
JWT_SECRET=your_super_secret_key_here
DATABASE_URL="file:./dev.db"
```

## Running the Server

```bash
# Install dependencies
npm install

# Run migrations
npx prisma migrate dev

# Start development server
npm run dev

# Start production server
npm start
```

## Testing

See individual guide files for detailed testing:
- `JWT_AUTHENTICATION.md` - Authentication testing
- `FOLDER_API_GUIDE.md` - Folder management testing
- `WORD_API_GUIDE.md` - Word management testing

## Additional Resources

- [JWT Authentication Guide](./JWT_AUTHENTICATION.md)
- [Folder API Guide](./FOLDER_API_GUIDE.md)
- [Word API Guide](./WORD_API_GUIDE.md)
- [Voice Lab API Guide](./VOICE_LAB_API_GUIDE.md)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Express Documentation](https://expressjs.com/)

## Seeding Data

To populate the database with sample lessons and phrases:

```bash
npm run seed
```

This will create 6 sample lessons with phrases for Voice Lab feature.
