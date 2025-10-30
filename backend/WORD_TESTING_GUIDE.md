# Word Management Testing Guide

## Tổng quan

File `src/__tests__/words.test.ts` chứa unit tests đầy đủ cho các word management endpoints của backend Marsa. Tests này đảm bảo các API quản lý từ vựng trong thư mục hoạt động chính xác với authentication và authorization phức tạp.

## Test Coverage

### GET /api/folders/:folderId/words (6 test cases)

1. ✅ **should get all words in folder successfully**
   - Test lấy danh sách từ thành công
   - Verify response status 200
   - Verify response chứa array of words
   - Verify words có đúng properties (id, text, meaning, folderId, createdAt)
   - Verify folder ownership được kiểm tra
   - Verify mocks được gọi đúng

2. ✅ **should return empty array if folder has no words**
   - Test trường hợp folder không có từ nào
   - Verify response status 200
   - Verify response là empty array

3. ✅ **should return 404 if folder does not exist**
   - Test với folder không tồn tại
   - Verify response status 404
   - Verify error message: "Folder not found"
   - Verify word.findMany không được gọi

4. ✅ **should return 403 if folder belongs to another user**
   - Test authorization - không thể xem từ trong folder của người khác
   - Verify response status 403
   - Verify error message: "You do not have permission to access this folder"

5. ✅ **should return 400 if folderId is not a number**
   - Test validation với folderId = "abc"
   - Verify response status 400
   - Verify error message: "Invalid folder ID"

6. ✅ **should return 401 if no token provided**
   - Test authentication requirement
   - Verify response status 401

### POST /api/folders/:folderId/words (9 test cases)

1. ✅ **should add word to folder successfully**
   - Test thêm từ mới thành công
   - Verify response status 201
   - Verify response chứa word mới (id, text, meaning, folderId)
   - Verify folder ownership được kiểm tra
   - Verify mocks được gọi đúng

2. ✅ **should trim text and meaning before creating**
   - Test tự động trim whitespace
   - Verify text và meaning được trim trước khi lưu
   - Verify mock được gọi với trimmed values

3. ✅ **should return 400 if text is missing**
   - Test validation khi thiếu text
   - Verify response status 400
   - Verify error message: "Word text is required"

4. ✅ **should return 400 if meaning is missing**
   - Test validation khi thiếu meaning
   - Verify response status 400
   - Verify error message: "Word meaning is required"

5. ✅ **should return 400 if text is empty string**
   - Test validation với text = ""
   - Verify response status 400

6. ✅ **should return 400 if text is only whitespace**
   - Test validation với text = "   "
   - Verify response status 400

7. ✅ **should return 404 if folder does not exist**
   - Test thêm từ vào folder không tồn tại
   - Verify response status 404

8. ✅ **should return 403 if folder belongs to another user**
   - Test authorization - không thể thêm từ vào folder của người khác
   - Verify response status 403
   - Verify error message: "You do not have permission to add words to this folder"

9. ✅ **should return 401 if no token provided**
   - Test authentication requirement
   - Verify response status 401

### DELETE /api/words/:wordId (6 test cases)

1. ✅ **should delete word successfully**
   - Test xóa từ thành công
   - Verify response status 204
   - Verify response body empty
   - Verify word.findUnique được gọi với include: { folder: true }
   - Verify ownership được kiểm tra qua folder

2. ✅ **should return 404 if word does not exist**
   - Test xóa từ không tồn tại
   - Verify response status 404
   - Verify error message: "Word not found"

3. ✅ **should return 403 if word belongs to another user folder**
   - Test authorization - không thể xóa từ trong folder của người khác
   - Verify response status 403
   - Verify error message: "You do not have permission to delete this word"

4. ✅ **should return 400 if wordId is not a number**
   - Test validation với wordId = "abc"
   - Verify response status 400
   - Verify error message: "Invalid word ID"

5. ✅ **should return 401 if no token provided**
   - Test authentication requirement
   - Verify response status 401

6. ✅ **should return 403 if token is invalid**
   - Test với invalid token
   - Verify response status 403

## Kỹ thuật Testing Nâng cao

### 1. Nested Authorization (Folder → Word)

DELETE endpoint kiểm tra ownership qua folder:

