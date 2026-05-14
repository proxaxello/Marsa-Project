# Marsa Development Tasks

## Overview
This document breaks down the Marsa MVP development into actionable tasks organized by phases, modules, and priority levels.

**Priority Levels:**
- 🔴 P0: Critical for MVP launch
- 🟡 P1: Important for MVP, can be simplified
- 🟢 P2: Nice-to-have, can be deferred post-MVP

---

## Phase 1: Project Setup & Infrastructure (Week 1-2)

### 1.1 Development Environment Setup 🔴 P0

**Flutter Mobile App**
- [v] Install Flutter SDK and set up development environment
- [ ] Create new Flutter project with proper naming convention
- [ ] Set up project structure using BLoC architecture pattern
  - [ ] Create `/data`, `/presentation`, `/logic` folders
  - [ ] Set up `/data/models`, `/data/repositories`, `/data/providers`
  - [ ] Set up `/presentation/screens`, `/presentation/widgets`
  - [ ] Set up `/logic/blocs`
- [ ] Configure `pubspec.yaml` with essential dependencies:
  - [ ] `flutter_bloc` (state management)
  - [ ] `http` or `dio` (API calls)
  - [ ] `shared_preferences` (local storage)
  - [ ] `sqflite` (local database for dictionary)
  - [ ] `path_provider` (file system access)
  - [ ] `audioplayers` (audio playback)
  - [ ] `permission_handler` (microphone permissions)
  - [ ] `record` (audio recording)
- [ ] Set up iOS and Android project configurations
- [ ] Configure app icons and splash screens

**Next.js Web App**
- [ ] Install Node.js and create Next.js project with TypeScript
- [ ] Configure Tailwind CSS
- [ ] Set up project structure:
  - [ ] `/pages` (routes)
  - [ ] `/components` (reusable UI)
  - [ ] `/lib` (utilities and API clients)
  - [ ] `/public` (static assets)
- [ ] Configure `next.config.js` for SEO optimization
- [ ] Set up environment variables (.env.local)

**Backend (Node.js)**
- [ ] Initialize Node.js project with TypeScript
- [ ] Set up Express.js server
- [ ] Configure project structure:
  - [ ] `/routes` (API endpoints)
  - [ ] `/controllers` (business logic)
  - [ ] `/models` (database models)
  - [ ] `/middleware` (auth, validation, error handling)
  - [ ] `/services` (external API integrations)
- [ ] Set up Prisma ORM
  - [ ] Initialize Prisma
  - [ ] Design database schema
  - [ ] Configure PostgreSQL connection
- [ ] Configure environment variables
- [ ] Set up error logging (Winston or similar)

**Backend (Python - AI Services)**
- [ ] Set up Python virtual environment
- [ ] Create Flask/FastAPI project for AI microservice
- [ ] Install essential ML libraries (scikit-learn, numpy, pandas)
- [ ] Set up project structure:
  - [ ] `/models` (ML models)
  - [ ] `/services` (AI processing logic)
  - [ ] `/api` (endpoints)
- [ ] Configure environment variables

### 1.2 Version Control & CI/CD 🔴 P0
- [ ] Initialize Git repository
- [ ] Create `.gitignore` files for all projects
- [ ] Set up GitHub repository with proper branching strategy
  - [ ] `main` (production)
  - [ ] `develop` (development)
  - [ ] `feature/*` (feature branches)
- [ ] Set up basic GitHub Actions for:
  - [ ] Flutter: Build checks and tests
  - [ ] Next.js: Build and type checking
  - [ ] Backend: Linting and tests

### 1.3 Database Design 🔴 P0
- [ ] Design Prisma schema for:
  - [ ] Users table (id, email, password_hash, created_at, subscription_type)
  - [ ] VocabularyFolders table (id, user_id, name, created_at)
  - [ ] VocabularyCards table (id, folder_id, word, definition, ipa, examples, audio_url)
  - [ ] CardReviews table (id, card_id, user_id, quality, next_review_date, ease_factor, interval)
  - [ ] UserProgress table (id, user_id, total_words_learned, streak_days, xp_points)
  - [ ] PronunciationAttempts table (id, user_id, word, audio_file_path, score, feedback, created_at)
