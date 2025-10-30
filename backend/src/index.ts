import express, { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// Load environment variables
dotenv.config();

// Initialize Prisma client
const prisma = new PrismaClient();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(express.json());

// JWT Authentication Middleware
interface AuthRequest extends Request {
  user?: {
    userId: number;
  };
}

function authenticateToken(req: AuthRequest, res: Response, next: NextFunction) {
  // Get token from Authorization header
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Format: "Bearer <token>"
  
  // If no token provided, return 401 Unauthorized
  if (!token) {
    return res.status(401).json({ error: 'Access token is required' });
  }
  
  // Verify token
  const jwtSecret = process.env.JWT_SECRET;
  
  if (!jwtSecret) {
    console.error('JWT_SECRET is not defined in environment variables');
    return res.status(500).json({ error: 'Server configuration error' });
  }
  
  try {
    // Verify and decode the token
    const decoded = jwt.verify(token, jwtSecret) as { userId: number };
    
    // Attach user info to request object
    req.user = { userId: decoded.userId };
    
    // Continue to the next middleware/route handler
    next();
  } catch (error) {
    // Token is invalid or expired
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(403).json({ error: 'Token has expired' });
    }
    return res.status(403).json({ error: 'Invalid token' });
  }
}

// Routes
app.get('/', (req: Request, res: Response) => {
  res.json({ message: 'Hello from Marsa Backend!' });
});

// User routes
app.get('/api/users', async (req: Request, res: Response) => {
  try {
    const users = await prisma.user.findMany();
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Protected route example - Get current user profile
app.get('/api/profile', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    // Get user ID from the authenticated request
    const userId = req.user?.userId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    
    // Fetch user from database
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        updatedAt: true
        // Password is excluded from the select
      }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.status(200).json(user);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// User registration endpoint
app.post('/api/register', async (req: Request, res: Response) => {
  try {
    const { email, name, password } = req.body;
    
    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    
    // Check if user with this email already exists
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });
    
    if (existingUser) {
      return res.status(400).json({ error: 'User with this email already exists' });
    }
    
    // Hash the password using bcrypt (10 rounds of salt)
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Create new user with hashed password
    const newUser = await prisma.user.create({
      data: {
        email,
        name,
        password: hashedPassword
      }
    });
    
    // Return the created user (excluding sensitive information)
    res.status(201).json({
      id: newUser.id,
      email: newUser.email,
      name: newUser.name,
      createdAt: newUser.createdAt
      // Password is intentionally not included in the response
    });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

// ==================== FOLDER MANAGEMENT ROUTES ====================

// Get all folders for the authenticated user
app.get('/api/folders', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    
    // Fetch all folders belonging to the user
    const folders = await prisma.folder.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' }
    });
    
    res.status(200).json(folders);
  } catch (error) {
    console.error('Error fetching folders:', error);
    res.status(500).json({ error: 'Failed to fetch folders' });
  }
});

// Create a new folder
app.post('/api/folders', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { name } = req.body;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    
    // Validate folder name
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Folder name is required' });
    }
    
    // Create new folder
    const newFolder = await prisma.folder.create({
      data: {
        name: name.trim(),
        userId
      }
    });
    
    res.status(201).json(newFolder);
  } catch (error) {
    console.error('Error creating folder:', error);
    res.status(500).json({ error: 'Failed to create folder' });
  }
});

// Delete a folder
app.delete('/api/folders/:folderId', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const folderIdParam = req.params.folderId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    
    // Validate folderId
    if (!folderIdParam) {
      return res.status(400).json({ error: 'Folder ID is required' });
    }
    
    const folderId = parseInt(folderIdParam);
    
    if (isNaN(folderId)) {
      return res.status(400).json({ error: 'Invalid folder ID' });
    }
    
    // Check if folder exists and belongs to the user
    const folder = await prisma.folder.findUnique({
      where: { id: folderId }
    });
    
    if (!folder) {
      return res.status(404).json({ error: 'Folder not found' });
    }
    
    // Check ownership
    if (folder.userId !== userId) {
      return res.status(403).json({ error: 'You do not have permission to delete this folder' });
    }
    
    // Delete the folder
    await prisma.folder.delete({
      where: { id: folderId }
    });
    
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting folder:', error);
    res.status(500).json({ error: 'Failed to delete folder' });
  }
});

// ==================== WORD MANAGEMENT ROUTES ====================

// Get all words in a specific folder
app.get('/api/folders/:folderId/words', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const folderIdParam = req.params.folderId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    
    // Validate folderId
    if (!folderIdParam) {
      return res.status(400).json({ error: 'Folder ID is required' });
    }
    
    const folderId = parseInt(folderIdParam);
    
    if (isNaN(folderId)) {
      return res.status(400).json({ error: 'Invalid folder ID' });
    }
    
    // Check if folder exists and belongs to the user
    const folder = await prisma.folder.findUnique({
      where: { id: folderId }
    });
    
    if (!folder) {
      return res.status(404).json({ error: 'Folder not found' });
    }
    
    // Check ownership
    if (folder.userId !== userId) {
      return res.status(403).json({ error: 'You do not have permission to access this folder' });
    }
    
    // Fetch all words in the folder
    const words = await prisma.word.findMany({
      where: { folderId },
      orderBy: { createdAt: 'desc' }
    });
    
    res.status(200).json(words);
  } catch (error) {
    console.error('Error fetching words:', error);
    res.status(500).json({ error: 'Failed to fetch words' });
  }
});

