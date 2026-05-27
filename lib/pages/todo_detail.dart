import 'package:flutter/material.dart';
import 'package:todos/models/todo.dart';
import 'package:todos/services/todo_service.dart';
import 'package:uuid/uuid.dart';

class TodoDetailPage extends StatefulWidget {
  const TodoDetailPage({super.key, required this.todo});

  final Todo todo;

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final _service = TodoService();
  final _uuid = const Uuid();

  late Todo _todo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  Future<void> _persist(Todo updated) async {
    setState(() => _isSaving = true);
    try {
      await _service.update(updated);
      setState(() => _todo = updated);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _showRenameTodoDialog() async {
    final controller = TextEditingController(text: _todo.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer la tâche'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    final title = controller.text.trim();
    if (confirmed != true || title.isEmpty || title == _todo.title) return;

    await _persist(_todo.copyWith(title: title));
  }

  Future<void> _showAddSubtaskDialog() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle sous-tâche'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Titre de la sous-tâche'),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    final title = controller.text.trim();
    if (confirmed != true || title.isEmpty) return;

    final newSubtask = SubTask(id: _uuid.v4(), title: title);
    final updated = _todo.copyWith(subTasks: [..._todo.subTasks, newSubtask]);
    await _persist(updated);
  }

  Future<void> _showRenameSubtaskDialog(SubTask subtask) async {
    final controller = TextEditingController(text: subtask.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer la sous-tâche'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    final title = controller.text.trim();
    if (confirmed != true || title.isEmpty || title == subtask.title) return;

    final updated = _todo.copyWith(
      subTasks: _todo.subTasks
          .map((s) => s.id == subtask.id ? s.copyWith(title: title) : s)
          .toList(),
    );
    await _persist(updated);
  }

  Future<void> _toggleSubtask(SubTask subtask) async {
    final updated = _todo.copyWith(
      subTasks: _todo.subTasks
          .map(
            (s) => s.id == subtask.id ? s.copyWith(completed: !s.completed) : s,
          )
          .toList(),
    );
    await _persist(updated);
  }

  Future<void> _deleteSubtask(SubTask subtask) async {
    final updated = _todo.copyWith(
      subTasks: _todo.subTasks.where((s) => s.id != subtask.id).toList(),
    );
    await _persist(updated);
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
    final doneCount = _todo.subTasks.where((s) => s.completed).length;
    final total = _todo.subTasks.length;

    return PopScope<Todo>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_todo);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_todo.title, overflow: TextOverflow.ellipsis),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Renommer la tâche',
                onPressed: _showRenameTodoDialog,
              ),
          ],
        ),
        body: Column(
          children: [
            if (total > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: total > 0 ? doneCount / total : 0,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$doneCount / $total',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _todo.subTasks.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: _todo.subTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final subtask = _todo.subTasks[i];
                        return _SubtaskCard(
                          subtask: subtask,
                          onToggle: () => _toggleSubtask(subtask),
                          onRename: () => _showRenameSubtaskDialog(subtask),
                          onDelete: () => _deleteSubtask(subtask),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isSaving ? null : _showAddSubtaskDialog,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une sous-tâche'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.playlist_add,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune sous-tâche pour le moment',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour découper cette tâche en étapes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtaskCard extends StatelessWidget {
  const _SubtaskCard({
    required this.subtask,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
  });

  final SubTask subtask;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Checkbox(value: subtask.completed, onChanged: (_) => onToggle()),
            Expanded(
              child: Text(
                subtask.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: subtask.completed
                      ? TextDecoration.lineThrough
                      : null,
                  color: subtask.completed
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onRename,
              tooltip: 'Renommer',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}
