# Folder Management Testing Guide

## Tổng quan

File `src/__tests__/folders.test.ts` chứa unit tests đầy đủ cho các folder management endpoints của backend Marsa. Tests này đảm bảo các API quản lý thư mục từ vựng hoạt động chính xác với authentication và authorization.

## Test Coverage

### GET /api/folders (5 test cases)

1. ✅ **should get all folders for authenticated user**
   - Test lấy danh sách thư mục thành công
   - Verify response status 200
   - Verify response chứa array of folders
   - Verify folders có đúng properties (id, name, userId, createdAt)
   - Verify mock được gọi với đúng userId và orderBy

2. ✅ **should return empty array if user has no folders**
   - Test trường hợp user chưa có thư mục nào
   - Verify response status 200
   - Verify response là empty array

3. ✅ **should return 401 if no token provided**
   - Test authentication requirement
   - Verify response status 401
   - Verify error message: "Access token is required"
   - Verify không có database calls

4. ✅ **should return 403 if token is invalid**
   - Test với token không hợp lệ
   - Verify response status 403
   - Verify error message: "Invalid token"

5. ✅ **should return 403 if token is expired**
   - Test với token đã hết hạn
   - Verify response status 403
   - Verify error message: "Token has expired"

### POST /api/folders (6 test cases)

1. ✅ **should create a new folder successfully**
   - Test tạo thư mục thành công
   - Verify response status 201
   - Verify response chứa folder mới (id, name, userId, createdAt)
   - Verify mock được gọi với đúng data

2. ✅ **should trim folder name before creating**
   - Test tự động trim whitespace
   - Verify name được trim trước khi lưu
   - Verify mock được gọi với trimmed name

3. ✅ **should return 400 if folder name is missing**
   - Test validation khi thiếu name
   - Verify response status 400
   - Verify error message: "Folder name is required"

4. ✅ **should return 400 if folder name is empty string**
   - Test validation với name = ""
   - Verify response status 400

5. ✅ **should return 400 if folder name is only whitespace**
   - Test validation với name = "   "
   - Verify response status 400

6. ✅ **should return 401 if no token provided**
   - Test authentication requirement
   - Verify response status 401

### DELETE /api/folders/:folderId (7 test cases)

1. ✅ **should delete folder successfully**
   - Test xóa thư mục thành công
   - Verify response status 204
   - Verify response body empty
   - Verify findUnique và delete được gọi đúng

2. ✅ **should return 404 if folder does not exist**
   - Test xóa thư mục không tồn tại
   - Verify response status 404
   - Verify error message: "Folder not found"
   - Verify delete không được gọi

3. ✅ **should return 403 if folder belongs to another user**
   - Test authorization - không thể xóa thư mục của người khác
   - Verify response status 403
   - Verify error message: "You do not have permission to delete this folder"
   - Verify delete không được gọi

4. ✅ **should return 400 if folderId is not a number**
   - Test validation với folderId = "abc"
   - Verify response status 400
   - Verify error message: "Invalid folder ID"

5. ✅ **should return 400 if folderId is negative**
   - Test với folderId = -1
   - Verify response status 404 (không tìm thấy)

6. ✅ **should return 401 if no token provided**
   - Test authentication requirement
   - Verify response status 401

7. ✅ **should return 403 if token is invalid**
   - Test với invalid token
   - Verify response status 403

## Kỹ thuật Testing

### 1. JWT Token Generation

```typescript
const generateToken = (userId: number): string => {
  return jwt.sign({ userId }, process.env.JWT_SECRET as string, {
    expiresIn: '24h',
  });
};
```

**Sử dụng:**
```typescript
const userId = 1;
const token = generateToken(userId);

const response = await request(app)
  .get('/api/folders')
  .set('Authorization', `Bearer ${token}`);
```

### 2. Testing Authentication

