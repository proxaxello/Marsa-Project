# Testing Guide - Marsa Backend

## Tổng quan

Backend Marsa sử dụng **Jest** làm framework testing chính với **ts-jest** để hỗ trợ TypeScript. Hệ thống testing bao gồm unit tests và integration tests để đảm bảo chất lượng code.

## Cài đặt

### Dependencies đã cài đặt

```json
{
  "devDependencies": {
    "jest": "^30.2.0",
    "@types/jest": "^30.0.0",
    "ts-jest": "^29.4.5"
  }
}
```

### Cài đặt thủ công (nếu cần)

```bash
npm install -D jest @types/jest ts-jest
```

## Cấu hình Jest

### jest.config.ts

```typescript
import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  verbose: true,
  collectCoverage: false,
  coverageDirectory: 'coverage',
  testMatch: [
    '**/__tests__/**/*.test.ts',
    '**/?(*.)+(spec|test).ts'
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  roots: ['<rootDir>/src'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
};

export default config;
```

**Giải thích:**
- `preset: 'ts-jest'` - Sử dụng ts-jest để compile TypeScript
- `testEnvironment: 'node'` - Môi trường Node.js (không phải browser)
- `verbose: true` - Hiển thị chi tiết kết quả test
- `testMatch` - Pattern để tìm file test
- `roots` - Thư mục gốc chứa source code và tests

## Scripts NPM

### package.json

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

**Sử dụng:**

```bash
# Chạy tất cả tests một lần
npm test

# Chạy tests ở chế độ watch (tự động chạy lại khi file thay đổi)
npm run test:watch

# Chạy tests và tạo báo cáo coverage
npm run test:coverage
```

## Cấu trúc thư mục

```
backend/
├── src/
│   ├── __tests__/              # Thư mục chứa tất cả tests
│   │   ├── example.test.ts     # Test ví dụ
│   │   ├── auth.test.ts        # Tests cho authentication
│   │   ├── folder.test.ts      # Tests cho folder APIs
│   │   ├── word.test.ts        # Tests cho word APIs
│   │   └── lesson.test.ts      # Tests cho lesson APIs
│   └── index.ts                # Main application file
├── jest.config.ts              # Jest configuration
└── package.json
```

## Viết Tests

### Test cơ bản

```typescript
describe('Example Test Suite', () => {
  it('should return true', () => {
    expect(true).toBe(true);
  });

  it('should perform basic arithmetic', () => {
    expect(2 + 2).toBe(4);
  });
});
```

### Test với setup và teardown

```typescript
describe('User Service', () => {
  let userService: UserService;

  beforeAll(() => {
    // Chạy một lần trước tất cả tests
    console.log('Setting up test suite');
  });

  beforeEach(() => {
    // Chạy trước mỗi test
    userService = new UserService();
  });

  afterEach(() => {
    // Chạy sau mỗi test
    // Cleanup nếu cần
  });

  afterAll(() => {
    // Chạy một lần sau tất cả tests
    console.log('Cleaning up test suite');
  });

  it('should create a user', () => {
    const user = userService.createUser('test@example.com');
    expect(user.email).toBe('test@example.com');
  });
});
```

### Test async functions

```typescript
describe('Async Operations', () => {
  it('should fetch data asynchronously', async () => {
    const data = await fetchData();
    expect(data).toBeDefined();
    expect(data.length).toBeGreaterThan(0);
  });

  it('should handle promises', () => {
    return fetchData().then(data => {
      expect(data).toBeDefined();
    });
  });

  it('should handle rejected promises', async () => {
    await expect(fetchInvalidData()).rejects.toThrow('Invalid data');
  });
});
```

### Test với mocks

```typescript
describe('API Service', () => {
  it('should call external API', async () => {
    // Mock fetch function
    const mockFetch = jest.fn().mockResolvedValue({
      json: async () => ({ data: 'test' })
    });
    global.fetch = mockFetch;

    const result = await apiService.getData();
    
    expect(mockFetch).toHaveBeenCalledTimes(1);
    expect(result.data).toBe('test');
  });
});
```

## Jest Matchers

### Equality Matchers

```typescript
expect(value).toBe(expected);           // Strict equality (===)
expect(value).toEqual(expected);        // Deep equality
expect(value).not.toBe(expected);       // Negation
```

### Truthiness Matchers

```typescript
expect(value).toBeTruthy();             // Truthy value
expect(value).toBeFalsy();              // Falsy value
expect(value).toBeNull();               // null
expect(value).toBeUndefined();          // undefined
expect(value).toBeDefined();            // Not undefined
```

### Number Matchers

```typescript
expect(value).toBeGreaterThan(3);
expect(value).toBeGreaterThanOrEqual(3.5);
expect(value).toBeLessThan(5);
expect(value).toBeLessThanOrEqual(4.5);
expect(value).toBeCloseTo(0.3);         // Floating point
```

### String Matchers

```typescript
expect(string).toMatch(/pattern/);
expect(string).toContain('substring');
```

### Array/Iterable Matchers

```typescript
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(array).toEqual(expect.arrayContaining([item1, item2]));
```

### Object Matchers

```typescript
expect(object).toHaveProperty('key');
expect(object).toHaveProperty('key', value);
expect(object).toMatchObject({ key: value });
```

### Exception Matchers

```typescript
expect(() => fn()).toThrow();
expect(() => fn()).toThrow(Error);
expect(() => fn()).toThrow('error message');
expect(async () => await fn()).rejects.toThrow();
```

## Best Practices

### 1. Test Organization

```typescript
describe('Feature Name', () => {
  describe('Subfeature or Method', () => {
    it('should do something specific', () => {
      // Test implementation
    });
  });
});
```

