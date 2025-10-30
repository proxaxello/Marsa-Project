# Voice Lab API Guide

## Tổng quan

Backend Marsa cung cấp các API endpoints để hỗ trợ tính năng Voice Lab - nơi người dùng có thể luyện phát âm với các bài học có sẵn. Tất cả các endpoints này đều được bảo vệ bằng JWT authentication.

## Database Schema

### Model Lesson

```prisma
model Lesson {
  id          Int      @id @default(autoincrement())
  title       String
  description String
  difficulty  String
  createdAt   DateTime @default(now())
  phrases     Phrase[]
}
```

### Model Phrase

```prisma
model Phrase {
  id        Int      @id @default(autoincrement())
  text      String
  lessonId  Int
  lesson    Lesson   @relation(fields: [lessonId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
}
```

**Quan hệ:**
- Mỗi Lesson có thể chứa nhiều Phrases
- Khi Lesson bị xóa, tất cả Phrases trong lesson đó cũng bị xóa (Cascade)

**Cấu trúc dữ liệu:**
```
Lesson (1) ----< (N) Phrase
```

## API Endpoints

### 1. Lấy danh sách tất cả bài học (Protected)

**Endpoint:** `GET /api/lessons`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Response (200 OK):**
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
    "title": "Introducing Yourself",
    "description": "Practice self-introduction phrases",
    "difficulty": "Beginner",
    "createdAt": "2024-01-02T00:00:00.000Z"
  },
  {
    "id": 3,
    "title": "At the Restaurant",
    "description": "Common phrases used when dining out",
    "difficulty": "Intermediate",
    "createdAt": "2024-01-03T00:00:00.000Z"
  }
]
```

**Mô tả:**
- Trả về danh sách tất cả bài học có sẵn
- Bài học được sắp xếp theo thời gian tạo (mới nhất trước)
- Không cần kiểm tra quyền sở hữu vì bài học là public cho tất cả users

**Difficulty Levels:**
- `Beginner` - Dành cho người mới bắt đầu
- `Intermediate` - Trình độ trung cấp
- `Advanced` - Trình độ nâng cao

### 2. Lấy danh sách câu/từ trong bài học (Protected)

**Endpoint:** `GET /api/lessons/:lessonId/phrases`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**URL Parameters:**
- `lessonId` (number): ID của bài học

**Response (200 OK):**
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
  },
  {
    "id": 3,
    "text": "Good afternoon!",
    "lessonId": 1,
    "createdAt": "2024-01-01T00:00:02.000Z"
  }
]
```

**Mô tả:**
- Trả về danh sách tất cả câu/từ trong bài học được chỉ định
- Phrases được sắp xếp theo thứ tự tạo (từ đầu đến cuối bài học)
- Kiểm tra bài học có tồn tại trước khi trả về dữ liệu

**Error Responses:**

**400 Bad Request** - ID không hợp lệ:
```json
{
  "error": "Invalid lesson ID"
}
```

**404 Not Found** - Bài học không tồn tại:
```json
{
  "error": "Lesson not found"
}
```

## Ví dụ sử dụng

### 1. Với cURL

**Lấy danh sách bài học:**
```bash
curl -X GET http://localhost:3001/api/lessons \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Lấy danh sách câu/từ trong bài học:**
```bash
curl -X GET http://localhost:3001/api/lessons/1/phrases \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 2. Với JavaScript (Fetch API)

