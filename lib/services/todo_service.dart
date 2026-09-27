import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/todo_item.dart';

class TodoService {
  TodoService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('todos');
  }

  Stream<List<TodoItem>> watchTodos(String userId) {
    return _collection(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TodoItem.fromFirestore).toList());
  }

  Future<TodoItem> createTodo({
    required String userId,
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final doc = _collection(userId).doc();
    final item = TodoItem(
      id: doc.id,
      title: title.trim(),
      description: description.trim(),
      completed: false,
      createdAt: now,
      updatedAt: now,
    );
    await doc.set(item.toFirestore());
    return item;
  }

  Future<void> updateTodo({
    required String userId,
    required TodoItem item,
    String? title,
    String? description,
    bool? completed,
  }) async {
    final updated = item.copyWith(
      title: title?.trim(),
      description: description?.trim(),
      completed: completed,
      updatedAt: DateTime.now(),
    );
    await _collection(userId).doc(item.id).update(updated.toFirestore());
  }

  Future<void> deleteTodo({
    required String userId,
    required String todoId,
  }) async {
    await _collection(userId).doc(todoId).delete();
  }
}
