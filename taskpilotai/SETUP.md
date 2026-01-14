# Quick Setup Guide

## 1. Install Dependencies
```bash
flutter pub get
```

## 2. Set OpenAI API Key (Optional)

The app works without an API key, but AI features will use simple fallback parsing.

### Option A: Environment Variable
```bash
export OPENAI_API_KEY=sk-your-key-here
flutter run --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY
```

### Option B: Edit Code
Edit `lib/providers/providers.dart` line 24:
```dart
const apiKey = 'sk-your-key-here'; // Add your key here
```

## 3. Run the App
```bash
flutter run
```

## Features Implemented

✅ **Core Features:**
- Authentication screen with email input
- Task dashboard with status organization
- Create/edit tasks with AI parsing
- Offline storage with Hive
- Task statistics overview

✅ **AI Features:**
- Natural language task parsing
- Smart priority suggestions
- Intelligent tag recommendations
- Task breakdown (ready for implementation)

## Project Structure

- `lib/models/` - Data models (Task, User) with Hive adapters
- `lib/services/` - Business logic (AI, Auth, Storage, Tasks)
- `lib/providers/` - Riverpod state management
- `lib/screens/` - UI screens (Auth, Dashboard, Create Task)
- `lib/widgets/` - Reusable UI components

## Next Steps

1. Add Firebase Authentication for production
2. Implement task detail/edit screen
3. Add task search and filtering
4. Implement task breakdown feature
5. Add notifications for due dates
6. Implement task sharing/collaboration

