import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'storage_service.dart';

class TaskService {
  final StorageService _storageService;
  final _uuid = const Uuid();

  TaskService(this._storageService);

  Future<List<Task>> getTasks() async {
    return await _storageService.loadTasks();
  }

  Future<Task> createTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> tags = const [],
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      status: TaskStatus.todo,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags,
    );

    await _storageService.saveTask(task);
    return task;
  }

  Future<Task> updateTask(Task task) async {
    await _storageService.saveTask(task);
    return task;
  }

  Future<void> deleteTask(String taskId) async {
    await _storageService.deleteTask(taskId);
  }

  Future<Task> toggleTaskStatus(Task task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.todo
        : TaskStatus.completed;
    
    final updatedTask = task.copyWith(
      status: newStatus,
      completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
    );

    await _storageService.saveTask(updatedTask);
    return updatedTask;
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final allTasks = await getTasks();
    return allTasks.where((task) => task.status == status).toList();
  }

  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final allTasks = await getTasks();
    return allTasks.where((task) => task.priority == priority).toList();
  }
}

