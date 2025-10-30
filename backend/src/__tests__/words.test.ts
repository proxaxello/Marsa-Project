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

describe('Word Management Endpoints', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  // ==================== GET /api/folders/:folderId/words TESTS ====================

  describe('GET /api/folders/:folderId/words', () => {
    it('should get all words in folder successfully', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const mockFolder = {
        id: folderId,
        name: 'Business English',
        userId: userId,
        createdAt: new Date('2024-01-01'),
      };

      const mockWords = [
        {
          id: 1,
          text: 'hello',
          meaning: 'xin chào',
          folderId: folderId,
          createdAt: new Date('2024-01-01'),
        },
        {
          id: 2,
          text: 'goodbye',
          meaning: 'tạm biệt',
          folderId: folderId,
          createdAt: new Date('2024-01-02'),
        },
      ];

      // Mock: folder exists and belongs to user
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(mockFolder);
      
      // Mock: words in folder
      (prisma.word.findMany as jest.Mock).mockResolvedValue(mockWords);

      // Act
      const response = await request(app)
        .get(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(2);
      expect(response.body[0]).toHaveProperty('id', 1);
      expect(response.body[0]).toHaveProperty('text', 'hello');
      expect(response.body[0]).toHaveProperty('meaning', 'xin chào');
      expect(response.body[1]).toHaveProperty('id', 2);

      // Verify mocks
      expect(prisma.folder.findUnique).toHaveBeenCalledWith({
        where: { id: folderId },
      });
      expect(prisma.word.findMany).toHaveBeenCalledWith({
        where: { folderId },
        orderBy: { createdAt: 'desc' },
      });
    });

    it('should return empty array if folder has no words', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const mockFolder = {
        id: folderId,
        name: 'Empty Folder',
        userId: userId,
        createdAt: new Date(),
      };

      // Mock: folder exists but has no words
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(mockFolder);
      (prisma.word.findMany as jest.Mock).mockResolvedValue([]);

      // Act
      const response = await request(app)
        .get(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toEqual([]);
      expect(response.body).toHaveLength(0);
    });

    it('should return 404 if folder does not exist', async () => {
      // Arrange
      const userId = 1;
      const folderId = 999;
      const token = generateToken(userId);

      // Mock: folder doesn't exist
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      const response = await request(app)
        .get(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Folder not found');

      // Verify word.findMany was NOT called
      expect(prisma.word.findMany).not.toHaveBeenCalled();
    });

    it('should return 403 if folder belongs to another user', async () => {
      // Arrange
      const userId = 1;
      const otherUserId = 2;
      const folderId = 1;
      const token = generateToken(userId);

      const otherUserFolder = {
        id: folderId,
        name: 'Other User Folder',
        userId: otherUserId, // Different user
        createdAt: new Date(),
      };

      // Mock: folder exists but belongs to another user
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(otherUserFolder);

      // Act
      const response = await request(app)
        .get(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'You do not have permission to access this folder');

      // Verify word.findMany was NOT called
      expect(prisma.word.findMany).not.toHaveBeenCalled();
    });

    it('should return 400 if folderId is not a number', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidFolderId = 'abc';

      // Act
      const response = await request(app)
        .get(`/api/folders/${invalidFolderId}/words`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Invalid folder ID');

      // Verify no database calls
      expect(prisma.folder.findUnique).not.toHaveBeenCalled();
      expect(prisma.word.findMany).not.toHaveBeenCalled();
    });

    it('should return 401 if no token provided', async () => {
      // Arrange
      const folderId = 1;

      // Act
      const response = await request(app)
        .get(`/api/folders/${folderId}/words`);
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls
      expect(prisma.folder.findUnique).not.toHaveBeenCalled();
      expect(prisma.word.findMany).not.toHaveBeenCalled();
    });
  });

  // ==================== POST /api/folders/:folderId/words TESTS ====================

  describe('POST /api/folders/:folderId/words', () => {
    it('should add word to folder successfully', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const wordData = {
        text: 'hello',
        meaning: 'xin chào',
      };

      const mockFolder = {
        id: folderId,
        name: 'Business English',
        userId: userId,
        createdAt: new Date(),
      };

      const createdWord = {
        id: 1,
        text: 'hello',
        meaning: 'xin chào',
        folderId: folderId,
        createdAt: new Date('2024-01-01'),
      };

      // Mock: folder exists and belongs to user
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(mockFolder);
      
      // Mock: word.create
      (prisma.word.create as jest.Mock).mockResolvedValue(createdWord);

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(wordData);

      // Assert
      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id', 1);
      expect(response.body).toHaveProperty('text', 'hello');
      expect(response.body).toHaveProperty('meaning', 'xin chào');
      expect(response.body).toHaveProperty('folderId', folderId);

      // Verify mocks
      expect(prisma.folder.findUnique).toHaveBeenCalledWith({
        where: { id: folderId },
      });
      expect(prisma.word.create).toHaveBeenCalledWith({
        data: {
          text: 'hello',
          meaning: 'xin chào',
          folderId: folderId,
        },
      });
    });

    it('should trim text and meaning before creating', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const wordData = {
        text: '  hello  ',
        meaning: '  xin chào  ',
      };

      const mockFolder = {
        id: folderId,
        name: 'Business English',
        userId: userId,
        createdAt: new Date(),
      };

      const createdWord = {
        id: 1,
        text: 'hello',
        meaning: 'xin chào',
        folderId: folderId,
        createdAt: new Date(),
      };

      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(mockFolder);
      (prisma.word.create as jest.Mock).mockResolvedValue(createdWord);

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(wordData);

      // Assert
      expect(response.status).toBe(201);

      // Verify text and meaning were trimmed
      expect(prisma.word.create).toHaveBeenCalledWith({
        data: {
          text: 'hello', // Trimmed
          meaning: 'xin chào', // Trimmed
          folderId: folderId,
        },
      });
    });

    it('should return 400 if text is missing', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const invalidData = {
        meaning: 'xin chào',
        // text is missing
      };

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Word text is required');

      // Verify word.create was NOT called
      expect(prisma.word.create).not.toHaveBeenCalled();
    });

    it('should return 400 if meaning is missing', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const invalidData = {
        text: 'hello',
        // meaning is missing
      };

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Word meaning is required');

      // Verify word.create was NOT called
      expect(prisma.word.create).not.toHaveBeenCalled();
    });

    it('should return 400 if text is empty string', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const invalidData = {
        text: '',
        meaning: 'xin chào',
      };

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Word text is required');
    });

    it('should return 400 if text is only whitespace', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const invalidData = {
        text: '   ',
        meaning: 'xin chào',
      };

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Word text is required');
    });

    it('should return 404 if folder does not exist', async () => {
      // Arrange
      const userId = 1;
      const folderId = 999;
      const token = generateToken(userId);

      const wordData = {
        text: 'hello',
        meaning: 'xin chào',
      };

      // Mock: folder doesn't exist
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(wordData);

      // Assert
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Folder not found');

      // Verify word.create was NOT called
      expect(prisma.word.create).not.toHaveBeenCalled();
    });

    it('should return 403 if folder belongs to another user', async () => {
      // Arrange
      const userId = 1;
      const otherUserId = 2;
      const folderId = 1;
      const token = generateToken(userId);

      const wordData = {
        text: 'hello',
        meaning: 'xin chào',
      };

      const otherUserFolder = {
        id: folderId,
        name: 'Other User Folder',
        userId: otherUserId, // Different user
        createdAt: new Date(),
      };

      // Mock: folder exists but belongs to another user
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(otherUserFolder);

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .set('Authorization', `Bearer ${token}`)
        .send(wordData);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'You do not have permission to add words to this folder');

      // Verify word.create was NOT called
      expect(prisma.word.create).not.toHaveBeenCalled();
    });

    it('should return 401 if no token provided', async () => {
      // Arrange
      const folderId = 1;
      const wordData = {
        text: 'hello',
        meaning: 'xin chào',
      };

      // Act
      const response = await request(app)
        .post(`/api/folders/${folderId}/words`)
        .send(wordData);
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls
      expect(prisma.folder.findUnique).not.toHaveBeenCalled();
      expect(prisma.word.create).not.toHaveBeenCalled();
    });
  });

  // ==================== DELETE /api/words/:wordId TESTS ====================

  describe('DELETE /api/words/:wordId', () => {
    it('should delete word successfully', async () => {
      // Arrange
      const userId = 1;
      const wordId = 1;
      const token = generateToken(userId);

      const existingWord = {
        id: wordId,
        text: 'hello',
        meaning: 'xin chào',
        folderId: 1,
        createdAt: new Date(),
        folder: {
          id: 1,
          name: 'Business English',
          userId: userId, // Belongs to current user
          createdAt: new Date(),
        },
      };

      // Mock: word exists and belongs to user's folder
      (prisma.word.findUnique as jest.Mock).mockResolvedValue(existingWord);
      
      // Mock: word.delete
      (prisma.word.delete as jest.Mock).mockResolvedValue(existingWord);

      // Act
      const response = await request(app)
        .delete(`/api/words/${wordId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(204);
      expect(response.body).toEqual({});

      // Verify mocks
      expect(prisma.word.findUnique).toHaveBeenCalledWith({
        where: { id: wordId },
        include: { folder: true },
      });
      expect(prisma.word.delete).toHaveBeenCalledWith({
        where: { id: wordId },
      });
    });

    it('should return 404 if word does not exist', async () => {
      // Arrange
      const userId = 1;
      const wordId = 999;
      const token = generateToken(userId);

      // Mock: word doesn't exist
      (prisma.word.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      const response = await request(app)
        .delete(`/api/words/${wordId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Word not found');

      // Verify word.delete was NOT called
      expect(prisma.word.delete).not.toHaveBeenCalled();
    });

    it('should return 403 if word belongs to another user folder', async () => {
      // Arrange
      const userId = 1;
      const otherUserId = 2;
      const wordId = 1;
      const token = generateToken(userId);

      const otherUserWord = {
        id: wordId,
        text: 'hello',
        meaning: 'xin chào',
        folderId: 1,
        createdAt: new Date(),
        folder: {
          id: 1,
          name: 'Other User Folder',
          userId: otherUserId, // Different user
          createdAt: new Date(),
        },
      };

      // Mock: word exists but belongs to another user's folder
      (prisma.word.findUnique as jest.Mock).mockResolvedValue(otherUserWord);

      // Act
      const response = await request(app)
        .delete(`/api/words/${wordId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'You do not have permission to delete this word');

      // Verify word.delete was NOT called
      expect(prisma.word.delete).not.toHaveBeenCalled();
    });

    it('should return 400 if wordId is not a number', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidWordId = 'abc';

      // Act
      const response = await request(app)
        .delete(`/api/words/${invalidWordId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Invalid word ID');

      // Verify no database calls
      expect(prisma.word.findUnique).not.toHaveBeenCalled();
      expect(prisma.word.delete).not.toHaveBeenCalled();
    });

    it('should return 401 if no token provided', async () => {
      // Arrange
      const wordId = 1;

      // Act
      const response = await request(app)
        .delete(`/api/words/${wordId}`);
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls
      expect(prisma.word.findUnique).not.toHaveBeenCalled();
      expect(prisma.word.delete).not.toHaveBeenCalled();
    });

    it('should return 403 if token is invalid', async () => {
      // Arrange
      const wordId = 1;
      const invalidToken = 'invalid.token.here';

      // Act
      const response = await request(app)
        .delete(`/api/words/${wordId}`)
        .set('Authorization', `Bearer ${invalidToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Invalid token');

      // Verify no database calls
      expect(prisma.word.findUnique).not.toHaveBeenCalled();
      expect(prisma.word.delete).not.toHaveBeenCalled();
    });
  });
});
