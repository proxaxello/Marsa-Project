import request from 'supertest';
import app from '../index';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';

// Mock PrismaClient
jest.mock('@prisma/client', () => {
  const mockPrismaClient = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    folder: {
      findMany: jest.fn(),
      create: jest.fn(),
      findUnique: jest.fn(),
      delete: jest.fn(),
    },
    word: {
      findMany: jest.fn(),
      create: jest.fn(),
      findUnique: jest.fn(),
      delete: jest.fn(),
    },
    lesson: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    phrase: {
      findMany: jest.fn(),
    },
    $disconnect: jest.fn(),
  };
  return {
    PrismaClient: jest.fn(() => mockPrismaClient),
  };
});

// Mock dotenv
jest.mock('dotenv', () => ({
  config: jest.fn(),
}));

// Set test environment variables
process.env.JWT_SECRET = 'test_secret_key_for_testing';
process.env.NODE_ENV = 'test';

const prisma = new PrismaClient();

// Helper function to generate valid JWT token
const generateToken = (userId: number): string => {
  return jwt.sign({ userId }, process.env.JWT_SECRET as string, {
    expiresIn: '24h',
  });
};

describe('Voice Lab Endpoints', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  // ==================== GET /api/lessons TESTS ====================

  describe('GET /api/lessons', () => {
    it('should get all lessons successfully', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);

      const mockLessons = [
        {
          id: 1,
          title: 'Greetings',
          description: 'Basic greetings in English',
          difficulty: 'beginner',
          createdAt: new Date('2024-01-01'),
        },
        {
          id: 2,
          title: 'Business Conversations',
          description: 'Professional business phrases',
          difficulty: 'intermediate',
          createdAt: new Date('2024-01-02'),
        },
        {
          id: 3,
          title: 'Advanced Idioms',
          description: 'Common English idioms',
          difficulty: 'advanced',
          createdAt: new Date('2024-01-03'),
        },
      ];

      // Mock: lessons exist
      (prisma.lesson.findMany as jest.Mock).mockResolvedValue(mockLessons);

      // Act
      const response = await request(app)
        .get('/api/lessons')
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(3);
      expect(response.body[0]).toHaveProperty('id', 1);
      expect(response.body[0]).toHaveProperty('title', 'Greetings');
      expect(response.body[0]).toHaveProperty('description', 'Basic greetings in English');
      expect(response.body[0]).toHaveProperty('difficulty', 'beginner');
      expect(response.body[1]).toHaveProperty('id', 2);
      expect(response.body[1]).toHaveProperty('title', 'Business Conversations');
      expect(response.body[2]).toHaveProperty('id', 3);

      // Verify mocks
      expect(prisma.lesson.findMany).toHaveBeenCalledWith({
        orderBy: { createdAt: 'desc' },
      });
    });

    it('should return empty array if no lessons exist', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);

      // Mock: no lessons
      (prisma.lesson.findMany as jest.Mock).mockResolvedValue([]);

      // Act
      const response = await request(app)
        .get('/api/lessons')
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toEqual([]);
      expect(response.body).toHaveLength(0);

      // Verify mock
      expect(prisma.lesson.findMany).toHaveBeenCalledWith({
        orderBy: { createdAt: 'desc' },
      });
    });

    it('should return 401 if no token provided', async () => {
      // Act
      const response = await request(app)
        .get('/api/lessons');
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls
      expect(prisma.lesson.findMany).not.toHaveBeenCalled();
    });

    it('should return 403 if token is invalid', async () => {
      // Arrange
      const invalidToken = 'invalid.token.here';

      // Act
      const response = await request(app)
        .get('/api/lessons')
        .set('Authorization', `Bearer ${invalidToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Invalid token');

      // Verify no database calls
      expect(prisma.lesson.findMany).not.toHaveBeenCalled();
    });

    it('should return 403 if token is expired', async () => {
      // Arrange
      const expiredToken = jwt.sign(
        { userId: 1 },
        process.env.JWT_SECRET as string,
        { expiresIn: '-1h' } // Expired 1 hour ago
      );

      // Act
      const response = await request(app)
        .get('/api/lessons')
        .set('Authorization', `Bearer ${expiredToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Token has expired');

      // Verify no database calls
      expect(prisma.lesson.findMany).not.toHaveBeenCalled();
    });
  });

  // ==================== GET /api/lessons/:lessonId/phrases TESTS ====================

  describe('GET /api/lessons/:lessonId/phrases', () => {
    it('should get all phrases in lesson successfully', async () => {
      // Arrange
      const userId = 1;
      const lessonId = 1;
      const token = generateToken(userId);

      const mockLesson = {
        id: lessonId,
        title: 'Greetings',
        description: 'Basic greetings',
        difficulty: 'beginner',
        createdAt: new Date('2024-01-01'),
      };

      const mockPhrases = [
        {
          id: 1,
          text: 'Hello, how are you?',
          translation: 'Xin chào, bạn khỏe không?',
          audioUrl: 'https://example.com/audio1.mp3',
          lessonId: lessonId,
          createdAt: new Date('2024-01-01'),
        },
        {
          id: 2,
          text: 'Good morning!',
          translation: 'Chào buổi sáng!',
          audioUrl: 'https://example.com/audio2.mp3',
          lessonId: lessonId,
          createdAt: new Date('2024-01-02'),
        },
        {
          id: 3,
          text: 'Nice to meet you.',
          translation: 'Rất vui được gặp bạn.',
          audioUrl: 'https://example.com/audio3.mp3',
          lessonId: lessonId,
          createdAt: new Date('2024-01-03'),
        },
      ];

      // Mock: lesson exists
      (prisma.lesson.findUnique as jest.Mock).mockResolvedValue(mockLesson);
      
      // Mock: phrases in lesson
      (prisma.phrase.findMany as jest.Mock).mockResolvedValue(mockPhrases);

      // Act
      const response = await request(app)
        .get(`/api/lessons/${lessonId}/phrases`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(3);
      expect(response.body[0]).toHaveProperty('id', 1);
      expect(response.body[0]).toHaveProperty('text', 'Hello, how are you?');
      expect(response.body[0]).toHaveProperty('translation', 'Xin chào, bạn khỏe không?');
      expect(response.body[0]).toHaveProperty('audioUrl', 'https://example.com/audio1.mp3');
      expect(response.body[1]).toHaveProperty('id', 2);
      expect(response.body[2]).toHaveProperty('id', 3);

      // Verify mocks
      expect(prisma.lesson.findUnique).toHaveBeenCalledWith({
        where: { id: lessonId },
      });
      expect(prisma.phrase.findMany).toHaveBeenCalledWith({
        where: { lessonId },
        orderBy: { createdAt: 'asc' },
      });
    });

    it('should return empty array if lesson has no phrases', async () => {
      // Arrange
      const userId = 1;
      const lessonId = 1;
      const token = generateToken(userId);

      const mockLesson = {
        id: lessonId,
        title: 'Empty Lesson',
        description: 'No phrases yet',
        difficulty: 'beginner',
        createdAt: new Date(),
      };

      // Mock: lesson exists but has no phrases
      (prisma.lesson.findUnique as jest.Mock).mockResolvedValue(mockLesson);
      (prisma.phrase.findMany as jest.Mock).mockResolvedValue([]);

      // Act
      const response = await request(app)
        .get(`/api/lessons/${lessonId}/phrases`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toEqual([]);
      expect(response.body).toHaveLength(0);

      // Verify mocks
      expect(prisma.lesson.findUnique).toHaveBeenCalledWith({
        where: { id: lessonId },
      });
      expect(prisma.phrase.findMany).toHaveBeenCalledWith({
        where: { lessonId },
        orderBy: { createdAt: 'asc' },
      });
    });

    it('should return 404 if lesson does not exist', async () => {
      // Arrange
      const userId = 1;
      const lessonId = 999;
      const token = generateToken(userId);

      // Mock: lesson doesn't exist
      (prisma.lesson.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      const response = await request(app)
        .get(`/api/lessons/${lessonId}/phrases`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Lesson not found');

      // Verify lesson.findUnique was called
      expect(prisma.lesson.findUnique).toHaveBeenCalledWith({
        where: { id: lessonId },
      });

      // Verify phrase.findMany was NOT called
      expect(prisma.phrase.findMany).not.toHaveBeenCalled();
    });

    it('should return 400 if lessonId is not a number', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidLessonId = 'abc';

      // Act
      const response = await request(app)
        .get(`/api/lessons/${invalidLessonId}/phrases`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Invalid lesson ID');

      // Verify no database calls
      expect(prisma.lesson.findUnique).not.toHaveBeenCalled();
      expect(prisma.phrase.findMany).not.toHaveBeenCalled();
    });

    it('should return 400 if lessonId is negative', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const negativeLessonId = -1;

      // Mock: lesson doesn't exist (negative ID won't exist)
      (prisma.lesson.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      const response = await request(app)
        .get(`/api/lessons/${negativeLessonId}/phrases`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Lesson not found');

      // Verify lesson.findUnique was called (validation passes, but lesson not found)
      expect(prisma.lesson.findUnique).toHaveBeenCalledWith({
        where: { id: negativeLessonId },
      });
    });

    it('should return 401 if no token provided', async () => {
      // Arrange
      const lessonId = 1;

      // Act
      const response = await request(app)
        .get(`/api/lessons/${lessonId}/phrases`);
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls
      expect(prisma.lesson.findUnique).not.toHaveBeenCalled();
      expect(prisma.phrase.findMany).not.toHaveBeenCalled();
    });

    it('should return 403 if token is invalid', async () => {
      // Arrange
      const lessonId = 1;
      const invalidToken = 'invalid.token.here';

      // Act
      const response = await request(app)
        .get(`/api/lessons/${lessonId}/phrases`)
        .set('Authorization', `Bearer ${invalidToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Invalid token');

      // Verify no database calls
      expect(prisma.lesson.findUnique).not.toHaveBeenCalled();
      expect(prisma.phrase.findMany).not.toHaveBeenCalled();
    });

    it('should return 403 if token is expired', async () => {
      // Arrange
      const lessonId = 1;
      const expiredToken = jwt.sign(
        { userId: 1 },
        process.env.JWT_SECRET as string,
        { expiresIn: '-1h' } // Expired 1 hour ago
      );

      // Act
      const response = await request(app)
        .get(`/api/lessons/${lessonId}/phrases`)
        .set('Authorization', `Bearer ${expiredToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Token has expired');

      // Verify no database calls
      expect(prisma.lesson.findUnique).not.toHaveBeenCalled();
      expect(prisma.phrase.findMany).not.toHaveBeenCalled();
    });
  });
});
