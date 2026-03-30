import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/todo.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/pages/todo_detail.dart';
import 'package:flutter_application_1/services/todo_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = TodoService();
  List<Todo> _todos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final todos = await _service.fetchAll();
      setState(() => _todos = todos);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Todo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Todo title'),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    final title = controller.text.trim();
    if (confirmed != true || title.isEmpty) return;

    try {
      final created = await _service.create(title);
      setState(() => _todos.add(created));
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _showRenameDialog(Todo todo) async {
    final controller = TextEditingController(text: todo.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Todo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final title = controller.text.trim();
    if (confirmed != true || title.isEmpty || title == todo.title) return;

    final updated = todo.copyWith(title: title);
    try {
      await _service.update(updated);
      setState(() {
        final idx = _todos.indexWhere((t) => t.id == todo.id);
        if (idx != -1) _todos[idx] = updated;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _toggleCompleted(Todo todo) async {
    final updated = todo.copyWith(completed: !todo.completed);
    try {
      await _service.update(updated);
      setState(() {
        final idx = _todos.indexWhere((t) => t.id == todo.id);
        if (idx != -1) _todos[idx] = updated;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    try {
      await _service.delete(todo.id!);
      setState(() => _todos.removeWhere((t) => t.id == todo.id));
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadTodos,
          ),
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            tooltip: 'Paramètres d\'affichage',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: _buildBody(theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une tâche'),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadTodos,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No todos yet!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first todo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: _todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _TodoCard(
        todo: _todos[i],
        onToggle: () => _toggleCompleted(_todos[i]),
        onRename: () => _showRenameDialog(_todos[i]),
        onDelete: () => _deleteTodo(_todos[i]),
        onTap: () async {
          final updated = await Navigator.push<Todo>(
            context,
            MaterialPageRoute(builder: (_) => TodoDetailPage(todo: _todos[i])),
          );
          if (updated != null) {
            setState(() {
              final idx = _todos.indexWhere((t) => t.id == updated.id);
              if (idx != -1) _todos[idx] = updated;
            });
          }
        },
      ),
    );
  }
}

class _TodoCard extends StatefulWidget {
  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
    required this.onTap,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  State<_TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<_TodoCard> {
  static const _previewLimit = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subTasks = widget.todo.subTasks;
    final hasMore = subTasks.length > _previewLimit;
    final visibleTasks = _expanded
        ? subTasks
        : subTasks.take(_previewLimit).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Todo header row ──────────────────────────────────────
              Row(
                children: [
                  Checkbox(
                    value: widget.todo.completed,
                    onChanged: (_) => widget.onToggle(),
                  ),
                  Expanded(
                    child: Text(
                      widget.todo.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: widget.todo.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: widget.todo.completed
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: widget.onRename,
                    tooltip: 'Rename',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),

              // ── Subtask preview rows ─────────────────────────────────
              if (subTasks.isNotEmpty) ...[
                for (final subtask in visibleTasks)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.subdirectory_arrow_right,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        if (subtask.completed)
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: theme.colorScheme.primary,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            size: 14,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtask.title,
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: subtask.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: subtask.completed
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Show more / Show less toggle ─────────────────────
                if (hasMore)
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 6),
                      child: Row(
                        children: [
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _expanded
                                ? 'Montrer moins'
                                : '${subTasks.length - _previewLimit} sous-tâche${subTasks.length - _previewLimit > 1 ? 's' : ''} en plus ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