```typescript
const word = await prisma.word.findUnique({
  where: { id: wordId },
  include: { folder: true }, // Include folder để check ownership
});

// Check ownership through folder
if (word.folder.userId !== userId) {
  return res.status(403).json({ error: 'Permission denied' });
}
```

**Test Pattern:**
```typescript
it('should return 403 if word belongs to another user folder', async () => {
  const userId = 1;
  const otherUserId = 2;
  
  const otherUserWord = {
    id: 1,
    text: 'hello',
    folderId: 1,
    folder: {
      id: 1,
      userId: otherUserId, // Different user!
    },
  };

  (prisma.word.findUnique as jest.Mock).mockResolvedValue(otherUserWord);

  const response = await request(app)
    .delete('/api/words/1')
    .set('Authorization', `Bearer ${token}`);

  expect(response.status).toBe(403);
  expect(prisma.word.delete).not.toHaveBeenCalled();
});
```

### 2. Mock với Include Relation

```typescript
// Mock word.findUnique with folder relation
(prisma.word.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  text: 'hello',
  meaning: 'xin chào',
  folderId: 1,
  createdAt: new Date(),
  folder: {
    id: 1,
    name: 'Business English',
    userId: 1,
    createdAt: new Date(),
  },
});

// Verify mock was called with include
expect(prisma.word.findUnique).toHaveBeenCalledWith({
  where: { id: 1 },
  include: { folder: true },
});
```

### 3. Two-Level Authorization Check

GET và POST endpoints kiểm tra folder ownership trước:

```typescript
// Step 1: Check folder exists
const folder = await prisma.folder.findUnique({
  where: { id: folderId }
});

if (!folder) {
  return res.status(404).json({ error: 'Folder not found' });
}

// Step 2: Check folder ownership
if (folder.userId !== userId) {
  return res.status(403).json({ error: 'Permission denied' });
}

// Step 3: Proceed with word operations
const words = await prisma.word.findMany({
  where: { folderId }
});
```

**Test Pattern:**
```typescript
it('should check folder ownership before fetching words', async () => {
  const userId = 1;
  const otherUserId = 2;
  
  const otherUserFolder = {
    id: 1,
    userId: otherUserId, // Different user
  };

  (prisma.folder.findUnique as jest.Mock).mockResolvedValue(otherUserFolder);

  const response = await request(app)
    .get('/api/folders/1/words')
    .set('Authorization', `Bearer ${token}`);

  expect(response.status).toBe(403);
  
  // Verify word.findMany was NOT called
  expect(prisma.word.findMany).not.toHaveBeenCalled();
});
```

### 4. Multiple Field Validation

POST endpoint validate cả text và meaning:

```typescript
if (!text || text.trim() === '') {
  return res.status(400).json({ error: 'Word text is required' });
}

if (!meaning || meaning.trim() === '') {
  return res.status(400).json({ error: 'Word meaning is required' });
}
```

**Test Coverage:**
```typescript
describe('Validation Tests', () => {
  it('should reject missing text', async () => { /* ... */ });
  it('should reject missing meaning', async () => { /* ... */ });
  it('should reject empty text', async () => { /* ... */ });
  it('should reject whitespace-only text', async () => { /* ... */ });
  it('should trim text and meaning', async () => { /* ... */ });
});
```

## Mock Setup Patterns

### GET Words Mock

```typescript
// Mock folder ownership check
(prisma.folder.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  name: 'Business English',
  userId: 1, // Current user
  createdAt: new Date(),
});

// Mock words in folder
(prisma.word.findMany as jest.Mock).mockResolvedValue([
  {
    id: 1,
    text: 'hello',
    meaning: 'xin chào',
    folderId: 1,
    createdAt: new Date(),
  },
  {
    id: 2,
    text: 'goodbye',
    meaning: 'tạm biệt',
    folderId: 1,
    createdAt: new Date(),
  },
]);
```

### POST Word Mock

```typescript
// Mock folder ownership check
(prisma.folder.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  userId: 1, // Current user
});

// Mock word creation
(prisma.word.create as jest.Mock).mockResolvedValue({
  id: 1,
  text: 'hello',
  meaning: 'xin chào',
  folderId: 1,
  createdAt: new Date(),
});
```

### DELETE Word Mock

