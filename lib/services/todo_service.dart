import 'dart:convert';

import 'package:todos/models/todo.dart';
import 'package:todos/services/endpoint_store.dart';
import 'package:todos/services/todo_cache_store.dart';
import 'package:http/http.dart' as http;

class TodoService {
  static const _headers = {'Content-Type': 'application/json'};
  final EndpointStore _endpointStore;
  final TodoCacheStore _cacheStore;
  String? _lastFetchWarning;

  TodoService({EndpointStore? endpointStore, TodoCacheStore? cacheStore})
    : _endpointStore = endpointStore ?? EndpointStore(),
      _cacheStore = cacheStore ?? TodoCacheStore();

  String? get lastFetchWarning => _lastFetchWarning;

  Future<List<Todo>> fetchAll() async {
    _lastFetchWarning = null;
    try {
      final res = await _requestWithEndpointRefresh(
        (baseUrl) => http.get(Uri.parse('$baseUrl/todos')),
      );
      _assertStatus(res, 200, 'fetch todos');
      final list = jsonDecode(res.body) as List<dynamic>;
      final todos = list
          .map((e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cacheStore.writeTodos(todos);
      return todos;
    } catch (e) {
      final cachedTodos = await _cacheStore.readTodos();
      if (cachedTodos.isNotEmpty) {
        _lastFetchWarning =
            'Network failed, showing cached todos. (${e.toString()})';
        return cachedTodos;
      }
      rethrow;
    }
  }

  Future<Todo> create(String title) async {
    final body = jsonEncode(Todo(title: title).toJson());
    final res = await _requestWithEndpointRefresh(
      (baseUrl) =>
          http.post(Uri.parse('$baseUrl/todos'), headers: _headers, body: body),
    );
    _assertStatus(res, 201, 'create todo');
    final created = Todo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    final cachedTodos = await _cacheStore.readTodos();
    await _cacheStore.writeTodos([...cachedTodos, created]);
    return created;
  }

  Future<void> update(Todo todo) async {
    final todoId = todo.id;
    if (todoId == null) {
      throw Exception('Cannot update todo without id.');
    }

    final res = await _requestWithEndpointRefresh(
      (baseUrl) => http.put(
        Uri.parse('$baseUrl/todos/$todoId'),
        headers: _headers,
        body: jsonEncode(todo.toJson()),
      ),
    );
    _assertStatus(res, 200, 'update todo');
    final cachedTodos = await _cacheStore.readTodos();
    final updated = cachedTodos
        .map((item) => item.id == todoId ? todo : item)
        .toList();
    await _cacheStore.writeTodos(updated);
  }

  Future<void> delete(String id) async {
    final res = await _requestWithEndpointRefresh(
      (baseUrl) => http.delete(Uri.parse('$baseUrl/todos/$id')),
    );
    _assertStatus(res, 200, 'delete todo');
    final cachedTodos = await _cacheStore.readTodos();
    final filtered = cachedTodos.where((item) => item.id != id).toList();
    await _cacheStore.writeTodos(filtered);
  }

  Future<http.Response> _requestWithEndpointRefresh(
    Future<http.Response> Function(String baseUrl) request,
  ) async {
    var baseUrl = await _endpointStore.getBaseUrl();
    var res = await request(baseUrl);

    if (res.statusCode == 400) {
      baseUrl = await _endpointStore.refreshEndpointFromCrudCrudPage();
      res = await request(baseUrl);
    }

    return res;
  }

  void _assertStatus(http.Response res, int expected, String action) {
    if (res.statusCode != expected) {
      throw Exception(
        'Failed to $action — HTTP ${res.statusCode}: ${res.body}',
      );
    }
  }
}
