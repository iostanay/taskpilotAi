import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(storageService);
});

final taskServiceProvider = Provider<TaskService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return TaskService(storageService);
});

final aiServiceProvider = Provider<AIService>((ref) {
  // OpenAI API Key - In production, use secure storage or environment variables
  const apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  return AIService(apiKey: apiKey.isEmpty ? null : apiKey);
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  try {
    final storageService = ref.watch(storageServiceProvider);
    // Load user directly from storage
    return await storageService.loadUser();
  } catch (e) {
    // If loading fails, return null (no user logged in)
    return null;
  }
});

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTasks();
});
