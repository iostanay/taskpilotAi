import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/providers.dart';
import '../widgets/task_card.dart';
import '../widgets/task_stats_card.dart';
import 'create_task_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskPilot AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Assistant',
            onPressed: () {
              // TODO: Open AI assistant dialog
            },
          ),
          PopupMenuButton<void>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Text(userAsync.value?.email ?? 'User'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
                onTap: () async {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();
                  ref.invalidate(currentUserProvider);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/auth');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
          final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).toList();
          final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(tasksProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TaskStatsCard(
                      total: tasks.length,
                      todo: todoTasks.length,
                      inProgress: inProgressTasks.length,
                      completed: completedTasks.length,
                    ),
                  ),
                ),
                if (todoTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'To Do (${todoTasks.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = todoTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            // TODO: Navigate to task detail
                          },
                          onToggle: () async {
                            final taskService = ref.read(taskServiceProvider);
                            await taskService.toggleTaskStatus(task);
                            ref.invalidate(tasksProvider);
                          },
                        );
                      },
                      childCount: todoTasks.length,
                    ),
                  ),
                ],
                if (inProgressTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'In Progress (${inProgressTasks.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = inProgressTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            // TODO: Navigate to task detail
                          },
                          onToggle: () async {
                            final taskService = ref.read(taskServiceProvider);
                            await taskService.toggleTaskStatus(task);
                            ref.invalidate(tasksProvider);
                          },
                        );
                      },
                      childCount: inProgressTasks.length,
                    ),
                  ),
                ],
                if (completedTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Completed (${completedTasks.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = completedTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            // TODO: Navigate to task detail
                          },
                          onToggle: () async {
                            final taskService = ref.read(taskServiceProvider);
                            await taskService.toggleTaskStatus(task);
                            ref.invalidate(tasksProvider);
                          },
                        );
                      },
                      childCount: completedTasks.length,
                    ),
                  ),
                ],
                if (tasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create your first task',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading tasks: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(tasksProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}

