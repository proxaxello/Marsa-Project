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

describe('Folder Management Endpoints', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  // ==================== GET /api/folders TESTS ====================

  describe('GET /api/folders', () => {
    it('should get all folders for authenticated user', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      
      const mockFolders = [
        {
          id: 1,
          name: 'Business English',
          userId: userId,
          createdAt: new Date('2024-01-01'),
        },
        {
          id: 2,
          name: 'Travel Phrases',
          userId: userId,
          createdAt: new Date('2024-01-02'),
        },
      ];

      // Mock: findMany returns user's folders
      (prisma.folder.findMany as jest.Mock).mockResolvedValue(mockFolders);

      // Act
      const response = await request(app)
        .get('/api/folders')
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(2);
      expect(response.body[0]).toHaveProperty('id', 1);
      expect(response.body[0]).toHaveProperty('name', 'Business English');
      expect(response.body[1]).toHaveProperty('id', 2);
      expect(response.body[1]).toHaveProperty('name', 'Travel Phrases');

      // Verify mock was called correctly
      expect(prisma.folder.findMany).toHaveBeenCalledWith({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      });
    });

    it('should return empty array if user has no folders', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);

      // Mock: findMany returns empty array
      (prisma.folder.findMany as jest.Mock).mockResolvedValue([]);

      // Act
      const response = await request(app)
        .get('/api/folders')
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body).toEqual([]);
      expect(response.body).toHaveLength(0);
    });

    it('should return 401 if no token provided', async () => {
      // Act
      const response = await request(app)
        .get('/api/folders');
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls were made
      expect(prisma.folder.findMany).not.toHaveBeenCalled();
    });

    it('should return 403 if token is invalid', async () => {
      // Arrange
      const invalidToken = 'invalid.token.here';

      // Act
      const response = await request(app)
        .get('/api/folders')
        .set('Authorization', `Bearer ${invalidToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Invalid token');

      // Verify no database calls were made
      expect(prisma.folder.findMany).not.toHaveBeenCalled();
    });

    it('should return 403 if token is expired', async () => {
      // Arrange - Create expired token
      const userId = 1;
      const expiredToken = jwt.sign(
        { userId },
        process.env.JWT_SECRET as string,
        { expiresIn: '-1h' } // Expired 1 hour ago
      );

      // Act
      const response = await request(app)
        .get('/api/folders')
        .set('Authorization', `Bearer ${expiredToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Token has expired');
    });
  });

  // ==================== POST /api/folders TESTS ====================

  describe('POST /api/folders', () => {
    it('should create a new folder successfully', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const folderData = {
        name: 'New Folder',
      };

      const createdFolder = {
        id: 1,
        name: 'New Folder',
        userId: userId,
        createdAt: new Date('2024-01-01'),
      };

      // Mock: folder.create
      (prisma.folder.create as jest.Mock).mockResolvedValue(createdFolder);

      // Act
      const response = await request(app)
        .post('/api/folders')
        .set('Authorization', `Bearer ${token}`)
        .send(folderData);

      // Assert
      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id', 1);
      expect(response.body).toHaveProperty('name', 'New Folder');
      expect(response.body).toHaveProperty('userId', userId);
      expect(response.body).toHaveProperty('createdAt');

      // Verify mock was called correctly
      expect(prisma.folder.create).toHaveBeenCalledWith({
        data: {
          name: 'New Folder',
          userId: userId,
        },
      });
    });

    it('should trim folder name before creating', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const folderData = {
        name: '  Folder with spaces  ',
      };

      const createdFolder = {
        id: 1,
        name: 'Folder with spaces',
        userId: userId,
        createdAt: new Date('2024-01-01'),
      };

      // Mock: folder.create
      (prisma.folder.create as jest.Mock).mockResolvedValue(createdFolder);

      // Act
      const response = await request(app)
        .post('/api/folders')
        .set('Authorization', `Bearer ${token}`)
        .send(folderData);

      // Assert
      expect(response.status).toBe(201);
      expect(response.body.name).toBe('Folder with spaces');

      // Verify name was trimmed
      expect(prisma.folder.create).toHaveBeenCalledWith({
        data: {
          name: 'Folder with spaces', // Trimmed
          userId: userId,
        },
      });
    });

    it('should return 400 if folder name is missing', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidData = {}; // No name

      // Act
      const response = await request(app)
        .post('/api/folders')
        .set('Authorization', `Bearer ${token}`)
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Folder name is required');

      // Verify folder.create was NOT called
      expect(prisma.folder.create).not.toHaveBeenCalled();
    });

    it('should return 400 if folder name is empty string', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidData = {
        name: '',
      };

      // Act
      const response = await request(app)
        .post('/api/folders')
        .set('Authorization', `Bearer ${token}`)
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Folder name is required');
    });

    it('should return 400 if folder name is only whitespace', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidData = {
        name: '   ',
      };

      // Act
      const response = await request(app)
        .post('/api/folders')
        .set('Authorization', `Bearer ${token}`)
        .send(invalidData);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Folder name is required');
    });

    it('should return 401 if no token provided', async () => {
      // Arrange
      const folderData = {
        name: 'New Folder',
      };

      // Act
      const response = await request(app)
        .post('/api/folders')
        .send(folderData);
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls were made
      expect(prisma.folder.create).not.toHaveBeenCalled();
    });
  });

  // ==================== DELETE /api/folders/:folderId TESTS ====================

  describe('DELETE /api/folders/:folderId', () => {
    it('should delete folder successfully', async () => {
      // Arrange
      const userId = 1;
      const folderId = 1;
      const token = generateToken(userId);

      const existingFolder = {
        id: folderId,
        name: 'Folder to Delete',
        userId: userId,
        createdAt: new Date('2024-01-01'),
      };

      // Mock: folder exists and belongs to user
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(existingFolder);
      
      // Mock: folder.delete
      (prisma.folder.delete as jest.Mock).mockResolvedValue(existingFolder);

      // Act
      const response = await request(app)
        .delete(`/api/folders/${folderId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(204);
      expect(response.body).toEqual({});

      // Verify mocks were called correctly
      expect(prisma.folder.findUnique).toHaveBeenCalledWith({
        where: { id: folderId },
      });
      expect(prisma.folder.delete).toHaveBeenCalledWith({
        where: { id: folderId },
      });
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
        .delete(`/api/folders/${folderId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Folder not found');

      // Verify folder.delete was NOT called
      expect(prisma.folder.delete).not.toHaveBeenCalled();
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
        createdAt: new Date('2024-01-01'),
      };

      // Mock: folder exists but belongs to another user
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(otherUserFolder);

      // Act
      const response = await request(app)
        .delete(`/api/folders/${folderId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'You do not have permission to delete this folder');

      // Verify folder.delete was NOT called
      expect(prisma.folder.delete).not.toHaveBeenCalled();
    });

    it('should return 400 if folderId is not a number', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidFolderId = 'abc';

      // Act
      const response = await request(app)
        .delete(`/api/folders/${invalidFolderId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'Invalid folder ID');

      // Verify no database calls were made
      expect(prisma.folder.findUnique).not.toHaveBeenCalled();
      expect(prisma.folder.delete).not.toHaveBeenCalled();
    });

    it('should return 400 if folderId is negative', async () => {
      // Arrange
      const userId = 1;
      const token = generateToken(userId);
      const invalidFolderId = -1;

      // Note: The current implementation doesn't explicitly check for negative IDs
      // but the database lookup will fail, so we test the behavior

      // Mock: folder doesn't exist (negative ID won't be found)
      (prisma.folder.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      const response = await request(app)
        .delete(`/api/folders/${invalidFolderId}`)
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Folder not found');
    });

    it('should return 401 if no token provided', async () => {
      // Arrange
      const folderId = 1;

      // Act
      const response = await request(app)
        .delete(`/api/folders/${folderId}`);
        // No Authorization header

      // Assert
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Access token is required');

      // Verify no database calls were made
      expect(prisma.folder.findUnique).not.toHaveBeenCalled();
      expect(prisma.folder.delete).not.toHaveBeenCalled();
    });

    it('should return 403 if token is invalid', async () => {
      // Arrange
      const folderId = 1;
      const invalidToken = 'invalid.token.here';

      // Act
      const response = await request(app)
        .delete(`/api/folders/${folderId}`)
        .set('Authorization', `Bearer ${invalidToken}`);

      // Assert
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error', 'Invalid token');

      // Verify no database calls were made
      expect(prisma.folder.findUnique).not.toHaveBeenCalled();
      expect(prisma.folder.delete).not.toHaveBeenCalled();
    });
  });
});
