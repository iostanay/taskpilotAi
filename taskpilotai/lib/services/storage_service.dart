import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/user.dart';

class StorageService {
  static const String _tasksBoxName = 'tasks';
  static const String _userBoxName = 'user';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AppUserAdapter());
    }
  }

  Future<Box<Task>> getTasksBox() async {
    if (!Hive.isBoxOpen(_tasksBoxName)) {
      return await Hive.openBox<Task>(_tasksBoxName);
    }
    return Hive.box<Task>(_tasksBoxName);
  }

  Future<Box<AppUser>> getUserBox() async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      return await Hive.openBox<AppUser>(_userBoxName);
    }
    return Hive.box<AppUser>(_userBoxName);
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final box = await getTasksBox();
    await box.clear();
    for (final task in tasks) {
      await box.put(task.id, task);
    }
  }

  Future<List<Task>> loadTasks() async {
    final box = await getTasksBox();
    return box.values.toList();
  }

  Future<void> saveTask(Task task) async {
    final box = await getTasksBox();
    await box.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    final box = await getTasksBox();
    await box.delete(taskId);
  }

  Future<void> saveUser(AppUser user) async {
    final box = await getUserBox();
    await box.put('current_user', user);
  }

  Future<AppUser?> loadUser() async {
    final box = await getUserBox();
    return box.get('current_user');
  }

  Future<void> clearUser() async {
    final box = await getUserBox();
    await box.delete('current_user');
  }

  Future<void> clearAll() async {
    final tasksBox = await getTasksBox();
    final userBox = await getUserBox();
    await tasksBox.clear();
    await userBox.clear();
  }
}

