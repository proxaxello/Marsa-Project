# Product Requirements Document (PRD) - Marsa AI English Learning Super-App

## 1. Vision & Mission

### Vision
To become the indispensable, all-in-one English learning companion for Vietnamese learners, eventually expanding to a global audience.

### Mission
To eliminate the friction of using multiple separate apps by integrating a powerful offline dictionary, a gamified vocabulary trainer with spaced repetition, and advanced AI-powered pronunciation and conversation practice into a single, seamless platform. We solve the user's core pain point: fragmented learning.

---

## 2. Market Opportunity

### 2.1 Market Size & Growth
- Vietnamese EdTech market valued at ~$5 billion USD
- 2024 revenue: ~$360 million USD
- Projected CAGR: 11-13% (2025-2026)
- Mobile learning apps segment: $15 million USD
- Expected users by 2029: 11.8 million

### 2.2 Market Gap
Vietnamese English learners currently use multiple fragmented apps:
- **TFlat**: Offline dictionary lookups
- **Quizlet/Memrise**: Vocabulary flashcards with spaced repetition
- **Duolingo**: Grammar and general practice with gamification
- **ELSA Speak**: AI-powered pronunciation practice

This fragmentation creates:
- Cognitive overload and time waste
- Inconsistent learning experience
- Multiple subscription costs
- Lack of comprehensive progress tracking
- Disconnected skill development

---

## 3. Target Audience

### Primary Segment
**Students and workers in Vietnam (ages 13-48)**

#### Needs
- Meet university English exit requirements
- Improve professional communication for career advancement
- Prepare for standardized tests (TOEIC, IELTS)

#### Characteristics
- Tech-savvy, active on social media
- Price-sensitive but willing to pay for effective tools with clear results
- 100% of students surveyed have used AI tools for English learning

---

## 4. Unique Selling Proposition (USP)

**Marsa is the only All-in-One Intelligent English Learning Platform that combines:**
1. Comprehensive Offline Dictionary
2. Spaced Repetition System (SRS) for vocabulary
3. AI-powered personalized learning paths
4. AI pronunciation scoring (ELSA-equivalent quality)

**Key Competitive Advantages:**
1. **Data Network Effect**: Comprehensive learning data across all skills enables superior AI personalization
2. **Seamless Experience**: Eliminates app-switching friction, creating higher user engagement and retention

---

## 5. App Architecture

### 5.1 Bottom Navigation (5 Tabs)

#### Tab 1: Home (Trang chủ)
**Objective**: Primary entry point for vocabulary discovery and search

**Key Components:**
- **Search Bar** (top placement)
  - Placeholder: "Nhập từ, cụm từ, hoặc câu..."
  - Three icon buttons:
    - Microphone: Voice input search
    - Pencil: Handwriting input
    - Camera: Image-based search (future feature)

- **Search Results Display**
  - Word with IPA phonetic transcription
  - Audio pronunciation button (speaker icon)
  - Primary Vietnamese meaning
  - Detailed definitions, examples, synonyms, antonyms, collocations
  - Prominent "⭐ Save" button → adds to Practice tab vocabulary folder

- **Content Sections**
  - "Từ khóa hot" (Trending Keywords): Horizontal scroll of trending vocabulary
  - "Lịch sử" (History): Recently searched words

#### Tab 2: Practice (Luyện tập)
**Objective**: Central hub for vocabulary memorization through gamified, spaced-repetition-based practice

**Key Components:**
- **Folder Management**
  - Unlimited vocabulary folders (e.g., "IELTS Speaking Part 1", "Business English")
  - Display as list or grid

- **Practice Modes** (within each folder):
  1. **Flashcards**
     - Simple card interface
     - Tap to flip (word ↔ meaning/example)
     - Swipe left: "Don't Know"
     - Swipe right: "Know"
     - User feedback feeds SRS algorithm
  
  2. **Learn**
     - Guided learning mode combining flashcards and simple quizzes
  
  3. **Test**
     - Multiple Choice: Choose correct meaning
     - True/False: Match word with meaning
     - Match: Grid of cards with words and meanings, tap matching pairs with timer
  