### 2. Test Naming

- Sử dụng mô tả rõ ràng: `should return user when valid ID is provided`
- Tránh tên chung chung: `test1`, `works`
- Mô tả behavior, không phải implementation

### 3. AAA Pattern (Arrange-Act-Assert)

```typescript
it('should calculate total price', () => {
  // Arrange - Setup test data
  const items = [
    { price: 10, quantity: 2 },
    { price: 5, quantity: 3 }
  ];

  // Act - Execute the function
  const total = calculateTotal(items);

  // Assert - Verify the result
  expect(total).toBe(35);
});
```

### 4. One Assertion Per Test (khi có thể)

```typescript
// Good
it('should return correct name', () => {
  expect(user.name).toBe('John');
});

it('should return correct email', () => {
  expect(user.email).toBe('john@example.com');
});

// Acceptable when testing related properties
it('should create user with correct properties', () => {
  expect(user.name).toBe('John');
  expect(user.email).toBe('john@example.com');
  expect(user.age).toBe(30);
});
```

### 5. Avoid Test Interdependence

```typescript
// Bad - Tests depend on each other
let userId;
it('should create user', () => {
  userId = createUser();
  expect(userId).toBeDefined();
});
it('should get user', () => {
  const user = getUser(userId); // Depends on previous test
  expect(user).toBeDefined();
});

// Good - Each test is independent
it('should create user', () => {
  const userId = createUser();
  expect(userId).toBeDefined();
});
it('should get user', () => {
  const userId = createUser(); // Create own data
  const user = getUser(userId);
  expect(user).toBeDefined();
});
```

## Testing Strategies

### Unit Tests

Test individual functions/methods in isolation:

```typescript
describe('calculateDiscount', () => {
  it('should apply 10% discount for regular customers', () => {
    const price = 100;
    const discount = calculateDiscount(price, 'regular');
    expect(discount).toBe(90);
  });

  it('should apply 20% discount for VIP customers', () => {
    const price = 100;
    const discount = calculateDiscount(price, 'vip');
    expect(discount).toBe(80);
  });
});
```

### Integration Tests

Test how multiple components work together:

```typescript
describe('User Registration Flow', () => {
  it('should register user and send welcome email', async () => {
    const userData = {
      email: 'test@example.com',
      password: 'password123'
    };

    const user = await registerUser(userData);
    expect(user).toBeDefined();
    expect(user.email).toBe(userData.email);
    
    // Verify email was sent
    expect(emailService.sendWelcomeEmail).toHaveBeenCalledWith(user.email);
  });
});
```

### API Endpoint Tests

Test Express routes:

```typescript
import request from 'supertest';
import app from '../index';

describe('POST /api/login', () => {
  it('should login with valid credentials', async () => {
    const response = await request(app)
      .post('/api/login')
      .send({
        email: 'test@example.com',
        password: 'password123'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('token');
  });

  it('should reject invalid credentials', async () => {
    const response = await request(app)
      .post('/api/login')
      .send({
        email: 'test@example.com',
        password: 'wrongpassword'
      });

    expect(response.status).toBe(401);
    expect(response.body).toHaveProperty('error');
  });
});
```

## Code Coverage

### Chạy coverage report

```bash
npm run test:coverage
```

### Đọc coverage report

```
--------------------|---------|----------|---------|---------|-------------------
File                | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
--------------------|---------|----------|---------|---------|-------------------
All files           |   85.71 |    66.67 |     100 |   85.71 |
 index.ts           |   85.71 |    66.67 |     100 |   85.71 | 15-16
--------------------|---------|----------|---------|---------|-------------------
```

**Metrics:**
- **% Stmts** - Percentage of statements executed
- **% Branch** - Percentage of branches (if/else) executed
- **% Funcs** - Percentage of functions called
- **% Lines** - Percentage of lines executed

**Coverage Goals:**
- Aim for 80%+ coverage
- Focus on critical paths first
- 100% coverage is not always necessary

## Troubleshooting

### Issue: Tests không chạy

**Solution:**
```bash
# Kiểm tra Jest đã được cài đặt
npm list jest

# Reinstall nếu cần
npm install -D jest @types/jest ts-jest
```

### Issue: TypeScript errors trong tests

**Solution:**
- Kiểm tra `jest.config.ts` có `preset: 'ts-jest'`
- Kiểm tra `tsconfig.json` include test files
- Restart TypeScript server trong IDE

### Issue: Module not found

**Solution:**
```typescript
// jest.config.ts
moduleNameMapper: {
  '^@/(.*)$': '<rootDir>/src/$1'
}
```

### Issue: Tests chạy chậm

**Solution:**
```bash
# Chạy tests song song
jest --maxWorkers=4

# Chỉ chạy tests đã thay đổi
jest --onlyChanged

# Chạy tests liên quan đến files đã thay đổi
jest --watch
```

## Next Steps

Sau khi thiết lập xong môi trường testing:

1. **Viết Unit Tests** cho các functions/utilities
2. **Viết Integration Tests** cho API endpoints
3. **Mock Database** để test không ảnh hưởng data thật
4. **Setup CI/CD** để tự động chạy tests
5. **Monitor Coverage** và cải thiện dần

## Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [ts-jest Documentation](https://kulshekhar.github.io/ts-jest/)
- [Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)

## Kết luận

Môi trường testing đã được thiết lập thành công với:
- ✅ Jest và ts-jest đã cài đặt
- ✅ Configuration file (`jest.config.ts`)
- ✅ NPM scripts (`test`, `test:watch`, `test:coverage`)
- ✅ Test directory structure (`src/__tests__`)
- ✅ Example test file chạy thành công

**Task 11.1 hoàn thành!** 🎉