- [ ] Run Prisma migrations
- [ ] Seed database with test data

---

## Phase 2: Authentication & User Management (Week 3)

### 2.1 Backend Authentication API 🔴 P0
- [ ] Implement user registration endpoint (`POST /api/auth/register`)
  - [ ] Validate email and password
  - [ ] Hash password using bcrypt
  - [ ] Create user in database
  - [ ] Generate JWT token
- [ ] Implement login endpoint (`POST /api/auth/login`)
  - [ ] Verify credentials
  - [ ] Generate JWT token
  - [ ] Return user profile data
- [ ] Implement JWT verification middleware
- [ ] Implement password reset flow (email-based)
- [ ] Implement token refresh endpoint
- [ ] Add rate limiting to authentication endpoints

### 2.2 Flutter Authentication UI 🔴 P0
- [ ] Create authentication screens:
  - [ ] Login screen with email/password fields
  - [ ] Registration screen
  - [ ] Password reset screen
- [ ] Implement authentication BLoC:
  - [ ] States: Unauthenticated, Loading, Authenticated, Error
  - [ ] Events: LoginRequested, RegisterRequested, LogoutRequested
- [ ] Implement secure token storage using `flutter_secure_storage`
- [ ] Add form validation
- [ ] Add loading indicators and error messages
- [ ] Implement auto-login on app start (if token exists)

### 2.3 User Profile & Settings 🟡 P1
- [ ] Create Settings screen UI
- [ ] Implement profile editing functionality
- [ ] Add notification preferences toggle
- [ ] Add audio settings (speed, auto-play)
- [ ] Add theme toggle (dark/light mode)
- [ ] Implement logout functionality

---

## Phase 3: Tab 1 - Home (Dictionary) (Week 4-5)

### 3.1 Dictionary Data Preparation 🔴 P0
- [ ] Source English-Vietnamese dictionary data
  - [ ] Research open-source dictionaries (StarDict, FreeDict)
  - [ ] Format data into JSON/SQLite structure
- [ ] Import dictionary into SQLite database
- [ ] Create efficient indexes for fast search
- [ ] Bundle SQLite database with Flutter app

### 3.2 Dictionary Search Backend API 🔴 P0
- [ ] Implement search endpoint (`GET /api/dictionary/search?query=`)
  - [ ] Full-text search in word entries
  - [ ] Return word details (IPA, definitions, examples)
  - [ ] Include audio URL if available
- [ ] Implement word details endpoint (`GET /api/dictionary/word/:id`)
- [ ] Add caching for frequently searched words

### 3.3 Home Screen UI (Flutter) 🔴 P0
- [ ] Create Home screen layout with:
  - [ ] Search bar at top with three icons (mic, pencil, camera)
  - [ ] Trending keywords section (horizontal scroll)
  - [ ] Search history section (list)
- [ ] Implement search functionality:
  - [ ] Text input search
  - [ ] Voice search (using speech-to-text)
  - [ ] Handwriting input (using drawing widget)
  - [ ] Camera search (placeholder for MVP)
- [ ] Create word detail view:
  - [ ] Display word, IPA, and audio button
  - [ ] Show Vietnamese meanings
  - [ ] Display examples, synonyms, antonyms
  - [ ] Prominent "⭐ Save" button
- [ ] Implement audio playback for pronunciation
- [ ] Create search BLoC for state management
- [ ] Implement search history persistence

### 3.4 Offline Dictionary Functionality 🔴 P0
- [ ] Implement offline search using local SQLite
- [ ] Add offline/online status indicator
- [ ] Sync search history to backend when online
- [ ] Handle offline audio playback (cache frequently used audio)

### 3.5 Save to Vocabulary Feature 🔴 P0
- [ ] Implement "Save to Vocabulary" API endpoint
  - [ ] `POST /api/vocabulary/save`
  - [ ] Create flashcard from word data
  - [ ] Add to default folder or user-selected folder
- [ ] Add confirmation feedback (toast/snackbar)
- [ ] Update UI to show if word is already saved

