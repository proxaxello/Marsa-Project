# Authentication Testing Guide

## Tổng quan

File `src/__tests__/auth.test.ts` chứa unit tests đầy đủ cho các authentication endpoints của backend Marsa. Tests này sử dụng mocking để không phụ thuộc vào database thật.

## Test Coverage

### POST /api/register (5 test cases)

1. ✅ **should register a new user successfully**
   - Test đăng ký thành công với email, password và name
   - Verify response status 201
   - Verify response chứa id, email, name, createdAt
   - Verify password không có trong response
   - Verify các mock functions được gọi đúng

2. ✅ **should return 400 if email already exists**
   - Test trường hợp email đã tồn tại trong database
   - Verify response status 400
   - Verify error message: "User with this email already exists"
   - Verify user.create không được gọi

3. ✅ **should return 400 if email is missing**
   - Test validation khi thiếu email
   - Verify response status 400
   - Verify error message: "Email and password are required"
   - Verify không có database calls

4. ✅ **should return 400 if password is missing**
   - Test validation khi thiếu password
   - Verify response status 400
   - Verify error message: "Email and password are required"
   - Verify không có database calls

5. ✅ **should register user without name (optional field)**
   - Test đăng ký với name = undefined (optional)
   - Verify response status 201
   - Verify name = null trong response

### POST /api/login (6 test cases)

1. ✅ **should login successfully with valid credentials**
   - Test đăng nhập thành công với email và password đúng
   - Verify response status 200
   - Verify response chứa token (JWT)
   - Verify response chứa user info (id, email, name)
   - Verify password không có trong response
   - Verify token là string và có length > 0

2. ✅ **should return 400 if password is incorrect**
   - Test đăng nhập với password sai
   - Verify response status 400
   - Verify error message: "Invalid email or password"
   - Verify không có token trong response

3. ✅ **should return 400 if email does not exist**
   - Test đăng nhập với email không tồn tại
   - Verify response status 400
   - Verify error message: "Invalid email or password"
   - Verify bcrypt.compare không được gọi

4. ✅ **should return 400 if email is missing**
   - Test validation khi thiếu email
   - Verify response status 400
   - Verify error message: "Email and password are required"

5. ✅ **should return 400 if password is missing**
   - Test validation khi thiếu password
   - Verify response status 400
   - Verify error message: "Email and password are required"

6. ✅ **should return 400 if both email and password are missing**
   - Test validation khi thiếu cả email và password
   - Verify response status 400
   - Verify error message: "Email and password are required"

## Kỹ thuật Mocking

### 1. Mock PrismaClient

```typescript
jest.mock('@prisma/client', () => {
  const mockPrismaClient = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    $disconnect: jest.fn(),
  };
  return {
    PrismaClient: jest.fn(() => mockPrismaClient),
  };
});
```

**Giải thích:**
- Mock toàn bộ `@prisma/client` module
- Tạo mock functions cho `user.findUnique` và `user.create`
- Mỗi test case sẽ config mock này trả về giá trị khác nhau

### 2. Mock bcrypt

```typescript
jest.mock('bcrypt');
```

**Sử dụng trong tests:**
```typescript
// Mock password hashing
(bcrypt.hash as jest.Mock).mockResolvedValue('hashed_password_123');

// Mock password comparison
(bcrypt.compare as jest.Mock).mockResolvedValue(true); // Success
(bcrypt.compare as jest.Mock).mockResolvedValue(false); // Failure
```

### 3. Mock Environment Variables

```typescript
process.env.JWT_SECRET = 'test_secret_key_for_testing';
process.env.NODE_ENV = 'test';
```

**Lý do:**
- JWT_SECRET cần thiết để tạo và verify tokens
- NODE_ENV = 'test' để tránh start server thật

## Cấu trúc Test Case

### AAA Pattern (Arrange-Act-Assert)

```typescript
it('should register a new user successfully', async () => {
  // ===== ARRANGE =====
  // Setup test data
  const newUserData = {
    email: 'newuser@example.com',
    password: 'password123',
    name: 'New User',
  };

  // Setup mock responses
  (prisma.user.findUnique as jest.Mock).mockResolvedValue(null);
  (bcrypt.hash as jest.Mock).mockResolvedValue('hashed_password');
  (prisma.user.create as jest.Mock).mockResolvedValue(createdUser);

  // ===== ACT =====
  // Execute the API call
  const response = await request(app)
    .post('/api/register')
    .send(newUserData);

  // ===== ASSERT =====
  // Verify the results
  expect(response.status).toBe(201);
  expect(response.body).toHaveProperty('email', newUserData.email);
  
  // Verify mock calls
  expect(prisma.user.findUnique).toHaveBeenCalledWith({
    where: { email: newUserData.email },
  });
});
```

