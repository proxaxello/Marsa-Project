# Word Management API Guide

## Tổng quan

Backend Marsa đã được triển khai các API endpoints để quản lý từ vựng trong thư mục. Tất cả các endpoints này đều được bảo vệ bằng JWT authentication và kiểm tra quyền sở hữu thư mục.

## Database Schema

### Model Word

```prisma
model Word {
  id        Int      @id @default(autoincrement())
  text      String
  meaning   String
  folderId  Int
  folder    Folder   @relation(fields: [folderId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
}
```

**Quan hệ:**
- Mỗi Word thuộc về một Folder
- Khi Folder bị xóa, tất cả Words trong folder đó cũng bị xóa (Cascade)

**Cấu trúc dữ liệu:**
```
User (1) ----< (N) Folder (1) ----< (N) Word
```

## API Endpoints

### 1. Lấy danh sách từ vựng trong thư mục (Protected)

**Endpoint:** `GET /api/folders/:folderId/words`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**URL Parameters:**
- `folderId` (number): ID của thư mục

**Response (200 OK):**
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

**Mô tả:**
- Trả về danh sách tất cả từ vựng trong thư mục được chỉ định
- Từ vựng được sắp xếp theo thời gian tạo (mới nhất trước)
- Kiểm tra quyền sở hữu thư mục trước khi trả về dữ liệu

**Error Responses:**

**403 Forbidden** - Không có quyền truy cập thư mục:
```json
{
  "error": "You do not have permission to access this folder"
}
```

**404 Not Found** - Thư mục không tồn tại:
```json
{
  "error": "Folder not found"
}
```

### 2. Thêm từ vựng mới vào thư mục (Protected)

**Endpoint:** `POST /api/folders/:folderId/words`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

**URL Parameters:**
- `folderId` (number): ID của thư mục

**Request Body:**
```json
{
  "text": "hello",
  "meaning": "xin chào"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "text": "hello",
  "meaning": "xin chào",
  "folderId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

**Validation:**
- `text` là bắt buộc và không được để trống (từ tiếng Anh)
- `meaning` là bắt buộc và không được để trống (nghĩa tiếng Việt)
- Khoảng trắng ở đầu và cuối sẽ được tự động loại bỏ
- Kiểm tra quyền sở hữu thư mục trước khi thêm từ

**Error Responses:**

**400 Bad Request** - Thiếu text:
```json
{
  "error": "Word text is required"
}
```

**400 Bad Request** - Thiếu meaning:
```json
{
  "error": "Word meaning is required"
}
```

**403 Forbidden** - Không có quyền thêm từ vào thư mục:
```json
{
  "error": "You do not have permission to add words to this folder"
}
```

**404 Not Found** - Thư mục không tồn tại:
```json
{
  "error": "Folder not found"
}
```

### 3. Xóa từ vựng (Protected)

**Endpoint:** `DELETE /api/words/:wordId`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**URL Parameters:**
- `wordId` (number): ID của từ vựng cần xóa

**Response (204 No Content):**
Không có body, chỉ trả về status code 204

**Mô tả:**
- Kiểm tra quyền sở hữu phức tạp: từ vựng phải thuộc về thư mục, và thư mục phải thuộc về người dùng
- Sử dụng `include: { folder: true }` để lấy thông tin thư mục kèm theo

**Error Responses:**

**400 Bad Request** - ID không hợp lệ:
```json
{
  "error": "Invalid word ID"
}
```

**403 Forbidden** - Không có quyền xóa:
```json
{
  "error": "You do not have permission to delete this word"
}
```

**404 Not Found** - Từ vựng không tồn tại:
```json
{
  "error": "Word not found"
}
```

## Ví dụ sử dụng

### 1. Với cURL

**Lấy danh sách từ vựng trong thư mục:**
```bash
curl -X GET http://localhost:3001/api/folders/1/words \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Thêm từ vựng mới:**
```bash
curl -X POST http://localhost:3001/api/folders/1/words \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"text":"hello","meaning":"xin chào"}'
```

**Xóa từ vựng:**
```bash
curl -X DELETE http://localhost:3001/api/words/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 2. Với JavaScript (Fetch API)

```javascript
const token = localStorage.getItem('token');
const API_BASE_URL = 'http://localhost:3001';