---

## Phase 4: Tab 2 - Practice (Vocabulary & Games) (Week 6-8)

### 4.1 Vocabulary Folder Management 🔴 P0

**Backend API**
- [ ] Implement folder CRUD endpoints:
  - [ ] `GET /api/folders` (list all folders)
  - [ ] `POST /api/folders` (create new folder)
  - [ ] `PUT /api/folders/:id` (rename folder)
  - [ ] `DELETE /api/folders/:id` (delete folder)
  - [ ] `GET /api/folders/:id/cards` (get all cards in folder)

**Flutter UI**
- [ ] Create Practice screen with folder list/grid
- [ ] Implement folder creation dialog
- [ ] Implement folder rename/delete actions
- [ ] Add visual indicators (card count, last studied date)
- [ ] Create folder details screen showing all cards

### 4.2 Flashcard System 🔴 P0

**Backend API**
- [ ] Implement card CRUD endpoints:
  - [ ] `GET /api/cards/:folderId` (get cards)
  - [ ] `POST /api/cards` (add card)
  - [ ] `PUT /api/cards/:id` (edit card)
  - [ ] `DELETE /api/cards/:id` (delete card)
- [ ] Implement review submission endpoint:
  - [ ] `POST /api/cards/:id/review`
  - [ ] Accept quality rating (0-5)
  - [ ] Update card review schedule using SM-2

**Flutter UI**
- [ ] Create flashcard widget with flip animation
- [ ] Implement swipe gestures:
  - [ ] Swipe right: "Know" (quality 4-5)
  - [ ] Swipe left: "Don't Know" (quality 0-2)
  - [ ] Tap to flip card
- [ ] Display front (word) and back (meaning + example)
- [ ] Show progress indicator (X of Y cards)
- [ ] Add "Show Answer" button as alternative to tap
- [ ] Implement session completion screen with statistics

### 4.3 Spaced Repetition Algorithm (SM-2) 🔴 P0
- [ ] Implement SM-2 algorithm in backend:
  - [ ] Calculate new ease factor based on quality rating
  - [ ] Calculate new interval (days until next review)
  - [ ] Update next_review_date in database
- [ ] Create scheduled review query:
  - [ ] `GET /api/reviews/due` (cards due for review today)
- [ ] Implement push notification scheduling:
  - [ ] Send daily reminder if cards are due
  - [ ] Include count of cards to review

### 4.4 Learn Mode 🟡 P1
- [ ] Create guided learning flow:
  - [ ] Show word → ask for meaning (multiple choice)
  - [ ] Show meaning → ask for word (typing)
  - [ ] Mix with flashcard reviews
- [ ] Implement Learn mode UI
- [ ] Add immediate feedback for correct/incorrect answers

### 4.5 Test Mode 🟡 P1

**Multiple Choice**
- [ ] Create multiple choice question generator:
  - [ ] Select target card
  - [ ] Generate 3 distractor options
  - [ ] Randomize order
- [ ] Implement multiple choice UI
- [ ] Track correct/incorrect answers

**True/False**
- [ ] Generate true/false questions:
  - [ ] 50% true (correct word-meaning pair)
  - [ ] 50% false (wrong pairing)
- [ ] Implement True/False UI

**Match Game**
- [ ] Create matching game UI:
  - [ ] Grid of cards (6-12 cards)
  - [ ] Half with words, half with meanings
  - [ ] Tap to select, match pairs
- [ ] Add timer display
- [ ] Implement scoring based on time and errors
- [ ] Show completion animation

### 4.6 Progress Tracking 🟡 P1
- [ ] Track user statistics:
  - [ ] Total words learned
  - [ ] Study streak (consecutive days)
  - [ ] XP points earned
  - [ ] Accuracy rate
- [ ] Display progress on Practice tab
- [ ] Implement XP reward system for completing reviews

---

## Phase 5: Tab 3 - Voice Lab (Pronunciation) (Week 9-10)

### 5.1 Speechace API Integration 🔴 P0

