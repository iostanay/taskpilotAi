# TaskPilot AI

An intelligent task management mobile application built with Flutter, featuring AI-powered task parsing, suggestions, and smart categorization using OpenAI.

## Features

- ✅ **AI-Powered Task Creation**: Parse natural language task descriptions with OpenAI
- 📱 **Offline-First**: Local storage with Hive for offline task management
- 🎯 **Smart Prioritization**: AI suggests task priorities based on content
- 🏷️ **Intelligent Tagging**: Automatic tag suggestions using AI
- 📊 **Task Dashboard**: View tasks organized by status (To Do, In Progress, Completed)
- 🔐 **Simple Authentication**: Email-based authentication flow
- 💾 **Local Storage**: All tasks stored locally with Hive

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- OpenAI API Key (optional, for AI features)

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code (Hive Adapters)

The Hive adapters are already generated, but if you modify the models, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure OpenAI API Key (Optional)

For AI features to work, you need an OpenAI API key. You can set it in one of two ways:

**Option A: Environment Variable (Recommended for Development)**
```bash
export OPENAI_API_KEY=your_api_key_here
flutter run --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY
```

**Option B: Direct in Code (Not Recommended for Production)**
Edit `lib/providers/providers.dart` and replace the `apiKey` parameter in `AIService`:

```dart
final aiServiceProvider = Provider<AIService>((ref) {
  const apiKey = 'your_api_key_here'; // Replace with your key
  return AIService(apiKey: apiKey.isEmpty ? null : apiKey);
});
```

**Note**: The app will work without an API key, but AI features will use fallback simple parsing.

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart            # Task model with Hive annotations
│   ├── task.g.dart          # Generated Hive adapter
│   ├── user.dart            # User model
│   └── user.g.dart          # Generated Hive adapter
├── services/                 # Business logic
│   ├── ai_service.dart      # OpenAI integration
│   ├── auth_service.dart    # Authentication logic
│   ├── storage_service.dart # Hive storage management
│   └── task_service.dart    # Task CRUD operations
├── providers/               # Riverpod state management
│   └── providers.dart       # Provider definitions
├── screens/                 # UI screens
│   ├── auth_screen.dart     # Login/signup screen
│   ├── dashboard_screen.dart # Main task dashboard
│   └── create_task_screen.dart # Task creation with AI
└── widgets/                 # Reusable widgets
    ├── task_card.dart       # Task list item widget
    └── task_stats_card.dart # Statistics overview widget
```

## AI Features

### Task Parsing
Enter a natural language description like "Buy groceries tomorrow - urgent" and the AI will:
- Extract the task title
- Suggest priority (high/medium/low)
- Suggest relevant tags
- Parse due dates if mentioned

### Smart Tagging
Click "AI Suggest" when creating a task to get intelligent tag recommendations based on:
- Task content
- Existing tags in your system
- Context and patterns

### Task Breakdown
(Coming soon) Break complex tasks into smaller subtasks automatically.

## Architecture

- **State Management**: Riverpod for reactive state management
- **Local Storage**: Hive for fast, offline-first data persistence
- **AI Integration**: OpenAI API (gpt-4o-mini) for intelligent features
- **UI Framework**: Flutter with Material 3 design

## Development

### Adding New Features

1. **New Task Fields**: Update `lib/models/task.dart` and regenerate adapters
2. **New AI Features**: Extend `lib/services/ai_service.dart`
3. **New Screens**: Add to `lib/screens/` and update routing in `main.dart`

### Running Tests

```bash
flutter test
```

## License

This project is a starting point for a Flutter application.

## Notes

- The app works offline by default - all tasks are stored locally
- AI features require an active internet connection and OpenAI API key
- Authentication is currently simplified (mock) - integrate with Firebase Auth for production