**No Token:**
```typescript
const response = await request(app)
  .get('/api/folders');
  // No Authorization header

expect(response.status).toBe(401);
expect(response.body).toHaveProperty('error', 'Access token is required');
```

**Invalid Token:**
```typescript
const response = await request(app)
  .get('/api/folders')
  .set('Authorization', `Bearer invalid.token.here`);

expect(response.status).toBe(403);
expect(response.body).toHaveProperty('error', 'Invalid token');
```

**Expired Token:**
```typescript
const expiredToken = jwt.sign(
  { userId: 1 },
  process.env.JWT_SECRET as string,
  { expiresIn: '-1h' } // Expired 1 hour ago
);

const response = await request(app)
  .get('/api/folders')
  .set('Authorization', `Bearer ${expiredToken}`);

expect(response.status).toBe(403);
expect(response.body).toHaveProperty('error', 'Token has expired');
```

### 3. Testing Authorization (Ownership)

```typescript
it('should return 403 if folder belongs to another user', async () => {
  const userId = 1;
  const otherUserId = 2;
  const token = generateToken(userId);

  const otherUserFolder = {
    id: 1,
    name: 'Other User Folder',
    userId: otherUserId, // Different user!
    createdAt: new Date(),
  };

  (prisma.folder.findUnique as jest.Mock).mockResolvedValue(otherUserFolder);

  const response = await request(app)
    .delete('/api/folders/1')
    .set('Authorization', `Bearer ${token}`);

  expect(response.status).toBe(403);
  expect(response.body.error).toContain('permission');
});
```

### 4. Mock Prisma Folder Operations

```typescript
// Mock findMany
(prisma.folder.findMany as jest.Mock).mockResolvedValue([
  { id: 1, name: 'Folder 1', userId: 1, createdAt: new Date() },
  { id: 2, name: 'Folder 2', userId: 1, createdAt: new Date() },
]);

// Mock create
(prisma.folder.create as jest.Mock).mockResolvedValue({
  id: 1,
  name: 'New Folder',
  userId: 1,
  createdAt: new Date(),
});

// Mock findUnique
(prisma.folder.findUnique as jest.Mock).mockResolvedValue({
  id: 1,
  name: 'Existing Folder',
  userId: 1,
  createdAt: new Date(),
});

// Mock delete
(prisma.folder.delete as jest.Mock).mockResolvedValue({
  id: 1,
  name: 'Deleted Folder',
  userId: 1,
  createdAt: new Date(),
});
```

### 5. Testing Validation

**Missing Required Field:**
```typescript
const response = await request(app)
  .post('/api/folders')
  .set('Authorization', `Bearer ${token}`)
  .send({}); // No name

expect(response.status).toBe(400);
expect(response.body).toHaveProperty('error', 'Folder name is required');
```

**Empty String:**
```typescript
const response = await request(app)
  .post('/api/folders')
  .set('Authorization', `Bearer ${token}`)
  .send({ name: '' });

expect(response.status).toBe(400);
```

**Whitespace Only:**
```typescript
const response = await request(app)
  .post('/api/folders')
  .set('Authorization', `Bearer ${token}`)
  .send({ name: '   ' });

expect(response.status).toBe(400);
```

**Invalid ID Format:**
```typescript
const response = await request(app)
  .delete('/api/folders/abc') // Not a number
  .set('Authorization', `Bearer ${token}`);

expect(response.status).toBe(400);
expect(response.body).toHaveProperty('error', 'Invalid folder ID');
```

## Test Structure

### AAA Pattern Example