## Lifecycle Hooks

### beforeEach

```typescript
beforeEach(() => {
  jest.clearAllMocks();
});
```

**Mục đích:**
- Clear tất cả mock calls trước mỗi test
- Đảm bảo tests độc lập với nhau
- Tránh side effects giữa các tests

### afterAll

```typescript
afterAll(async () => {
  await prisma.$disconnect();
});
```

**Mục đích:**
- Cleanup sau khi tất cả tests chạy xong
- Disconnect Prisma client
- Giải phóng resources

## Supertest Usage

### Gửi POST Request

```typescript
const response = await request(app)
  .post('/api/register')
  .send({
    email: 'test@example.com',
    password: 'password123',
  });
```

### Verify Response

```typescript
// Status code
expect(response.status).toBe(201);

// Response body properties
expect(response.body).toHaveProperty('id');
expect(response.body).toHaveProperty('email', 'test@example.com');

// Property should NOT exist
expect(response.body).not.toHaveProperty('password');

// Type checking
expect(typeof response.body.token).toBe('string');
expect(response.body.token.length).toBeGreaterThan(0);
```

## Mock Verification

### Verify Function Calls

```typescript
// Verify function was called
expect(prisma.user.findUnique).toHaveBeenCalled();

// Verify function was called with specific arguments
expect(prisma.user.findUnique).toHaveBeenCalledWith({
  where: { email: 'test@example.com' },
});

// Verify function was called specific number of times
expect(prisma.user.create).toHaveBeenCalledTimes(1);

// Verify function was NOT called
expect(prisma.user.create).not.toHaveBeenCalled();
```

## Test Data Management

### Consistent Test Data

```typescript
const testUser = {
  id: 1,
  email: 'test@example.com',
  name: 'Test User',
  password: 'hashed_password',
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date('2024-01-01'),
};
```

**Best Practices:**
- Sử dụng email addresses rõ ràng (`newuser@`, `existing@`, `nonexistent@`)
- Sử dụng dates cố định để dễ debug
- Tách biệt test data cho mỗi scenario

## Error Scenarios

### Testing Error Responses

```typescript
it('should return 400 if email already exists', async () => {
  // Mock: User exists
  (prisma.user.findUnique as jest.Mock).mockResolvedValue(existingUser);

  const response = await request(app)
    .post('/api/register')
    .send(userData);

  // Verify error response
  expect(response.status).toBe(400);
  expect(response.body).toHaveProperty('error');
  expect(response.body.error).toBe('User with this email already exists');
});
```

### Testing Validation

```typescript
it('should return 400 if email is missing', async () => {
  const response = await request(app)
    .post('/api/register')
    .send({ password: 'password123' }); // Missing email

  expect(response.status).toBe(400);
  expect(response.body.error).toBe('Email and password are required');
  
  // Verify no database operations
  expect(prisma.user.findUnique).not.toHaveBeenCalled();
});
```

## Security Testing

### Password Hashing

```typescript
it('should hash password before storing', async () => {
  // Setup
  (bcrypt.hash as jest.Mock).mockResolvedValue('hashed_password');
  
  // Execute
  await request(app).post('/api/register').send(userData);
  
  // Verify bcrypt.hash was called with correct parameters
  expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
  
  // Verify hashed password was stored, not plain text
  expect(prisma.user.create).toHaveBeenCalledWith({
    data: expect.objectContaining({
      password: 'hashed_password', // Not 'password123'
    }),
  });
});
```

### Password Not in Response

```typescript
it('should not return password in response', async () => {
  const response = await request(app)
    .post('/api/register')
    .send(userData);

  expect(response.body).not.toHaveProperty('password');
});
```

### JWT Token Generation

