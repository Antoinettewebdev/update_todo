import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import 'todo_detail_screen.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.todoService,
  });

  final User user;
  final AuthService authService;
  final TodoService todoService;

  Future<void> _signOut(BuildContext context) async {
    await authService.signOut();
  }

  void _openDetail(BuildContext context, {TodoItem? item}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TodoDetailScreen(
          userId: user.uid,
          todoService: todoService,
          item: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Dos'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<TodoItem>>(
        stream: todoService.watchTodos(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load to-dos.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!;
          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No to-dos yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first item',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: todos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return _TodoTile(
                todo: todo,
                onTap: () => _openDetail(context, item: todo),
                onToggle: () => todoService.updateTodo(
                  userId: user.uid,
                  item: todo,
                  completed: !todo.completed,
                ),
                onDelete: () => todoService.deleteTodo(
                  userId: user.uid,
                  todoId: todo.id,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDetail(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final TodoItem todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete to-do?'),
            content: Text('Remove "${todo.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: todo.completed,
                  onChanged: (_) => onToggle(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title.isEmpty ? 'Untitled' : todo.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: todo.completed ? TextDecoration.lineThrough : null,
                          color: todo.completed
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                              : null,
                        ),
                      ),
                      if (todo.description.isNotEmpty)
                        Text(
                          todo.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