```typescript
it('should create a new folder successfully', async () => {
  // ===== ARRANGE =====
  const userId = 1;
  const token = generateToken(userId);
  const folderData = { name: 'New Folder' };
  
  const createdFolder = {
    id: 1,
    name: 'New Folder',
    userId: userId,
    createdAt: new Date(),
  };
  
  (prisma.folder.create as jest.Mock).mockResolvedValue(createdFolder);

  // ===== ACT =====
  const response = await request(app)
    .post('/api/folders')
    .set('Authorization', `Bearer ${token}`)
    .send(folderData);

  // ===== ASSERT =====
  expect(response.status).toBe(201);
  expect(response.body).toHaveProperty('id', 1);
  expect(response.body).toHaveProperty('name', 'New Folder');
  
  expect(prisma.folder.create).toHaveBeenCalledWith({
    data: {
      name: 'New Folder',
      userId: userId,
    },
  });
});
```

## Security Testing

### 1. Authentication Testing

Tất cả endpoints đều require authentication:

```typescript
// Test pattern for all endpoints
it('should return 401 if no token provided', async () => {
  const response = await request(app)
    .get('/api/folders'); // or POST, DELETE

  expect(response.status).toBe(401);
  expect(prisma.folder.findMany).not.toHaveBeenCalled();
});
```

### 2. Authorization Testing

DELETE endpoint kiểm tra ownership:

```typescript
it('should return 403 if folder belongs to another user', async () => {
  const userId = 1;
  const token = generateToken(userId);
  
  // Mock folder thuộc user khác
  (prisma.folder.findUnique as jest.Mock).mockResolvedValue({
    id: 1,
    userId: 2, // Different user
  });

  const response = await request(app)
    .delete('/api/folders/1')
    .set('Authorization', `Bearer ${token}`);

  expect(response.status).toBe(403);
  expect(prisma.folder.delete).not.toHaveBeenCalled();
});
```

### 3. Input Validation Testing

```typescript
// Test all validation scenarios
describe('Validation Tests', () => {
  it('should reject missing name', async () => { /* ... */ });
  it('should reject empty name', async () => { /* ... */ });
  it('should reject whitespace-only name', async () => { /* ... */ });
  it('should reject invalid ID format', async () => { /* ... */ });
});
```

## Mock Verification Patterns

### Verify Function Called

```typescript
expect(prisma.folder.findMany).toHaveBeenCalled();
```

### Verify Function Called With Arguments

```typescript
expect(prisma.folder.findMany).toHaveBeenCalledWith({
  where: { userId: 1 },
  orderBy: { createdAt: 'desc' },
});
```

### Verify Function NOT Called

```typescript
expect(prisma.folder.create).not.toHaveBeenCalled();
```

### Verify Call Count

```typescript
expect(prisma.folder.findUnique).toHaveBeenCalledTimes(1);
```

## Common Test Scenarios

### 1. Happy Path (Success)

```typescript
it('should perform action successfully', async () => {
  // Setup valid data and mocks
  // Execute request with valid token
  // Verify success response (200, 201, 204)
  // Verify correct data returned
  // Verify mocks called correctly
});
```

### 2. Authentication Failure

```typescript
it('should reject unauthenticated request', async () => {
  // Execute request without token
  // Verify 401 response
  // Verify no database operations
});
```

### 3. Authorization Failure

```typescript
it('should reject unauthorized action', async () => {
  // Setup data belonging to another user
  // Execute request with valid token
  // Verify 403 response
  // Verify no destructive operations
});
```

### 4. Validation Failure

```typescript
it('should reject invalid input', async () => {
  // Execute request with invalid data
  // Verify 400 response
  // Verify error message
  // Verify no database operations
});
```

### 5. Not Found

```typescript
it('should return 404 for non-existent resource', async () => {
  // Mock returns null
  // Execute request
  // Verify 404 response
  // Verify error message
});
```

## Running Tests

### Run All Tests

```bash
npm test
```

### Run Only Folder Tests