**Backend Service**
- [ ] Sign up for Speechace API account
- [ ] Create pronunciation scoring service:
  - [ ] `POST /api/pronunciation/score`
  - [ ] Accept audio file from client
  - [ ] Forward to Speechace API with text
  - [ ] Parse response and return structured feedback
- [ ] Implement audio file upload handling
- [ ] Add error handling for API failures

**Python Microservice (Alternative)**
- [ ] Research open-source pronunciation scoring models
- [ ] Implement basic pronunciation scoring if budget constrained
- [ ] Create endpoint for receiving and processing audio

### 5.2 Voice Lab UI (Flutter) 🔴 P0
- [ ] Create Voice Lab screen with lesson categories:
  - [ ] By sound (phonemes)
  - [ ] By topic
  - [ ] By difficulty
- [ ] Implement lesson detail view:
  - [ ] Display target word/sentence
  - [ ] Show IPA transcription
  - [ ] Play example audio button
  - [ ] Record button
- [ ] Implement audio recording:
  - [ ] Request microphone permission
  - [ ] Visual feedback during recording
  - [ ] Playback recorded audio
  - [ ] Submit for scoring
- [ ] Display scoring results:
  - [ ] Overall score (0-100)
  - [ ] Color-coded text (green/yellow/red phonemes)
  - [ ] Specific feedback on errors
- [ ] Add retry functionality
- [ ] Track pronunciation history

### 5.3 Word-Level Pronunciation in Dictionary 🔴 P0
- [ ] Add microphone icon to word detail view
- [ ] Implement quick pronunciation check from dictionary
- [ ] Add microphone icon to flashcard back
- [ ] Show simplified feedback for quick checks

### 5.4 Pronunciation Lessons Content 🟡 P1
- [ ] Create lesson content database:
  - [ ] Common phoneme pairs (/ɪ/ vs /iː/, /θ/ vs /s/)
  - [ ] Minimal pairs (ship/sheep, tree/three)
  - [ ] Common problematic sounds for Vietnamese learners
- [ ] Organize lessons by difficulty
- [ ] Add progression tracking

---

## Phase 6: Tab 4 - AI Tutor (Week 11)

### 6.1 AI Tutor Backend 🟡 P1
- [ ] Sign up for OpenAI/Gemini API
- [ ] Create chat endpoint:
  - [ ] `POST /api/chat/message`
  - [ ] Maintain conversation context
  - [ ] Stream responses for better UX
- [ ] Implement system prompts:
  - [ ] Define AI tutor personality
  - [ ] Set conversation guidelines
  - [ ] Include user's learning data in context
- [ ] Add conversation history storage
- [ ] Implement rate limiting (especially for free tier)

### 6.2 AI Tutor UI (Flutter) 🟡 P1
- [ ] Create chat interface:
  - [ ] Message list view
  - [ ] Text input field
  - [ ] Send button
  - [ ] Voice input button
- [ ] Implement chat BLoC for state management
- [ ] Add typing indicator
- [ ] Display user and AI messages with distinct styling
- [ ] Implement suggested prompts/questions
- [ ] Add conversation starters:
  - [ ] "Practice ordering food"
  - [ ] "Explain past perfect tense"
  - [ ] "What should I study today?"

### 6.3 Progress Analysis Integration 🟢 P2 (Post-MVP)
- [ ] Query user's weakness data
- [ ] Generate personalized suggestions
- [ ] Proactively offer help based on recent mistakes
- [ ] Track improvement over time

---

## Phase 7: Cross-Platform Features (Week 12)

### 7.1 Push Notifications 🔴 P0
- [ ] Set up Firebase Cloud Messaging (FCM)
- [ ] Implement notification service in backend
- [ ] Create notification scheduling:
  - [ ] Daily study reminder
  - [ ] Cards due for review
  - [ ] Streak reminders
- [ ] Implement notification handlers in Flutter
- [ ] Add notification settings in app

### 7.2 Data Synchronization 🔴 P0
- [ ] Implement sync service:
  - [ ] Upload local changes when online
  - [ ] Download updates from server
  - [ ] Resolve conflicts (last-write-wins for MVP)
- [ ] Add sync status indicator
- [ ] Handle sync errors gracefully

