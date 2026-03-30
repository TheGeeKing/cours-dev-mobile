import 'dart:convert';

import 'package:flutter_application_1/models/todo.dart';
import 'package:http/http.dart' as http;

class TodoService {
  static const _base =
      'https://crudcrud.com/api/6f72d418c74448859fb11cac0e687e86/todos';

  static const _headers = {'Content-Type': 'application/json'};

  Future<List<Todo>> fetchAll() async {
    final res = await http.get(Uri.parse(_base));
    _assertStatus(res, 200, 'fetch todos');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Todo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Todo> create(String title) async {
    final body = jsonEncode(Todo(title: title).toJson());
    final res = await http.post(
      Uri.parse(_base),
      headers: _headers,
      body: body,
    );
    _assertStatus(res, 201, 'create todo');
    return Todo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> update(Todo todo) async {
    final res = await http.put(
      Uri.parse('$_base/${todo.id}'),
      headers: _headers,
      body: jsonEncode(todo.toJson()),
    );
    _assertStatus(res, 200, 'update todo');
  }

  Future<void> delete(String id) async {
    final res = await http.delete(Uri.parse('$_base/$id'));
    _assertStatus(res, 200, 'delete todo');
  }

  void _assertStatus(http.Response res, int expected, String action) {
    if (res.statusCode != expected) {
      throw Exception(
        'Failed to $action — HTTP ${res.statusCode}: ${res.body}',
      );
    }
  }
}