- **Scoring & Spaced Repetition System (SM-2)**
  - Track performance (score, time, accuracy)
  - SM-2 algorithm calculates optimal review timing
  - Personalized review schedule for long-term retention
  - Push notifications for scheduled reviews

#### Tab 3: Voice Lab (Luyện Voice)
**Objective**: Dedicated space for AI-powered pronunciation improvement (ELSA Speak equivalent)

**Key Components:**
- **Word & Sentence Practice**
  - Lessons organized by:
    - Sound (e.g., /ɪ/ vs /iː/)
    - Topic
    - Difficulty level
  - Display text with "Record" button

- **AI Pronunciation Analysis** (via Speechace API)
  - Overall score (e.g., 85/100)
  - Color-coded phoneme feedback:
    - Green: Correct
    - Yellow: Partially correct
    - Red: Incorrect
  - Advanced feedback: fluency, intonation, rhythm

#### Tab 4: AI Tutor (Gia sư AI)
**Objective**: Conversational AI for practice, explanations, and progress tracking (GPT/Gemini API)

**Key Components:**
- **Chat Interface**
  - Type or speak to AI

- **Core Functions**
  1. **Conversational Practice**: Role-play scenarios (e.g., "ordering food at a restaurant")
  2. **Grammar & Vocabulary Explanations**: Answer questions like "difference between 'affect' and 'effect'"
  3. **Progress Tracking & Personalized Suggestions**: 
     - Analyze data from all tabs (saved words, game scores, pronunciation mistakes)
     - Provide personalized advice (e.g., "You often mispronounce the /θ/ sound. Let's practice in Voice Lab.")

#### Tab 5: Settings (Cài đặt)
**Objective**: Comprehensive user control over account and app experience

**Key Components:**
- Account Management: Profile, password, subscription status
- Notification Settings: Practice reminders, SRS alerts frequency
- Audio Settings: Voice speed, auto-play pronunciation
- General Settings: Dark/Light mode, data sync, help & support, privacy policy, terms of service

---

## 6. Technical Architecture

### 6.1 Tech Stack

**Mobile (Cross-Platform):**
- **Flutter** (Dart language)
  - Single codebase for iOS & Android
  - Near-native performance
  - Consistent UI across devices
  - Rich widget library for gamification
  - Strongly-typed language (AI code tool friendly)

**Web Application:**
- **Next.js** (React framework)
  - Server-Side Rendering (SSR) for SEO
  - Static Site Generation (SSG) for dictionary pages
  - File-system routing for AI code generation
  - TypeScript + Tailwind CSS

**Backend:**
- **Hybrid Architecture**
  - **Node.js** (Express): High-performance APIs, real-time operations
  - **Python**: AI/ML services (TensorFlow, PyTorch, scikit-learn)
  - Microservice communication via internal APIs

### 6.2 AI Components

**Speech-to-Text & Pronunciation Scoring:**
- **Speechace API** (specialized for language learning)
  - Phoneme-level accuracy scoring
  - Overall pronunciation score
  - Words per minute analysis
  - Pause detection
  - IELTS/PTE score estimation

**Spaced Repetition:**
- **Engine 1 (MVP)**: SM-2 Algorithm
  - Rule-based, proven effective
  - User self-assessment (0-5 scale)
  - Calculates optimal review intervals
  - Push notification scheduling

- **Engine 2 (Post-MVP)**: Weakness Analysis Model
  - Collect structured error data from tests
  - Train classification model (Random Forest or Logistic Regression)
  - Identify user weakness areas
  - Auto-suggest targeted lessons and vocabulary sets

**Conversational AI:**
- **GPT/Gemini API** for AI Tutor functionality

---

## 7. MVP Feature Set

### 7.1 Core Features (Must-Have for MVP)

1. **Offline English-Vietnamese Dictionary + Vocabulary Notebook**
   - Full dictionary functionality
   - One-tap "Save to Notebook" button
   - Automatic flashcard creation from saved words
   - Seamless "discovery → memorization" flow