### 7.3 Gamification Elements 🟡 P1
- [ ] Implement XP system:
  - [ ] Award XP for completing reviews
  - [ ] Award XP for study streaks
  - [ ] Award XP for pronunciation practice
- [ ] Create daily streak tracker
- [ ] Display user level based on XP
- [ ] Add achievement badges (basic set)
- [ ] Implement leaderboard (optional for MVP)

---

## Phase 8: Next.js Web Application (Week 13-14)

### 8.1 Web Dictionary (SEO Focus) 🔴 P0
- [ ] Create static pages for common words:
  - [ ] Use `getStaticPaths` and `getStaticProps`
  - [ ] Generate pages for top 5000 words
- [ ] Implement dynamic word pages:
  - [ ] URL structure: `/dict/en-vi/[word]`
  - [ ] Server-side rendering for SEO
- [ ] Optimize page metadata:
  - [ ] Title: "Word - English to Vietnamese Dictionary | Marsa"
  - [ ] Meta description with definition
  - [ ] Open Graph tags for social sharing
- [ ] Add breadcrumb navigation
- [ ] Implement internal linking between related words

### 8.2 Web Search Interface 🟡 P1
- [ ] Create homepage with search bar
- [ ] Implement client-side search
- [ ] Display search results
- [ ] Link to word detail pages

### 8.3 Blog for Content Marketing 🟡 P1
- [ ] Set up blog structure (`/blog/[slug]`)
- [ ] Create blog post template
- [ ] Implement markdown rendering
- [ ] Add SEO optimization for blog posts
- [ ] Create initial content:
  - [ ] "5 Effective Vocabulary Learning Techniques"
  - [ ] "How to Improve English Pronunciation"
  - [ ] "Common Grammar Mistakes Vietnamese Learners Make"

### 8.4 Landing Page 🟡 P1
- [ ] Create marketing landing page:
  - [ ] Hero section with value proposition
  - [ ] Feature showcase (dictionary, flashcards, AI pronunciation)
  - [ ] Pricing section
  - [ ] Download CTAs (App Store, Google Play)
- [ ] Add testimonials section (prepare for post-launch)
- [ ] Implement email signup for waitlist/newsletter

---

## Phase 9: Payment & Subscription (Week 15)

### 9.1 Payment Integration 🔴 P0
- [ ] Choose payment provider (Stripe for international, VNPay for Vietnam)
- [ ] Implement subscription plans in database
- [ ] Create checkout flow:
  - [ ] Display plan options
  - [ ] Redirect to payment gateway
  - [ ] Handle payment callbacks
- [ ] Implement subscription management:
  - [ ] Check subscription status
  - [ ] Handle subscription renewal
  - [ ] Handle subscription cancellation
- [ ] Add middleware to restrict Pro features

### 9.2 Subscription UI (Flutter) 🔴 P0
- [ ] Create subscription screen:
  - [ ] Display Free vs Pro features
  - [ ] Show pricing options (3 months, 6 months, annual)
  - [ ] Highlight savings for annual plan
- [ ] Implement subscription status in user profile
- [ ] Add "Upgrade to Pro" CTAs in appropriate places:
  - [ ] After 10 pronunciation checks (free limit)
  - [ ] When trying to create 4th vocabulary folder
  - [ ] Banner in Settings

### 9.3 Free Tier Limitations 🔴 P0
- [ ] Implement usage tracking:
  - [ ] Count daily pronunciation checks
  - [ ] Count vocabulary folders
  - [ ] Count cards per folder
- [ ] Add limitation enforcement
- [ ] Display usage meters ("3/10 pronunciation checks used today")
- [ ] Show ads in free version (AdMob integration)

---

## Phase 10: Testing & Quality Assurance (Week 16-17)

### 10.1 Unit Testing 🔴 P0
- [ ] Write unit tests for critical backend functions:
  - [ ] Authentication logic
  - [ ] SM-2 algorithm
  - [ ] Payment processing
- [ ] Write unit tests for Flutter BLoCs
- [ ] Aim for 70%+ code coverage on business logic