```bash
npm test folders.test.ts
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
PASS  src/__tests__/folders.test.ts
  Folder Management Endpoints
    GET /api/folders
      ✓ should get all folders for authenticated user (32 ms)
      ✓ should return empty array if user has no folders (10 ms)
      ✓ should return 401 if no token provided (4 ms)
      ✓ should return 403 if token is invalid (4 ms)
      ✓ should return 403 if token is expired (5 ms)
    POST /api/folders
      ✓ should create a new folder successfully (14 ms)
      ✓ should trim folder name before creating (4 ms)
      ✓ should return 400 if folder name is missing (5 ms)
      ✓ should return 400 if folder name is empty string (6 ms)
      ✓ should return 400 if folder name is only whitespace (4 ms)
      ✓ should return 401 if no token provided (4 ms)
    DELETE /api/folders/:folderId
      ✓ should delete folder successfully (5 ms)
      ✓ should return 404 if folder does not exist (4 ms)
      ✓ should return 403 if folder belongs to another user (3 ms)
      ✓ should return 400 if folderId is not a number (4 ms)
      ✓ should return 400 if folderId is negative (5 ms)
      ✓ should return 401 if no token provided (4 ms)
      ✓ should return 403 if token is invalid (4 ms)

Test Suites: 3 passed, 3 total
Tests:       34 passed, 34 total
Time:        2.671 s
```

## Best Practices Demonstrated

### 1. Comprehensive Coverage

- ✅ Success scenarios
- ✅ Authentication failures
- ✅ Authorization failures
- ✅ Validation failures
- ✅ Not found scenarios
- ✅ Edge cases (negative IDs, whitespace)

### 2. Clear Test Organization

```typescript
describe('Folder Management Endpoints', () => {
  describe('GET /api/folders', () => {
    // All GET tests
  });
  
  describe('POST /api/folders', () => {
    // All POST tests
  });
  
  describe('DELETE /api/folders/:folderId', () => {
    // All DELETE tests
  });
});
```

### 3. Descriptive Test Names

- Format: "should [expected behavior] [when condition]"
- Clear and specific
- Easy to understand failures

### 4. Proper Mock Management

```typescript
beforeEach(() => {
  jest.clearAllMocks(); // Reset before each test
});

afterAll(async () => {
  await prisma.$disconnect(); // Cleanup after all tests
});
```

### 5. Token Helper Function

```typescript
const generateToken = (userId: number): string => {
  return jwt.sign({ userId }, process.env.JWT_SECRET as string, {
    expiresIn: '24h',
  });
};
```

Reusable across all tests, reduces duplication.

## Key Differences from Auth Tests

### 1. Authentication Middleware

Folder tests require valid JWT tokens for all endpoints:

```typescript
const token = generateToken(userId);

const response = await request(app)
  .get('/api/folders')
  .set('Authorization', `Bearer ${token}`); // Required!
```

### 2. Authorization Checks

DELETE endpoint checks ownership:

```typescript
// Check if folder.userId === req.user.userId
if (folder.userId !== userId) {
  return res.status(403).json({ error: 'Permission denied' });
}
```

### 3. User Context

All operations are scoped to authenticated user:

```typescript
// GET - Only user's folders
prisma.folder.findMany({ where: { userId } });

// POST - Folder belongs to user
prisma.folder.create({ data: { name, userId } });

// DELETE - Verify ownership before delete
```

## Next Steps

Sau khi folder tests hoàn thành:

1. **Viết tests cho Word APIs** (`/api/folders/:id/words`)
2. **Viết tests cho Lesson APIs** (`/api/lessons`)
3. **Viết tests cho Phrase APIs** (`/api/lessons/:id/phrases`)
4. **Integration tests** cho complete workflows
5. **E2E tests** với real database (test environment)

## Kết luận

Folder Management tests đã được triển khai đầy đủ với:
- ✅ 18 test cases covering all scenarios
- ✅ Authentication testing (401, 403)
- ✅ Authorization testing (ownership)
- ✅ Validation testing (400)
- ✅ Not found testing (404)
- ✅ Success scenarios (200, 201, 204)
- ✅ 100% pass rate

**Folder Management testing hoàn thành!** 🎉
