import 'dart:convert';

import 'package:flutter_application_1/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoCacheStore {
  static const _todosCacheKey = 'todos_cache';

  Future<List<Todo>> readTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_todosCacheKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final raw = jsonDecode(jsonStr) as List<dynamic>;
    return raw.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> writeTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      todos.map((todo) => _todoToStorageJson(todo)).toList(),
    );
    await prefs.setString(_todosCacheKey, encoded);
  }

  Future<void> clearTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todosCacheKey);
  }

  Map<String, dynamic> _todoToStorageJson(Todo todo) => {
        '_id': todo.id,
        ...todo.toJson(),
      };
}