### 10.2 Integration Testing 🔴 P0
- [ ] Test API endpoints with Postman/Insomnia
- [ ] Write integration tests for critical user flows:
  - [ ] Registration → Login → Search word → Save to folder → Review flashcard
  - [ ] Free user → Upgrade to Pro → Access Pro features
- [ ] Test offline functionality

### 10.3 UI/UX Testing 🔴 P0
- [ ] Conduct internal testing on multiple devices:
  - [ ] iOS (various iPhone models)
  - [ ] Android (various screen sizes)
- [ ] Test accessibility features
- [ ] Check for UI consistency
- [ ] Verify loading states and error messages

### 10.4 Beta Testing 🟡 P1
- [ ] Set up beta testing program (TestFlight, Google Play Beta)
- [ ] Recruit 20-50 beta testers from target audience
- [ ] Create feedback collection form
- [ ] Analyze feedback and prioritize fixes
- [ ] Iterate based on beta feedback

### 10.5 Performance Optimization 🟡 P1
- [ ] Profile app performance:
  - [ ] Measure startup time
  - [ ] Check memory usage
  - [ ] Monitor network requests
- [ ] Optimize database queries
- [ ] Implement image caching
- [ ] Lazy load content where appropriate
- [ ] Minimize app size

---

## Phase 11: Pre-Launch Preparation (Week 18)

### 11.1 App Store Preparation 🔴 P0

**App Store (iOS)**
- [ ] Create Apple Developer account
- [ ] Prepare app metadata:
  - [ ] App name: "Marsa: Từ điển Anh Việt & Luyện Nói AI"
  - [ ] Subtitle highlighting key features
  - [ ] Description (4000 characters)
  - [ ] Keywords (separate by commas)
  - [ ] Screenshots (6.5", 5.5" sizes)
  - [ ] App preview video (optional but recommended)
- [ ] Set up in-app purchases
- [ ] Submit for review

**Google Play (Android)**
- [ ] Create Google Play Console account
- [ ] Prepare app metadata:
  - [ ] Title (30 characters)
  - [ ] Short description (80 characters)
  - [ ] Full description (4000 characters)
  - [ ] Screenshots (phone, 7" tablet, 10" tablet)
  - [ ] Feature graphic
  - [ ] App icon (512x512)
- [ ] Set up in-app billing
- [ ] Submit for review

### 11.2 Analytics & Monitoring 🔴 P0
- [ ] Set up Firebase Analytics
- [ ] Implement event tracking:
  - [ ] User registration
  - [ ] Word searches
  - [ ] Flashcard reviews completed
  - [ ] Pronunciation attempts
  - [ ] Subscription purchases
- [ ] Set up error tracking (Sentry or Firebase Crashlytics)
- [ ] Create analytics dashboard for monitoring KPIs

### 11.3 Marketing Preparation 🔴 P0
- [ ] Create social media accounts:
  - [ ] Facebook Page
  - [ ] TikTok
  - [ ] Instagram
  - [ ] YouTube channel
- [ ] Prepare launch content:
  - [ ] App demo video
  - [ ] Feature highlight posts
  - [ ] Before/after testimonial templates
- [ ] Create press kit:
  - [ ] App description
  - [ ] Screenshots
  - [ ] Logo assets
  - [ ] Founder bio
- [ ] Reach out to influencers for launch partnerships

### 11.4 Documentation 🟡 P1
- [ ] Create user help center:
  - [ ] Getting started guide
  - [ ] Feature tutorials
  - [ ] FAQ
  - [ ] Troubleshooting
- [ ] Write privacy policy
- [ ] Write terms of service
- [ ] Create support email/ticketing system

---

## Phase 12: Launch & Post-Launch (Week 19-20)

### 12.1 Soft Launch 🔴 P0
- [ ] Release to limited audience (Vietnam only)
- [ ] Monitor closely for critical bugs
- [ ] Collect initial user feedback
- [ ] Quick iteration on urgent issues

### 12.2 Marketing Launch 🔴 P0
- [ ] Execute launch marketing plan:
  - [ ] Social media announcement posts
  - [ ] Influencer collaborations go live
  - [ ] PR outreach to tech blogs
  - [ ] Launch ads (Facebook, TikTok)