```typescript
// Mock word with folder relation
(prisma.word.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  text: 'hello',
  meaning: 'xin chào',
  folderId: 1,
  createdAt: new Date(),
  folder: {
    id: 1,
    name: 'Business English',
    userId: 1, // Current user
    createdAt: new Date(),
  },
});

// Mock word deletion
(prisma.word.delete as jest.Mock).mockResolvedValue({
  id: 1,
  text: 'hello',
  meaning: 'xin chào',
  folderId: 1,
  createdAt: new Date(),
});
```

## Authorization Flow

### GET /api/folders/:folderId/words

```
Request → Authenticate → Validate folderId → 
Check folder exists → Check folder ownership → 
Fetch words → Return 200
```

**Authorization Points:**
1. JWT token validation (401)
2. Folder existence (404)
3. Folder ownership (403)

### POST /api/folders/:folderId/words

```
Request → Authenticate → Validate folderId → 
Validate text & meaning → Check folder exists → 
Check folder ownership → Create word → Return 201
```

**Authorization Points:**
1. JWT token validation (401)
2. Input validation (400)
3. Folder existence (404)
4. Folder ownership (403)

### DELETE /api/words/:wordId

```
Request → Authenticate → Validate wordId → 
Check word exists (with folder) → 
Check folder ownership → Delete word → Return 204
```

**Authorization Points:**
1. JWT token validation (401)
2. Word existence (404)
3. Folder ownership via word.folder (403)

## Test Data Patterns

### Consistent Test Data

```typescript
// User IDs
const userId = 1;
const otherUserId = 2;

// Folder data
const mockFolder = {
  id: 1,
  name: 'Business English',
  userId: userId,
  createdAt: new Date('2024-01-01'),
};

// Word data
const mockWord = {
  id: 1,
  text: 'hello',
  meaning: 'xin chào',
  folderId: 1,
  createdAt: new Date('2024-01-01'),
};

// Word with folder relation
const mockWordWithFolder = {
  ...mockWord,
  folder: mockFolder,
};
```

### Error Scenarios

```typescript
// Folder not found
(prisma.folder.findUnique as jest.Mock).mockResolvedValue(null);

// Word not found
(prisma.word.findUnique as jest.Mock).mockResolvedValue(null);

// Folder belongs to another user
(prisma.folder.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  userId: 2, // Different user
});

// Word belongs to another user's folder
(prisma.word.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  folder: {
    userId: 2, // Different user
  },
});
```

## Security Testing

### 1. Authentication Testing

Tất cả endpoints require authentication:

```typescript
it('should return 401 if no token provided', async () => {
  const response = await request(app)
    .get('/api/folders/1/words'); // No token

  expect(response.status).toBe(401);
  expect(prisma.folder.findUnique).not.toHaveBeenCalled();
});
```

### 2. Folder Ownership Testing

GET và POST endpoints kiểm tra folder ownership:

```typescript
it('should return 403 if folder belongs to another user', async () => {
  const otherUserFolder = {
    id: 1,
    userId: 2, // Different user
  };

  (prisma.folder.findUnique as jest.Mock).mockResolvedValue(otherUserFolder);

  const response = await request(app)
    .get('/api/folders/1/words')
    .set('Authorization', `Bearer ${token}`);

  expect(response.status).toBe(403);
  expect(prisma.word.findMany).not.toHaveBeenCalled();
});
```

### 3. Nested Ownership Testing

DELETE endpoint kiểm tra ownership qua folder relation:

```typescript
it('should return 403 if word belongs to another user folder', async () => {
  const wordWithOtherUserFolder = {
    id: 1,
    folder: {
      userId: 2, // Different user
    },
  };

  (prisma.word.findUnique as jest.Mock).mockResolvedValue(wordWithOtherUserFolder);

  const response = await request(app)
    .delete('/api/words/1')
    .set('Authorization', `Bearer ${token}`);

  expect(response.status).toBe(403);
  expect(prisma.word.delete).not.toHaveBeenCalled();
});
```

## Running Tests

### Run All Tests

```bash
npm test
```

### Run Only Word Tests

```bash
npm test words.test.ts
```

### Run Tests in Watch Mode

```bash
npm run test:watch
```

### Run with Coverage

```bash
npm run test:coverage
```

## Test Results