```typescript
it('should return valid JWT token on login', async () => {
  const response = await request(app)
    .post('/api/login')
    .send(loginData);

  expect(response.body).toHaveProperty('token');
  expect(typeof response.body.token).toBe('string');
  expect(response.body.token.length).toBeGreaterThan(0);
  
  // Token should have 3 parts (header.payload.signature)
  expect(response.body.token.split('.').length).toBe(3);
});
```

## Running Tests

### Run All Tests

```bash
npm test
```

### Run Specific Test File

```bash
npm test auth.test.ts
```

### Run Tests in Watch Mode

```bash
npm run test:watch
```

### Run Tests with Coverage

```bash
npm run test:coverage
```

## Test Results

```
PASS  src/__tests__/auth.test.ts
  Authentication Endpoints
    POST /api/register
      ✓ should register a new user successfully (81 ms)
      ✓ should return 400 if email already exists (6 ms)
      ✓ should return 400 if email is missing (7 ms)
      ✓ should return 400 if password is missing (5 ms)
      ✓ should register user without name (optional field) (7 ms)
    POST /api/login
      ✓ should login successfully with valid credentials (11 ms)
      ✓ should return 400 if password is incorrect (5 ms)
      ✓ should return 400 if email does not exist (4 ms)
      ✓ should return 400 if email is missing (7 ms)
      ✓ should return 400 if password is missing (4 ms)
      ✓ should return 400 if both email and password are missing (4 ms)

Test Suites: 2 passed, 2 total
Tests:       16 passed, 16 total
Snapshots:   0 total
Time:        1.842 s
```

## Best Practices Demonstrated

### 1. Test Independence
- Mỗi test case độc lập, không phụ thuộc vào kết quả của test khác
- Sử dụng `beforeEach` để reset mocks

### 2. Clear Test Names
- Tên test mô tả rõ ràng behavior được test
- Format: "should [expected behavior] when [condition]"

### 3. Comprehensive Coverage
- Test cả success cases và error cases
- Test validation logic
- Test edge cases (optional fields, missing fields)

### 4. Mock Verification
- Verify mock functions được gọi đúng
- Verify mock functions được gọi với đúng arguments
- Verify mock functions KHÔNG được gọi khi không nên

### 5. Security Focus
- Test password hashing
- Test password không có trong response
- Test JWT token generation

### 6. Realistic Test Data
- Sử dụng email addresses thực tế
- Sử dụng password có độ dài hợp lý
- Sử dụng dates cố định

## Common Pitfalls to Avoid

### ❌ Don't: Test Implementation Details

```typescript
// Bad - Testing internal implementation
expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
```

### ✅ Do: Test Behavior

```typescript
// Good - Testing behavior/outcome
expect(response.status).toBe(201);
expect(response.body).toHaveProperty('id');
```

### ❌ Don't: Share State Between Tests

```typescript
// Bad - Shared state
let userId;
it('should create user', () => {
  userId = response.body.id;
});
it('should get user', () => {
  // Uses userId from previous test
});
```

### ✅ Do: Keep Tests Independent

```typescript
// Good - Each test creates its own data
it('should create user', () => {
  const userId = createTestUser();
});
it('should get user', () => {
  const userId = createTestUser();
});
```

### ❌ Don't: Use Real Database

```typescript
// Bad - Connects to real database
const prisma = new PrismaClient();
await prisma.user.create(...);
```

### ✅ Do: Use Mocks

```typescript
// Good - Uses mocked Prisma
(prisma.user.create as jest.Mock).mockResolvedValue(mockUser);
```

## Next Steps

Sau khi authentication tests hoàn thành:

1. **Viết tests cho Folder APIs** (`/api/folders`)
2. **Viết tests cho Word APIs** (`/api/folders/:id/words`)
3. **Viết tests cho Lesson APIs** (`/api/lessons`)
4. **Viết tests cho JWT middleware** (`authenticateToken`)
5. **Setup CI/CD** để tự động chạy tests

## Resources

- [Jest Documentation](https://jestjs.io/)
- [Supertest Documentation](https://github.com/ladjs/supertest)
- [Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)

## Kết luận

Authentication tests đã được triển khai đầy đủ với:
- ✅ 11 test cases covering all scenarios
- ✅ Proper mocking (Prisma, bcrypt, dotenv)
- ✅ Security testing (password hashing, JWT)
- ✅ Validation testing
- ✅ Error handling testing
- ✅ 100% pass rate

**Authentication testing hoàn thành!** 🎉
