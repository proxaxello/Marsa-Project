import request from 'supertest';
import app from '../index';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

// Mock PrismaClient
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

// Mock bcrypt
jest.mock('bcrypt');

// Mock dotenv
jest.mock('dotenv', () => ({
  config: jest.fn(),
}));

// Set test environment variables
process.env.JWT_SECRET = 'test_secret_key_for_testing';
process.env.NODE_ENV = 'test';

const prisma = new PrismaClient();

describe('Authentication Endpoints', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  // ==================== REGISTER ENDPOINT TESTS ====================

  describe('POST /api/register', () => {
    it('should register a new user successfully', async () => {
      // Arrange
      const newUserData = {
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User',
      };

      const hashedPassword = 'hashed_password_123';
      const createdUser = {
        id: 1,
        email: newUserData.email,
        name: newUserData.name,
        password: hashedPassword,
        createdAt: new Date('2024-01-01'),
        updatedAt: new Date('2024-01-01'),
      };

      // Mock: User doesn't exist
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(null);
      
      // Mock: bcrypt.hash
      (bcrypt.hash as jest.Mock).mockResolvedValue(hashedPassword);
      
      // Mock: User creation
      (prisma.user.create as jest.Mock).mockResolvedValue(createdUser);

      // Act
      const response = await request(app)
        .post('/api/register')
        .send(newUserData);

      // Assert
      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('email', newUserData.email);
      expect(response.body).toHaveProperty('name', newUserData.name);
      expect(response.body).toHaveProperty('createdAt');
      expect(response.body).not.toHaveProperty('password'); // Password should not be in response

      // Verify mocks were called correctly
      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { email: newUserData.email },
      });
      expect(bcrypt.hash).toHaveBeenCalledWith(newUserData.password, 10);
      expect(prisma.user.create).toHaveBeenCalledWith({
        data: {
          email: newUserData.email,
          name: newUserData.name,
          password: hashedPassword,
        },
      });
    });

    it('should return 400 if email already exists', async () => {
      // Arrange
      const existingUserData = {
        email: 'existing@example.com',
        password: 'password123',
        name: 'Existing User',
      };

      const existingUser = {
        id: 1,
        email: existingUserData.email,
        name: existingUserData.name,
        password: 'hashed_password',
        createdAt: new Date('2024-01-01'),
        updatedAt: new Date('2024-01-01'),
      };

      // Mock: User already exists
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(existingUser);

      // Act
      const response = await request(app)
        .post('/api/register')
        .send(existingUserData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'User with this email already exists');
      
      // Verify user.create was NOT called
      expect(prisma.user.create).not.toHaveBeenCalled();
    });

    it('should return 400 if email is missing', async () => {
      // Arrange
      const invalidData = {
        password: 'password123',
        name: 'Test User',
      };

      // Act
      const response = await request(app)
        .post('/api/register')
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Email and password are required');
      
      // Verify no database calls were made
      expect(prisma.user.findUnique).not.toHaveBeenCalled();
      expect(prisma.user.create).not.toHaveBeenCalled();
    });

    it('should return 400 if password is missing', async () => {
      // Arrange
      const invalidData = {
        email: 'test@example.com',
        name: 'Test User',
      };

      // Act
      const response = await request(app)
        .post('/api/register')
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Email and password are required');
      
      // Verify no database calls were made
      expect(prisma.user.findUnique).not.toHaveBeenCalled();
      expect(prisma.user.create).not.toHaveBeenCalled();
    });

    it('should register user without name (optional field)', async () => {
      // Arrange
      const userData = {
        email: 'noname@example.com',
        password: 'password123',
      };

      const hashedPassword = 'hashed_password_123';
      const createdUser = {
        id: 2,
        email: userData.email,
        name: null,
        password: hashedPassword,
        createdAt: new Date('2024-01-01'),
        updatedAt: new Date('2024-01-01'),
      };

      // Mock setup
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue(hashedPassword);
      (prisma.user.create as jest.Mock).mockResolvedValue(createdUser);

      // Act
      const response = await request(app)
        .post('/api/register')
        .send(userData);

      // Assert
      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('email', userData.email);
      expect(response.body.name).toBeNull();
    });
  });

  // ==================== LOGIN ENDPOINT TESTS ====================

  describe('POST /api/login', () => {
    it('should login successfully with valid credentials', async () => {
      // Arrange
      const loginData = {
        email: 'user@example.com',
        password: 'password123',
      };

      const hashedPassword = await bcrypt.hash('password123', 10);
      const existingUser = {
        id: 1,
        email: loginData.email,
        name: 'Test User',
        password: hashedPassword,
        createdAt: new Date('2024-01-01'),
        updatedAt: new Date('2024-01-01'),
      };

      // Mock: User exists
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(existingUser);
      
      // Mock: Password comparison succeeds
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      // Act
      const response = await request(app)
        .post('/api/login')
        .send(loginData);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('user');
      expect(response.body.user).toHaveProperty('id', existingUser.id);
      expect(response.body.user).toHaveProperty('email', existingUser.email);
      expect(response.body.user).toHaveProperty('name', existingUser.name);
      expect(response.body.user).not.toHaveProperty('password'); // Password should not be in response

      // Verify token is a string
      expect(typeof response.body.token).toBe('string');
      expect(response.body.token.length).toBeGreaterThan(0);

      // Verify mocks were called
      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { email: loginData.email },
      });
      expect(bcrypt.compare).toHaveBeenCalledWith(loginData.password, existingUser.password);
    });

    it('should return 400 if password is incorrect', async () => {
      // Arrange
      const loginData = {
        email: 'user@example.com',
        password: 'wrongpassword',
      };

      const existingUser = {
        id: 1,
        email: loginData.email,
        name: 'Test User',
        password: 'hashed_correct_password',
        createdAt: new Date('2024-01-01'),
        updatedAt: new Date('2024-01-01'),
      };

      // Mock: User exists
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(existingUser);
      
      // Mock: Password comparison fails
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      // Act
      const response = await request(app)
        .post('/api/login')
        .send(loginData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Invalid email or password');
      expect(response.body).not.toHaveProperty('token');
    });

    it('should return 400 if email does not exist', async () => {
      // Arrange
      const loginData = {
        email: 'nonexistent@example.com',
        password: 'password123',
      };

      // Mock: User doesn't exist
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      const response = await request(app)
        .post('/api/login')
        .send(loginData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Invalid email or password');
      expect(response.body).not.toHaveProperty('token');
      
      // Verify bcrypt.compare was NOT called
      expect(bcrypt.compare).not.toHaveBeenCalled();
    });

    it('should return 400 if email is missing', async () => {
      // Arrange
      const invalidData = {
        password: 'password123',
      };

      // Act
      const response = await request(app)
        .post('/api/login')
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Email and password are required');
      
      // Verify no database calls were made
      expect(prisma.user.findUnique).not.toHaveBeenCalled();
    });

    it('should return 400 if password is missing', async () => {
      // Arrange
      const invalidData = {
        email: 'user@example.com',
      };

      // Act
      const response = await request(app)
        .post('/api/login')
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Email and password are required');
      
      // Verify no database calls were made
      expect(prisma.user.findUnique).not.toHaveBeenCalled();
    });

    it('should return 400 if both email and password are missing', async () => {
      // Arrange
      const invalidData = {};

      // Act
      const response = await request(app)
        .post('/api/login')
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Email and password are required');
    });
  });
});
