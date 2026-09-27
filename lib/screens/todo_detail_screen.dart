import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../services/todo_service.dart';

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({
    super.key,
    required this.userId,
    required this.todoService,
    this.item,
  });

  final String userId;
  final TodoService todoService;
  final TodoItem? item;

  bool get isEditing => item != null;

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.isEditing) {
        await widget.todoService.updateTodo(
          userId: widget.userId,
          item: widget.item!,
          title: title,
          description: _descriptionController.text,
        );
      } else {
        await widget.todoService.createTodo(
          userId: widget.userId,
          title: title,
          description: _descriptionController.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save to-do')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (!widget.isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete to-do?'),
        content: const Text('This cannot be undone.'),
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

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await widget.todoService.deleteTodo(
        userId: widget.userId,
        todoId: widget.item!.id,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete to-do')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit To-Do' : 'New To-Do'),
        actions: [
          if (widget.isEditing)
            IconButton(
              tooltip: 'Delete',
              onPressed: _isSaving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'What needs to be done?',
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: !widget.isEditing,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Optional details',
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 5,
            minLines: 3,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.isEditing ? 'Save changes' : 'Create to-do'),
          ),
        ),
      ),
    );
  }
}