// Add a new word to a folder
app.post('/api/folders/:folderId/words', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const folderIdParam = req.params.folderId;
    const { text, meaning } = req.body;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    
    // Validate folderId
    if (!folderIdParam) {
      return res.status(400).json({ error: 'Folder ID is required' });
    }
    
    const folderId = parseInt(folderIdParam);
    
    if (isNaN(folderId)) {
      return res.status(400).json({ error: 'Invalid folder ID' });
    }
    
    // Validate word data
    if (!text || text.trim() === '') {
      return res.status(400).json({ error: 'Word text is required' });
    }
    
    if (!meaning || meaning.trim() === '') {
      return res.status(400).json({ error: 'Word meaning is required' });
    }
    
    // Check if folder exists and belongs to the user
    const folder = await prisma.folder.findUnique({
      where: { id: folderId }
    });
    
    if (!folder) {
      return res.status(404).json({ error: 'Folder not found' });
    }
    
    // Check ownership
    if (folder.userId !== userId) {
      return res.status(403).json({ error: 'You do not have permission to add words to this folder' });
    }
    
    // Create new word
    const newWord = await prisma.word.create({
      data: {
        text: text.trim(),
        meaning: meaning.trim(),
        folderId
      }
    });
    
    res.status(201).json(newWord);
  } catch (error) {
    console.error('Error creating word:', error);
    res.status(500).json({ error: 'Failed to create word' });
  }
});

// Delete a word
app.delete('/api/words/:wordId', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const wordIdParam = req.params.wordId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    
    // Validate wordId
    if (!wordIdParam) {
      return res.status(400).json({ error: 'Word ID is required' });
    }
    
    const wordId = parseInt(wordIdParam);
    
    if (isNaN(wordId)) {
      return res.status(400).json({ error: 'Invalid word ID' });
    }
    
    // Check if word exists and get its folder information
    const word = await prisma.word.findUnique({
      where: { id: wordId },
      include: { folder: true }
    });
    
    if (!word) {
      return res.status(404).json({ error: 'Word not found' });
    }
    
    // Check ownership (word belongs to a folder that belongs to the user)
    if (word.folder.userId !== userId) {
      return res.status(403).json({ error: 'You do not have permission to delete this word' });
    }
    
    // Delete the word
    await prisma.word.delete({
      where: { id: wordId }
    });
    
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting word:', error);
    res.status(500).json({ error: 'Failed to delete word' });
  }
});

// ==================== VOICE LAB ROUTES ====================

// Get all lessons
app.get('/api/lessons', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    // Fetch all lessons
    const lessons = await prisma.lesson.findMany({
      orderBy: { createdAt: 'desc' }
    });
    
    res.status(200).json(lessons);
  } catch (error) {
    console.error('Error fetching lessons:', error);
    res.status(500).json({ error: 'Failed to fetch lessons' });
  }
});

// Get all phrases in a specific lesson
app.get('/api/lessons/:lessonId/phrases', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const lessonIdParam = req.params.lessonId;
    
    // Validate lessonId
    if (!lessonIdParam) {
      return res.status(400).json({ error: 'Lesson ID is required' });
    }
    
    const lessonId = parseInt(lessonIdParam);
    
    if (isNaN(lessonId)) {
      return res.status(400).json({ error: 'Invalid lesson ID' });
    }
    
    // Check if lesson exists
    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId }
    });
    
    if (!lesson) {
      return res.status(404).json({ error: 'Lesson not found' });
    }
    
    // Fetch all phrases in the lesson
    const phrases = await prisma.phrase.findMany({
      where: { lessonId },
      orderBy: { createdAt: 'asc' }
    });
    
    res.status(200).json(phrases);
  } catch (error) {
    console.error('Error fetching phrases:', error);
    res.status(500).json({ error: 'Failed to fetch phrases' });
  }
});

// ==================== USER AUTHENTICATION ROUTES ====================

// User login endpoint
app.post('/api/login', async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    
    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    
    // Find user by email
    const user = await prisma.user.findUnique({
      where: { email }
    });
    
    // If user not found or password doesn't match, return generic error
    // This is a security best practice to not reveal whether the email exists
    if (!user) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }
    
    // Compare provided password with stored hashed password
    const passwordMatch = await bcrypt.compare(password, user.password);
    
    if (!passwordMatch) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }
    
    // Password matches, login successful
    // Generate JWT token
    const jwtSecret = process.env.JWT_SECRET;
    
    if (!jwtSecret) {
      console.error('JWT_SECRET is not defined in environment variables');
      return res.status(500).json({ error: 'Server configuration error' });
    }
    
    // Create JWT payload with user ID
    const payload = {
      userId: user.id
    };
    
    // Sign the token with expiration time (24 hours)
    const token = jwt.sign(payload, jwtSecret, { expiresIn: '24h' });
    
    // Return the token along with user info (excluding password)
    res.status(200).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        createdAt: user.createdAt
      }
    });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Failed to process login' });
  }
});

// Start server only if not in test environment
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

// Handle shutdown gracefully
process.on('SIGINT', async () => {
  await prisma.$disconnect();
  process.exit(0);
});

// Export app for testing
export default app;
export { prisma };