```
PASS  src/__tests__/words.test.ts
  Word Management Endpoints
    GET /api/folders/:folderId/words
      ✓ should get all words in folder successfully (44 ms)
      ✓ should return empty array if folder has no words (6 ms)
      ✓ should return 404 if folder does not exist (6 ms)
      ✓ should return 403 if folder belongs to another user (4 ms)
      ✓ should return 400 if folderId is not a number (5 ms)
      ✓ should return 401 if no token provided (4 ms)
    POST /api/folders/:folderId/words
      ✓ should add word to folder successfully (14 ms)
      ✓ should trim text and meaning before creating (8 ms)
      ✓ should return 400 if text is missing (8 ms)
      ✓ should return 400 if meaning is missing (11 ms)
      ✓ should return 400 if text is empty string (5 ms)
      ✓ should return 400 if text is only whitespace (4 ms)
      ✓ should return 404 if folder does not exist (4 ms)
      ✓ should return 403 if folder belongs to another user (4 ms)
      ✓ should return 401 if no token provided (6 ms)
    DELETE /api/words/:wordId
      ✓ should delete word successfully (6 ms)
      ✓ should return 404 if word does not exist (4 ms)
      ✓ should return 403 if word belongs to another user folder (6 ms)
      ✓ should return 400 if wordId is not a number (5 ms)
      ✓ should return 401 if no token provided (4 ms)
      ✓ should return 403 if token is invalid (4 ms)

Test Suites: 4 passed, 4 total
Tests:       55 passed, 55 total
Time:        2.881 s
```

## Best Practices Demonstrated

### 1. Comprehensive Authorization

- ✅ Authentication (JWT token)
- ✅ Folder ownership verification
- ✅ Nested ownership (word → folder → user)
- ✅ Multiple authorization levels

### 2. Complete Validation

- ✅ Required fields (text, meaning)
- ✅ Empty strings
- ✅ Whitespace-only strings
- ✅ Invalid ID formats
- ✅ Automatic trimming

### 3. Proper Mock Management

- ✅ Mock folder.findUnique for ownership checks
- ✅ Mock word operations (findMany, create, findUnique, delete)
- ✅ Mock with relations (include: { folder: true })
- ✅ Clear mocks between tests

### 4. Error Handling

- ✅ 400 - Validation errors
- ✅ 401 - Authentication errors
- ✅ 403 - Authorization errors
- ✅ 404 - Not found errors
- ✅ 201, 200, 204 - Success responses

### 5. Security Focus

- ✅ Never expose other users' data
- ✅ Verify ownership at multiple levels
- ✅ Validate all inputs
- ✅ Proper error messages (no sensitive info)

## Key Differences from Previous Tests

### 1. Nested Authorization

Word tests require checking ownership through folder relation:

```typescript
// Folder tests: Direct ownership
if (folder.userId !== userId) { /* 403 */ }

// Word tests: Nested ownership
if (word.folder.userId !== userId) { /* 403 */ }
```

### 2. Include Relations in Mocks

```typescript
// Mock with relation
(prisma.word.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  text: 'hello',
  folder: {
    id: 1,
    userId: 1, // For ownership check
  },
});
```

### 3. Two-Step Authorization

GET và POST check folder ownership before word operations:

```typescript
// Step 1: Check folder
const folder = await prisma.folder.findUnique({ where: { id } });
if (folder.userId !== userId) { /* 403 */ }

// Step 2: Proceed with word operation
const words = await prisma.word.findMany({ where: { folderId } });
```

### 4. Multiple Field Validation

```typescript
// Validate both text and meaning
if (!text || text.trim() === '') { /* 400 */ }
if (!meaning || meaning.trim() === '') { /* 400 */ }
```

## Next Steps

Sau khi word tests hoàn thành:

1. **Viết tests cho Lesson APIs** (`/api/lessons`)
2. **Viết tests cho Phrase APIs** (`/api/lessons/:id/phrases`)
3. **Integration tests** cho complete workflows
4. **E2E tests** với real database
5. **Performance tests** cho large datasets

## Kết luận

Word Management tests đã được triển khai đầy đủ với:
- ✅ 21 test cases covering all scenarios
- ✅ Nested authorization testing
- ✅ Two-level ownership verification
- ✅ Complete validation testing
- ✅ Mock with relations (include)
- ✅ 100% pass rate

**Word Management testing hoàn thành!** 🎉