```javascript
const token = localStorage.getItem('token');
const API_BASE_URL = 'http://localhost:3001';

// Lấy danh sách bài học
async function getLessons() {
  const response = await fetch(`${API_BASE_URL}/api/lessons`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  if (response.ok) {
    const lessons = await response.json();
    console.log('Lessons:', lessons);
    return lessons;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Lấy danh sách câu/từ trong bài học
async function getPhrases(lessonId) {
  const response = await fetch(`${API_BASE_URL}/api/lessons/${lessonId}/phrases`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  if (response.ok) {
    const phrases = await response.json();
    console.log('Phrases:', phrases);
    return phrases;
  } else {
    const error = await response.json();
    throw new Error(error.error);
  }
}

// Sử dụng
async function main() {
  try {
    // Lấy danh sách bài học
    const lessons = await getLessons();
    
    // Lấy phrases của bài học đầu tiên
    if (lessons.length > 0) {
      const phrases = await getPhrases(lessons[0].id);
      console.log(`Lesson "${lessons[0].title}" has ${phrases.length} phrases`);
    }
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

interface Lesson {
  id: number;
  title: string;
  description: string;
  difficulty: string;
  createdAt: string;
}

interface Phrase {
  id: number;
  text: string;
  lessonId: number;
  createdAt: string;
}

// Lấy danh sách bài học
export async function getLessons(): Promise<Lesson[]> {
  const response = await api.get<Lesson[]>('/api/lessons');
  return response.data;
}

// Lấy danh sách câu/từ trong bài học
export async function getPhrases(lessonId: number): Promise<Phrase[]> {
  const response = await api.get<Phrase[]>(`/api/lessons/${lessonId}/phrases`);
  return response.data;
}

// Ví dụ sử dụng với React Component
import React, { useState, useEffect } from 'react';

function VoiceLabScreen() {
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [selectedLesson, setSelectedLesson] = useState<Lesson | null>(null);
  const [phrases, setPhrases] = useState<Phrase[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadLessons();
  }, []);

  const loadLessons = async () => {
    try {
      setLoading(true);
      const data = await getLessons();
      setLessons(data);
    } catch (error) {
      console.error('Failed to load lessons:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectLesson = async (lesson: Lesson) => {
    try {
      setLoading(true);
      setSelectedLesson(lesson);
      const data = await getPhrases(lesson.id);
      setPhrases(data);
    } catch (error) {
      console.error('Failed to load phrases:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>Voice Lab</h1>
      
      <div className="lessons-list">
        <h2>Available Lessons</h2>
        {lessons.map((lesson) => (
          <div 
            key={lesson.id} 
            onClick={() => handleSelectLesson(lesson)}
            className={`lesson-card ${selectedLesson?.id === lesson.id ? 'selected' : ''}`}
          >
            <h3>{lesson.title}</h3>
            <p>{lesson.description}</p>
            <span className={`difficulty ${lesson.difficulty.toLowerCase()}`}>
              {lesson.difficulty}
            </span>
          </div>
        ))}
      </div>

      {selectedLesson && (
        <div className="phrases-list">
          <h2>{selectedLesson.title} - Phrases</h2>
          {phrases.map((phrase, index) => (
            <div key={phrase.id} className="phrase-item">
              <span className="phrase-number">{index + 1}</span>
              <span className="phrase-text">{phrase.text}</span>
              <button onClick={() => handlePractice(phrase)}>
                Practice
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );

  function handlePractice(phrase: Phrase) {
    // Implement practice logic here
    console.log('Practicing phrase:', phrase.text);
  }
}
```

## Workflow hoàn chỉnh

### Quy trình sử dụng Voice Lab

1. **Đăng nhập** → Nhận JWT token
2. **Xem danh sách bài học** → `GET /api/lessons`
3. **Chọn một bài học** → Hiển thị thông tin bài học
4. **Xem các câu/từ** → `GET /api/lessons/:lessonId/phrases`
5. **Luyện phát âm** → Người dùng đọc từng câu và ghi âm
6. **Phân tích phát âm** → (API sẽ được thêm sau)

### Ví dụ workflow đầy đủ

```bash
# 1. Đăng nhập
TOKEN=$(curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}' \
  | jq -r '.token')

# 2. Lấy danh sách bài học
curl -X GET http://localhost:3001/api/lessons \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'

# 3. Lấy phrases của bài học đầu tiên (ID = 1)
curl -X GET http://localhost:3001/api/lessons/1/phrases \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'
```

## Seeding Data

### Chạy seed để tạo dữ liệu mẫu

```bash
npm run seed
```

Script seed sẽ tạo 6 bài học mẫu với các chủ đề:

