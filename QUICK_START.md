# 🚀 Marsa App - Quick Start Guide

## ✅ Đã hoàn thành

### 1. **Authentication Bypass** 
App đã được cấu hình để **TỰ ĐỘNG ĐĂNG NHẬP** mà không cần backend server.

### 2. **Neo-Brutalism Dictionary**
Giao diện Dictionary mới với thiết kế Neo-Brutalism đã sẵn sàng!

## 📱 Cách sử dụng

### Bước 1: Mở App trên Emulator
App đã được cài đặt trên emulator `sdk gphone64 x86 64`

### Bước 2: Tự động vào App
- ✅ **KHÔNG CẦN ĐĂNG NHẬP**
- ✅ App sẽ tự động bypass màn hình login
- ✅ Vào thẳng MainScreen với 6 tabs

### Bước 3: Xem Dictionary Screen
1. Nhấn vào tab **Dictionary** (icon sách 📖, tab thứ 2)
2. Bạn sẽ thấy:
   - ✅ Search bar lớn với border đen 4px
   - ✅ Status banner màu xanh neon "ONLINE"
   - ✅ Hero section màu hồng "DICTIONARY"
   - ✅ Buttons "ADD WORD" và "FAVORITES"
   - ✅ Category filter chips

## 🎨 Tính năng Dictionary

### Thêm từ mới
1. Nhấn button **"ADD WORD"** (màu xanh neon)
2. Điền thông tin:
   - English (bắt buộc)
   - Vietnamese (bắt buộc)
   - Example Sentence (tùy chọn)
   - Example Translation (tùy chọn)
   - Category (NOUN, VERB, ADJECTIVE, etc.)
   - Difficulty (BEGINNER, INTERMEDIATE, ADVANCED)
3. Nhấn **"ADD WORD"** để lưu

### Tìm kiếm từ
- Gõ từ vào search bar lớn ở trên cùng
- Kết quả hiện ngay lập tức

### Lọc theo Category
- Nhấn vào các chip: ALL, NOUN, VERB, ADJECTIVE, ADVERB, PHRASE, IDIOM
- Danh sách từ sẽ được lọc theo category

### Xem từ yêu thích
- Nhấn button **"FAVORITES"** (màu vàng)
- Chỉ hiển thị các từ đã được đánh dấu favorite

### Tương tác với Word Card
Mỗi word card có:
- 🔊 **Volume button** (màu cyan) - Nghe phát âm
- ⭐ **Star button** (màu vàng) - Đánh dấu favorite
- 🗑️ **Delete button** (màu hồng) - Xóa từ
- 📑 **SAVE TO FLASHCARD** (button lớn màu xanh neon) - Lưu vào flashcard

## 🎯 Neo-Brutalism Design Elements

### Colors
- **Neon Green** (#39FF14) - Buttons, online status
- **Electric Yellow** (#FFE500) - Nouns, favorites
- **Hot Pink** (#FF006E) - Verbs, delete, hero
- **Cyan Blue** (#00F5FF) - Adjectives, audio
- **Black** - Borders (4px thick)
- **White** - Backgrounds

### Typography
- **48px** - Hero titles (DICTIONARY)
- **36px** - Word display
- **18px** - Buttons, search
- **Font weight** - 700-900 (Bold to Black)
- **All caps** - Labels and buttons

### Effects
- **Thick borders** - 3-4px solid black
- **Harsh shadows** - offset(4-8px) no blur
- **Slight rotations** - Cards rotated ±0.01-0.02 radians
- **No gradients** - Pure solid colors only

## 🔧 Technical Details

### Database
- **SQLite** local database
- **Offline-first** - Tất cả dữ liệu lưu local
- **Auto-migration** - Tự động update schema

### State Management
- **BLoC pattern** - WordBloc quản lý state
- **Events**: LoadAllWords, AddWordWithDetails, UpdateWord, ToggleFavorite, SearchWords
- **States**: WordInitial, WordLoading, WordLoaded, WordError

### Text-to-Speech
- **flutter_tts** package
- **English (US)** voice
- **Offline** - Không cần internet

## 📂 File Structure

```
lib/
├── data/
│   ├── models/word_model.dart (Enhanced)
│   ├── providers/dictionary_provider.dart (Enhanced)
│   └── repositories/dictionary_repository.dart (Enhanced)
├── logic/
│   └── blocs/
│       └── word/
│           ├── word_bloc.dart (Enhanced)
│           ├── word_event.dart (Enhanced)
│           └── word_state.dart
├── presentation/
│   ├── screens/
│   │   ├── dictionary_screen.dart (NEW - 900 lines)
│   │   └── main_screen.dart (Enhanced)
│   └── theme/
│       └── neo_brutal_theme.dart (NEW - 500 lines)
└── main.dart (Enhanced)
```

## 🐛 Troubleshooting

### App không tự động vào?
- Kiểm tra `auth_bloc.dart` có dòng bypass:
  ```dart
  emit(const AuthAuthenticated(token: 'test_token_for_development'));
  ```

### Dictionary tab trống?
- Thêm từ mới bằng button "ADD WORD"
- Hoặc import sample data

### Text-to-speech không hoạt động?
- Kiểm tra emulator có hỗ trợ TTS
- Thử trên physical device

### Emulator hết dung lượng?
```bash
adb -s emulator-5554 shell pm clear com.android.vending
```

## 🔄 Rebuild App

Nếu cần rebuild:
```bash
cd marsa_app
flutter clean
flutter pub get
flutter build apk --debug
flutter run -d emulator-5554
```

## 📚 Documentation

- **Design System**: `NEO_BRUTALISM_DESIGN.md`
- **Implementation**: `IMPLEMENTATION_SUMMARY.md`
- **Authentication**: `AUTHENTICATION_GUIDE.md`

## ✨ Next Steps

1. ✅ Test Dictionary features
2. ✅ Add sample words
3. ✅ Test search and filters
4. ✅ Test text-to-speech
5. ✅ Test favorites
6. 🔄 Apply Neo-Brutalism to other screens
7. 🔄 Implement Flashcard screen
8. 🔄 Setup backend (optional)

---

**Enjoy your Neo-Brutalism Dictionary! 🎨**