- [ ] Create launch promotion:
  - [ ] 50% off first month of Pro
  - [ ] Referral bonus for early users
- [ ] Monitor app store rankings
- [ ] Respond to reviews

### 12.3 Post-Launch Monitoring 🔴 P0
- [ ] Daily monitoring of:
  - [ ] Crash reports
  - [ ] User reviews
  - [ ] Analytics metrics (DAU, retention, conversion)
  - [ ] Server performance
- [ ] Set up on-call rotation for critical issues
- [ ] Weekly team review of metrics and feedback

### 12.4 Iteration & Optimization 🔴 P0
- [ ] Create prioritized backlog from user feedback
- [ ] Fix critical bugs immediately
- [ ] Plan first post-launch update (2-4 weeks)
- [ ] A/B test key features:
  - [ ] Onboarding flow
  - [ ] Free-to-Pro conversion prompts
  - [ ] Subscription pricing

---

## Post-MVP Roadmap (Month 3+)

### Advanced Features 🟢 P2
- [ ] Sentence-level pronunciation practice
- [ ] Conversation simulation with AI
- [ ] Advanced grammar lessons
- [ ] Weakness analysis model (Engine 2)
- [ ] Community features (friend challenges, shared decks)
- [ ] Offline AI pronunciation (on-device model)
- [ ] Additional language pairs (Vietnamese-English)
- [ ] Integration with IELTS/TOEIC prep content

### Scale & Optimization
- [ ] Implement CDN for audio files
- [ ] Database sharding for scalability
- [ ] Microservices architecture refinement
- [ ] Advanced caching strategies
- [ ] Machine learning model improvements
- [ ] Internationalization (i18n) for expansion

---

## Resource Allocation Recommendations

### Team Composition for MVP
- **1 Full-stack Developer** (You + AI Code Tools): All phases
- **1 UI/UX Designer** (Freelance): Weeks 1-10 (design systems, mockups)
- **1 Content Creator** (Freelance): Weeks 8-18 (lesson content, blog posts)
- **1 QA Tester** (Part-time): Weeks 16-18 (testing phase)
- **1 Marketing Manager** (You): Weeks 15-20 (pre-launch and launch)

### Budget Priorities
1. **Speechace API**: $200-500/month (critical for competitive advantage)
2. **OpenAI/Gemini API**: $100-300/month (AI Tutor, adjust based on usage)
3. **Cloud hosting**: $100-200/month (AWS/GCP/Railway)
4. **App Store fees**: $100/year (Apple) + $25 one-time (Google)
5. **Domain & basic infrastructure**: $50/month

### Time Estimate
- **MVP Development**: 18-20 weeks (4.5-5 months)
- **With AI Code Tools acceleration**: Potentially 12-16 weeks (3-4 months)

---

## Success Metrics to Track

### Week 1-4 Post-Launch
- [ ] 1,000+ downloads
- [ ] 500+ registered users
- [ ] 30% D1 retention
- [ ] 15% D7 retention
- [ ] 5+ app store reviews (target 4.5+ stars)

### Month 2-3 Post-Launch
- [ ] 10,000+ downloads
- [ ] 5,000+ monthly active users
- [ ] 50+ Pro subscribers (1% conversion)
- [ ] 20% D30 retention
- [ ] Clear product-market fit signals

---

## Risk Mitigation Checklist

**Technical Risks**
- [ ] Have backup for Speechace (open-source alternative researched)
- [ ] Database backup strategy implemented
- [ ] Error monitoring with alerts configured
- [ ] Rate limiting on all APIs

**Business Risks**
- [ ] Freemium balance tested (not too generous, not too restrictive)
- [ ] Multiple marketing channels (don't rely on one)
- [ ] User feedback loop established early

**Operational Risks**
- [ ] Documentation for all critical systems
- [ ] Automated deployment pipeline
- [ ] Rollback strategy for bad updates

---

*Document Version: 1.0*  
*Last Updated: October 2025*  
*Owner: Development Team*