1. **Basic Greetings** (Beginner) - 8 phrases
2. **Introducing Yourself** (Beginner) - 7 phrases
3. **At the Restaurant** (Intermediate) - 8 phrases
4. **Shopping Expressions** (Intermediate) - 8 phrases
5. **Business Meeting** (Advanced) - 8 phrases
6. **Travel & Directions** (Intermediate) - 8 phrases

### Xem dữ liệu đã seed

```bash
# Sử dụng Prisma Studio
npx prisma studio
```

## Testing

### Test Cases

**Test 1: Lấy danh sách bài học**
```bash
curl -X GET http://localhost:3001/api/lessons \
  -H "Authorization: Bearer $TOKEN"
# Expected: 200 OK with array of lessons
```

**Test 2: Lấy phrases của bài học hợp lệ**
```bash
curl -X GET http://localhost:3001/api/lessons/1/phrases \
  -H "Authorization: Bearer $TOKEN"
# Expected: 200 OK with array of phrases
```

**Test 3: Lấy phrases của bài học không tồn tại**
```bash
curl -X GET http://localhost:3001/api/lessons/999/phrases \
  -H "Authorization: Bearer $TOKEN"
# Expected: 404 Not Found
```

**Test 4: Truy cập không có token**
```bash
curl -X GET http://localhost:3001/api/lessons
# Expected: 401 Unauthorized
```

## Tính năng tương lai

Các tính năng có thể được thêm vào sau:

1. **User Progress Tracking**: Theo dõi tiến độ học của từng user
   - `GET /api/lessons/:lessonId/progress` - Xem tiến độ
   - `POST /api/lessons/:lessonId/progress` - Cập nhật tiến độ

2. **Pronunciation Analysis**: Phân tích phát âm
   - `POST /api/phrases/:phraseId/analyze` - Gửi audio và nhận phân tích

3. **Lesson Filtering**: Lọc bài học theo độ khó
   - `GET /api/lessons?difficulty=Beginner`

4. **Lesson Search**: Tìm kiếm bài học
   - `GET /api/lessons/search?q=greeting`

5. **User Favorites**: Đánh dấu bài học yêu thích
   - `POST /api/lessons/:lessonId/favorite`
   - `GET /api/lessons/favorites`

6. **Lesson Statistics**: Thống kê
   - Số lượng người dùng đã hoàn thành
   - Điểm trung bình
   - Thời gian hoàn thành trung bình

7. **Custom Lessons**: Cho phép user tạo bài học riêng
   - `POST /api/lessons` - Tạo bài học mới
   - `POST /api/lessons/:lessonId/phrases` - Thêm phrase

8. **Audio Files**: Thêm file âm thanh mẫu cho mỗi phrase
   - `GET /api/phrases/:phraseId/audio` - Lấy audio file

9. **Lesson Categories**: Phân loại bài học theo chủ đề
   - Travel, Business, Daily Life, etc.

10. **Achievements & Badges**: Hệ thống thành tích
    - Hoàn thành 10 bài học
    - Luyện tập 7 ngày liên tiếp
    - Đạt điểm cao trong phát âm

## Migration

Migration đã được tạo tự động bằng lệnh:
```bash
npx prisma migrate dev --name add_lesson_phrase_models
```

File migration: `prisma/migrations/[timestamp]_add_lesson_phrase_models/migration.sql`

## Database Relationships

```
User (không liên kết trực tiếp với Lesson/Phrase trong phiên bản hiện tại)

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

**Lưu ý:** Trong phiên bản hiện tại, Lessons và Phrases là public cho tất cả users. Trong tương lai, có thể thêm quan hệ với User để theo dõi tiến độ học tập cá nhân.

## Best Practices

1. **Caching**: Cache danh sách lessons ở client vì dữ liệu ít thay đổi
2. **Pagination**: Nếu số lượng lessons tăng lên, cân nhắc thêm pagination
3. **Lazy Loading**: Chỉ load phrases khi user chọn lesson
4. **Offline Support**: Cache lessons và phrases để sử dụng offline
5. **Audio Preloading**: Preload audio files của phrases để giảm độ trễ
