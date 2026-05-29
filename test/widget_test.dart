import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todos/controllers/font_settings_controller.dart';
import 'package:todos/main.dart';
import 'package:todos/models/todo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Todo parses API JSON and applies defaults', () {
    final todo = Todo.fromJson({
      '_id': 'todo-1',
      'title': 'Prepare Flutter tests',
      'reminderAt': '2026-06-01T09:30:00',
      'subTasks': [
        {'id': 'subtask-1', 'title': 'Update widget test'},
      ],
    });

    expect(todo.id, 'todo-1');
    expect(todo.title, 'Prepare Flutter tests');
    expect(todo.completed, isFalse);
    expect(todo.reminderAt, DateTime(2026, 6, 1, 9, 30));
    expect(todo.subTasks, hasLength(1));
    expect(todo.subTasks.single.completed, isFalse);
  });

  test('Todo serializes API-managed id out of request body', () {
    const todo = Todo(
      id: 'todo-1',
      title: 'Prepare Flutter tests',
      completed: true,
      reminderAt: DateTime(2026, 6, 1, 9, 30),
      subTasks: [
        SubTask(id: 'subtask-1', title: 'Update widget test', completed: true),
      ],
    );

    expect(todo.toJson(), {
      'title': 'Prepare Flutter tests',
      'completed': true,
      'subTasks': [
        {'id': 'subtask-1', 'title': 'Update widget test', 'completed': true},
      ],
      'reminderAt': '2026-06-01T09:30:00.000',
    });
  });

  test('FontSettingsController persists typography preferences', () async {
    final controller = FontSettingsController();
    await controller.loaded;

    controller.updateFontFamily('Inter');
    controller.updateFontWeight(FontWeight.w700);
    controller.updateFontSizeScale(1.125);
    await controller.pendingSave;
    controller.dispose();

    final restoredController = FontSettingsController();
    await restoredController.loaded;

    expect(restoredController.settings.fontFamily, 'Inter');
    expect(restoredController.settings.fontWeight, FontWeight.w700);
    expect(restoredController.settings.fontSizeScale, 1.125);

    restoredController.dispose();
  });

  testWidgets('renders cached todos when the network fetch fails', (
    WidgetTester tester,
  ) async {
    _seedCachedTodos();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Mes tâches'), findsOneWidget);
    expect(find.text('Prepare Flutter tests'), findsOneWidget);
    expect(find.text('Update widget test'), findsOneWidget);
    expect(find.text('Ajouter une tâche'), findsOneWidget);
    expect(
      find.textContaining(
        'Réseau indisponible, affichage des tâches en cache.',
      ),
      findsOneWidget,
    );
    expect(find.text('0'), findsNothing);
  });
}

void _seedCachedTodos() {
  const todo = Todo(
    id: 'todo-1',
    title: 'Prepare Flutter tests',
    subTasks: [SubTask(id: 'subtask-1', title: 'Update widget test')],
  );

  SharedPreferences.setMockInitialValues({
    'tinycrud_endpoint': 'https://example.invalid',
    'todos_cache': jsonEncode([
      {'_id': todo.id, ...todo.toJson()},
    ]),
  });
}
