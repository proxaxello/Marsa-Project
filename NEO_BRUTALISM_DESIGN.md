# Neo-Brutalism Design System - Marsa App

## Overview
This document outlines the Neo-Brutalism design system implemented for the Marsa English learning app, following the comprehensive UI/UX requirements.

## Design Principles

### 1. **Bold Colors & High Contrast**
- **Neon Green** (#39FF14): Primary actions, success states, online status
- **Electric Yellow** (#FFE500): Nouns, favorites, highlights
- **Hot Pink** (#FF006E): Verbs, errors, hero sections
- **Cyan Blue** (#00F5FF): Adjectives, audio features, empty states
- **Pure Black** (#000000): Borders, text, shadows
- **Pure White** (#FFFFFF): Backgrounds, cards

### 2. **Thick Black Borders**
- Standard: 3px
- Prominent elements: 4px
- Extra emphasis: 6px
- All borders are solid black with no border-radius

### 3. **Harsh Drop Shadows**
- Small: offset(2, 2), no blur
- Medium: offset(4, 4), no blur
- Large: offset(6, 6), no blur
- Extra Large: offset(8, 8), no blur
- **No soft shadows or blur effects**

### 4. **Raw Typography**
- Font weights: 700 (bold) and 900 (black) only
- All caps for labels and buttons
- Letter spacing for emphasis
- No subtle font variations

### 5. **Asymmetrical Layouts**
- Slight rotations (±0.01 to ±0.02 radians)
- Intentional "misalignment"
- Staggered card layouts

## Implemented Screens

### 1. Dictionary Screen ✅

**Location**: `lib/presentation/screens/dictionary_screen.dart`

**Features**:
- ✅ Highly prominent search bar (64px height, large icons)
- ✅ IPA transcription display for each word
- ✅ Word type badges (noun, verb, adjective, etc.)
- ✅ Bold category colors matching design system
- ✅ Audio pronunciation button (text-to-speech)
- ✅ Very prominent "SAVE TO FLASHCARD" button
- ✅ Offline status indicator
- ✅ Example sentences with translations
- ✅ Favorite toggle functionality
- ✅ Category filtering with horizontal scroll
- ✅ Add word form with all fields
- ✅ Neo-brutal styling throughout

**Design Elements**:
```dart
// Search Bar
- Height: 64px
- Border: 4px black
- Shadow: offset(6, 6)
- Icon size: 32px
- Font size: 18px, weight 700

// Word Cards
- Border: 4px black
- Shadow: offset(6, 6)
- Padding: 20px
- Slight rotation for variety

// Save to Flashcard Button
- Height: 56px
- Background: Neon Green (#39FF14)
- Border: 4px black
- Shadow: offset(4, 4)
- Font: 18px, weight 900
```

### 2. Theme System ✅

**Location**: `lib/presentation/theme/neo_brutal_theme.dart`

**Provides**:
- Color palette constants
- Border width constants
- Shadow configurations
- Typography styles
- Component builders (buttons, cards, badges, etc.)
- Material theme configuration

**Usage Example**:
```dart
// Using the theme system
Container(
  decoration: NeoBrutalTheme.containerDecoration(
    backgroundColor: NeoBrutalTheme.neonGreen,
    shadow: NeoBrutalTheme.shadowLarge,
  ),
  child: Text(
    'HELLO',
    style: NeoBrutalTheme.headingMedium,
  ),
)

// Using pre-built components
NeoBrutalTheme.primaryButton(
  text: 'CLICK ME',
  onPressed: () {},
  icon: Icons.check,
  isFullWidth: true,
)
```

## Component Library

### Buttons
```dart
// Primary Button
NeoBrutalTheme.primaryButton(
  text: 'SAVE',
  onPressed: () {},
  backgroundColor: NeoBrutalTheme.neonGreen,
  icon: Icons.save,
)

// Icon Button
NeoBrutalTheme.iconButton(
  icon: Icons.volume_up,
  backgroundColor: NeoBrutalTheme.cyanBlue,
  onPressed: () {},
)
```

### Cards
```dart
// Standard Card
Container(
  decoration: NeoBrutalTheme.cardDecoration(),
  child: content,
)

// Rotated Card
NeoBrutalTheme.rotatedCard(
  rotation: 0.01,
  backgroundColor: NeoBrutalTheme.pureWhite,
  child: content,
)
```

### Badges
```dart
NeoBrutalTheme.badge(
  text: 'NOUN',
  backgroundColor: NeoBrutalTheme.electricYellow,
)
```

### Search Bar
```dart
NeoBrutalTheme.searchBar(
  controller: searchController,
  onChanged: (value) {},
  hintText: 'SEARCH DICTIONARY...',
  onClear: () {},
)
```

### Hero Section
```dart
NeoBrutalTheme.heroSection(
  title: 'DICTIONARY',
  subtitle: 'English ⟷ Vietnamese',
  description: '1000 words available',
  backgroundColor: NeoBrutalTheme.hotPink,
)
```

### Status Banner
```dart
NeoBrutalTheme.statusBanner(
  text: 'ONLINE - Dictionary synced',
  icon: Icons.wifi,
  backgroundColor: NeoBrutalTheme.neonGreen,
)
```

## Typography Scale

### Headings
- **Large**: 48px, weight 900 (Hero titles)
- **Medium**: 36px, weight 900 (Section titles)
- **Small**: 24px, weight 900 (Card titles)

### Body Text
- **Large**: 18px, weight 700 (Important content)
- **Medium**: 16px, weight 700 (Standard content)
- **Small**: 14px, weight 700 (Secondary content)

### Labels
- **Large**: 14px, weight 900, letter-spacing 1.2 (Button text)
- **Small**: 10px, weight 900, letter-spacing 1.2 (Field labels)

## Color Usage Guidelines

### Neon Green (#39FF14)
- Primary action buttons
- Success messages
- Online status
- Positive feedback
- "Save to Flashcard" buttons

### Electric Yellow (#FFE500)
- Noun badges
- Favorite indicators
- Highlights
- Warning states

### Hot Pink (#FF006E)
- Verb badges
- Delete buttons
- Error states
- Hero sections
- Attention-grabbing elements

### Cyan Blue (#00F5FF)
- Adjective badges
- Audio/pronunciation features
- Empty states
- Information displays

## Accessibility Considerations

1. **High Contrast**: All text has strong contrast against backgrounds
2. **Large Touch Targets**: Buttons are minimum 48px height
3. **Clear Visual Hierarchy**: Bold typography and spacing
4. **Icon + Text**: Important actions have both icon and text labels
5. **Readable Fonts**: Weight 700+ ensures readability

## Implementation Checklist

### Dictionary Screen ✅
- [x] Prominent search bar
- [x] IPA transcription
- [x] Word types display
- [x] Audio pronunciation
- [x] Save to Flashcard button
- [x] Offline indicator
- [x] Example sentences
- [x] Category filtering
- [x] Neo-brutal styling

### Remaining Screens 🚧
- [ ] Home Screen / Dashboard
- [ ] Flashcard Learning Screen
- [ ] AI Pronunciation Practice Screen
- [ ] Profile / Progress Screen

## Next Steps

1. **Apply theme to existing screens**:
   - Update Home Screen with Neo-Brutalism
   - Redesign Practice Screen
   - Enhance Settings Screen

2. **Create new screens**:
   - Flashcard Review (with spaced repetition UI)
   - AI Pronunciation Practice (with waveform)
   - Progress/Profile Screen (with badges)

3. **Add animations**:
   - Button press effects (shadow removal)
   - Card flip animations (for flashcards)
   - Slide-in transitions

4. **Enhance components**:
   - Custom progress bars
   - Achievement badges
   - Leaderboard cards
   - Streak indicators

## Code Examples

### Creating a Neo-Brutal Button
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    color: NeoBrutalTheme.neonGreen,
    border: Border.all(
      color: NeoBrutalTheme.pureBlack,
      width: NeoBrutalTheme.borderWidthThick,
    ),
    boxShadow: [NeoBrutalTheme.shadowMedium],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      child: Center(
        child: Text(
          'BUTTON TEXT',
          style: NeoBrutalTheme.buttonText,
        ),
      ),
    ),
  ),
)
```

### Creating a Word Card
```dart
Transform.rotate(
  angle: 0.01, // Slight rotation
  child: Container(
    padding: EdgeInsets.all(20),
    decoration: NeoBrutalTheme.cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word
        Text('hello', style: NeoBrutalTheme.headingMedium),
        SizedBox(height: 8),
        // IPA
        Text('/həˈloʊ/', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
        )),
        SizedBox(height: 8),
        // Meaning
        Text('xin chào', style: NeoBrutalTheme.bodyLarge),
      ],
    ),
  ),
)
```

## Resources

- **Theme File**: `lib/presentation/theme/neo_brutal_theme.dart`
- **Dictionary Screen**: `lib/presentation/screens/dictionary_screen.dart`
- **Color Palette**: See NeoBrutalTheme class constants
- **Typography**: See NeoBrutalTheme text styles

## Design Philosophy

> "Neo-Brutalism is about being bold, direct, and unapologetic. Every element should be clearly defined with thick borders and harsh shadows. The design should feel raw and intentional, not polished or subtle. Typography should be heavy and readable. Colors should pop with high contrast. Layouts can be slightly asymmetrical to add personality."

This design system ensures consistency across the Marsa app while maintaining the bold, raw aesthetic of Neo-Brutalism.