// Lấy danh sách từ vựng trong thư mục
async function getWords(folderId) {
  const response = await fetch(`${API_BASE_URL}/api/folders/${folderId}/words`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  if (response.ok) {
    const words = await response.json();
    console.log('Words:', words);
    return words;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Thêm từ vựng mới
async function addWord(folderId, text, meaning) {
  const response = await fetch(`${API_BASE_URL}/api/folders/${folderId}/words`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ text, meaning }),
  });
  
  if (response.ok) {
    const newWord = await response.json();
    console.log('Created word:', newWord);
    return newWord;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Xóa từ vựng
async function deleteWord(wordId) {
  const response = await fetch(`${API_BASE_URL}/api/words/${wordId}`, {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  if (response.ok) {
    console.log('Word deleted successfully');
    return true;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Sử dụng
async function main() {
  try {
    const folderId = 1;
    
    // Thêm từ vựng
    const newWord = await addWord(folderId, 'hello', 'xin chào');
    
    // Lấy danh sách từ vựng
    const words = await getWords(folderId);
    
    // Xóa từ vựng
    await deleteWord(newWord.id);
  } catch (error) {
    console.error('Error:', error.message);
  }
}
```

### 3. Với TypeScript + Axios

```typescript
import axios from 'axios';

const API_BASE_URL = 'http://localhost:3001';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`,
  },
});

interface Word {
  id: number;
  text: string;
  meaning: string;
  folderId: number;
  createdAt: string;
}

interface CreateWordDto {
  text: string;
  meaning: string;
}

// Lấy danh sách từ vựng trong thư mục
export async function getWords(folderId: number): Promise<Word[]> {
  const response = await api.get<Word[]>(`/api/folders/${folderId}/words`);
  return response.data;
}

// Thêm từ vựng mới
export async function addWord(folderId: number, data: CreateWordDto): Promise<Word> {
  const response = await api.post<Word>(`/api/folders/${folderId}/words`, data);
  return response.data;
}

// Xóa từ vựng
export async function deleteWord(wordId: number): Promise<void> {
  await api.delete(`/api/words/${wordId}`);
}

// Ví dụ sử dụng với React Component
import React, { useState, useEffect } from 'react';

function WordList({ folderId }: { folderId: number }) {
  const [words, setWords] = useState<Word[]>([]);
  const [newWord, setNewWord] = useState({ text: '', meaning: '' });

  useEffect(() => {
    loadWords();
  }, [folderId]);

  const loadWords = async () => {
    try {
      const data = await getWords(folderId);
      setWords(data);
    } catch (error) {
      console.error('Failed to load words:', error);
    }
  };

  const handleAddWord = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await addWord(folderId, newWord);
      setNewWord({ text: '', meaning: '' });
      loadWords();
    } catch (error) {
      console.error('Failed to add word:', error);
    }
  };

  const handleDeleteWord = async (wordId: number) => {
    try {
      await deleteWord(wordId);
      loadWords();
    } catch (error) {
      console.error('Failed to delete word:', error);
    }
  };

  return (
    <div>
      <form onSubmit={handleAddWord}>
        <input
          type="text"
          placeholder="English word"
          value={newWord.text}
          onChange={(e) => setNewWord({ ...newWord, text: e.target.value })}
        />
        <input
          type="text"
          placeholder="Vietnamese meaning"
          value={newWord.meaning}
          onChange={(e) => setNewWord({ ...newWord, meaning: e.target.value })}
        />
        <button type="submit">Add Word</button>
      </form>

      <ul>
        {words.map((word) => (
          <li key={word.id}>
            <strong>{word.text}</strong>: {word.meaning}
            <button onClick={() => handleDeleteWord(word.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

## Workflow hoàn chỉnh

### Quy trình làm việc với từ vựng

1. **Đăng nhập** → Nhận JWT token
2. **Tạo thư mục** → `POST /api/folders`
3. **Thêm từ vào thư mục** → `POST /api/folders/:folderId/words`
4. **Xem danh sách từ** → `GET /api/folders/:folderId/words`
5. **Xóa từ không cần thiết** → `DELETE /api/words/:wordId`

### Ví dụ workflow đầy đủ

```bash
# 1. Đăng nhập
TOKEN=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}' \
  | jq -r '.token')

# 2. Tạo thư mục
FOLDER_ID=$(curl -X POST http://localhost:3001/api/folders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Business English"}' \
  | jq -r '.id')

# 3. Thêm từ vào thư mục
curl -X POST http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"meeting","meaning":"cuộc họp"}'

curl -X POST http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"deadline","meaning":"hạn chót"}'

# 4. Xem danh sách từ
curl -X GET http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN"
```

## Bảo mật

### Kiểm tra quyền sở hữu nhiều cấp

API từ vựng thực hiện kiểm tra quyền sở hữu ở nhiều cấp:

1. **GET /api/folders/:folderId/words**: 
   - Kiểm tra folder có thuộc về user không
   
2. **POST /api/folders/:folderId/words**: 
   - Kiểm tra folder có thuộc về user không trước khi thêm từ
   
3. **DELETE /api/words/:wordId**: 
   - Kiểm tra word → folder → user (kiểm tra 2 cấp)

### Cascade Delete

- Khi Folder bị xóa → Tất cả Words trong folder đó tự động bị xóa
- Khi User bị xóa → Tất cả Folders → Tất cả Words tự động bị xóa

## Testing

### Test Cases

**Test 1: Thêm từ vào thư mục của mình**
```bash
# Expected: 201 Created
curl -X POST http://localhost:3001/api/folders/1/words \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"hello","meaning":"xin chào"}'
```

**Test 2: Không thể thêm từ thiếu meaning**
```bash
# Expected: 400 Bad Request
curl -X POST http://localhost:3001/api/folders/1/words \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"hello"}'
```

**Test 3: Không thể xem từ trong thư mục của người khác**
```bash
# User A tạo thư mục và thêm từ
TOKEN_A=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"userA@example.com","password":"password123"}' \
  | jq -r '.token')

FOLDER_ID=$(curl -X POST http://localhost:3001/api/folders \
  -H "Authorization: Bearer $TOKEN_A" \
  -H "Content-Type: application/json" \
  -d '{"name":"My Folder"}' \
  | jq -r '.id')

# User B cố gắng xem từ trong thư mục của User A
TOKEN_B=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"userB@example.com","password":"password123"}' \
  | jq -r '.token')

curl -X GET http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN_B"
# Expected: 403 Forbidden
```

**Test 4: Không thể xóa từ của người khác**
```bash
# User A thêm từ
WORD_ID=$(curl -X POST http://localhost:3001/api/folders/$FOLDER_ID/words \
  -H "Authorization: Bearer $TOKEN_A" \
  -H "Content-Type: application/json" \
  -d '{"text":"hello","meaning":"xin chào"}' \
  | jq -r '.id')

# User B cố gắng xóa từ của User A
curl -X DELETE http://localhost:3001/api/words/$WORD_ID \
  -H "Authorization: Bearer $TOKEN_B"
# Expected: 403 Forbidden
```

## Tính năng tương lai

1. **Update Word**: `PUT /api/words/:id` - Cập nhật từ vựng
2. **Search Words**: `GET /api/words/search?q=hello` - Tìm kiếm từ vựng
3. **Word Statistics**: Thống kê số lượng từ đã học, từ cần ôn tập
4. **Word Examples**: Thêm câu ví dụ cho mỗi từ
5. **Word Pronunciation**: Thêm phiên âm (IPA)
6. **Word Audio**: Thêm file âm thanh phát âm
7. **Word Images**: Thêm hình ảnh minh họa
8. **Spaced Repetition**: Thuật toán lặp lại ngắt quãng (SM-2)
9. **Word Tags**: Thêm tags/categories cho từ vựng
10. **Bulk Import**: Import nhiều từ cùng lúc từ CSV/Excel

## Migration

Migration đã được tạo tự động bằng lệnh:
```bash
npx prisma migrate dev --name add_word_model
```

File migration: `prisma/migrations/[timestamp]_add_word_model/migration.sql`