2. **Flashcard System with SM-2 Spaced Repetition**
   - Daily smart push notifications ("Time to review 5 words")
   - Simple, engaging review interface
   - Progress tracking and habit formation

3. **AI Pronunciation Scoring (Word-Level)**
   - Microphone icon on dictionary entries and flashcard backs
   - Instant feedback via Speechace API
   - Score display (e.g., 85/100)
   - Phoneme-level highlighting of errors
   - Teaser for Pro features

### 7.2 Features Deferred to Post-MVP
- Sentence-level pronunciation practice
- Conversation simulation
- Advanced grammar lessons
- Full AI Tutor capabilities
- Community features
- Comprehensive weakness analysis (Engine 2)

---

## 8. Business Model & Pricing

### 8.1 Target Customer Segment (Priority)
**University students and young professionals (18-28 years old)**
- High, urgent need for English proficiency
- Tech-savvy, willing to try new apps
- Price-sensitive but will pay for proven results
- Active on social media (viral marketing potential)

### 8.2 Freemium Model

**Marsa Free:**
- Full offline dictionary (unlimited lookups)
- Limited vocabulary notebooks (3 sets, max 50 words each)
- Limited AI pronunciation scoring (10 checks/day)
- Ads enabled
- **Goal**: Compete with TFlat and Quizlet free versions

**Marsa Pro (Subscription):**
- **Price**: 1,299,000 VNĐ/year
  - 3-month and 6-month options at higher relative prices
- **Features**:
  - All Free features
  - Ad-free experience
  - Unlimited vocabulary notebooks
  - Unlimited AI pronunciation scoring (word, sentence, conversation levels)
  - AI-personalized grammar and vocabulary learning paths
  - Full access to all lessons and practice games

---

## 9. Go-To-Market Strategy

### 9.1 Phase 1: Pre-launch & Launch

**SEO Optimization (Dictionary):**
- Next.js web version for optimal indexing
- Static URLs for each word (e.g., marsa.app/dict/en-vi/hello)
- On-page SEO: title tags, meta descriptions, H1 headers
- High-quality blog content ("effective vocabulary learning", "pronunciation tips", "common grammar mistakes")

**App Store Optimization (ASO):**
- App title: "Marsa: Từ điển Anh Việt & Luyện Nói AI"
- Keyword research targeting TFlat, Duolingo, ELSA users
- Optimize for Vietnamese (with and without diacritics)
- High-quality icon, screenshots, preview video
- Visual storytelling: "Search → Save → Learn → Practice" flow

### 9.2 Phase 2: Growth & Community Building

**Influencer Marketing (EdTech Focus):**
- **YouTube**: Partner with app reviewers and English teachers (Langmaster, I'm Mary, Rachel's English)
- **TikTok**: Collaborate with Edutainers (Khánh Vy, Davo's Lingo, Bino chém Tiếng Anh)
- **Content**: "30-day pronunciation challenge", before/after comparisons, IELTS prep guides

**Community Building:**
- Official Facebook group: "Cùng học tiếng Anh hiệu quả với Marsa"
- Weekly learning challenges
- Livestream Q&A sessions with teachers
- Exclusive learning tips
- User feedback collection

**Viral Gamification Marketing:**
- Share weekly scores to Facebook
- Challenge friends to complete lessons
- Referral rewards: "Invite a friend, both get 7 days Pro free"
- Weekly leaderboard (XP-based competition)

---

## 10. Success Metrics (KPIs)

### User Acquisition
- Daily/Monthly Active Users (DAU/MAU)
- App downloads (iOS + Android)
- Organic vs. paid acquisition ratio

### Engagement
- Daily average session length
- Words searched per user per day
- Flashcard reviews completed per user per day
- Voice Lab practice frequency
- 7-day and 30-day retention rates

### Monetization
- Free-to-Pro conversion rate
- Average Revenue Per User (ARPU)
- Churn rate
- Lifetime Value (LTV)

### Product Quality
- AI pronunciation accuracy (user satisfaction score)
- Bug report frequency
- App store rating (target: 4.5+)
- Net Promoter Score (NPS)

---

## 11. Development Roadmap

### Phase 1: MVP Development (Months 1-3)
- Flutter app setup with 5-tab navigation
- Offline dictionary integration
- Basic flashcard system with SM-2
- Speechace API integration (word-level)
- User authentication and profile
- Basic analytics integration

### Phase 2: Launch & Iteration (Months 4-6)
- Next.js web version for SEO
- ASO optimization and launch
- Initial marketing campaigns
- User feedback collection
- Bug fixes and UX improvements

### Phase 3: Feature Enhancement (Months 7-9)
- Sentence-level pronunciation
- AI Tutor basic functionality
- Weakness analysis model (Engine 2)
- Community features
- Gamification enhancements

### Phase 4: Scale & Expand (Months 10-12)
- Advanced AI personalization
- Conversation simulation
- Additional language pairs (expansion)
- Partnership opportunities
- Series A preparation

---

## 12. Critical Success Factors

### 1. Flawless USP Execution
The "All-in-One" experience must be genuinely seamless. The workflow from dictionary lookup → save to flashcard → SRS review → pronunciation practice must have zero friction. Any disconnection weakens the core value proposition.

### 2. AI Quality Focus
Pronunciation scoring must match or exceed ELSA Speak quality. This is the premium feature that justifies Pro subscriptions. Investment in a high-quality API from MVP launch is non-negotiable.

### 3. Dual User Acquisition Engine
- **Long-term organic**: SEO and ASO for free utility users (dictionary, flashcards)
- **Active brand-building**: Influencer marketing and community for premium AI features
- Strong free version as acquisition funnel, superior AI experience as conversion driver

---

## 13. Risk Mitigation

### Technical Risks
- **API dependency**: Speechace downtime or price increases
  - Mitigation: Contractual SLA agreements, budget buffer, evaluate alternative providers
  
- **Cross-platform consistency**: Flutter performance issues
  - Mitigation: Extensive testing, gradual rollout, native fallbacks for critical features

### Market Risks
- **Competitor response**: TFlat, Duolingo, or ELSA adding missing features
  - Mitigation: Move fast, build data moat, focus on integration superiority
  
- **User adoption**: Users reluctant to switch from familiar multi-app workflow
  - Mitigation: Freemium model lowers switching cost, viral features encourage trial

### Business Risks
- **Low conversion rate**: Users stay on free tier
  - Mitigation: Carefully balance free/pro features, demonstrate clear value of AI features
  
- **High customer acquisition cost**: Paid marketing too expensive
  - Mitigation: Prioritize organic growth channels (SEO, ASO, community, referrals)

---

## Appendix: Competitive Analysis Matrix

| Feature | TFlat | Quizlet | Duolingo | ELSA Speak | **Marsa** |
|---------|-------|---------|----------|------------|-----------|
| Offline Dictionary | ✅ Strong | ❌ | ⚠️ Weak | ⚠️ Weak | ✅ **Strong** |
| Vocabulary Learning | ⚠️ Weak | ✅ Strong | ⚠️ Medium | ⚠️ Weak | ✅ **Strong** |
| Spaced Repetition | ❌ | ✅ Strong | ⚠️ Implicit | ❌ | ✅ **Strong (SM-2)** |
| Grammar Learning | ❌ | ❌ | ✅ Strong | ⚠️ Weak | ✅ **Strong** |
| Gamification | ❌ | ✅ Strong | ✅ Very Strong | ⚠️ Medium | ✅ **Very Strong** |
| AI Pronunciation | ❌ | ❌ | ⚠️ Weak | ✅ Very Strong | ✅ **Very Strong** |
| AI Personalization | ❌ | ⚠️ Weak | ⚠️ Medium | ✅ Strong | ✅ **Very Strong** |
| **All-in-One** | ❌ | ❌ | ❌ | ❌ | ✅ **CORE USP** |

---

*Document Version: 1.0*  
*Last Updated: October 2025*  
*Owner: Product Team*