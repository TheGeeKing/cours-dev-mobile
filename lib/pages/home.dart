import 'package:flutter/material.dart';
import 'package:todos/models/todo.dart';
import 'package:todos/pages/settings_page.dart';
import 'package:todos/pages/todo_detail.dart';
import 'package:todos/services/todo_reminder_notification_service.dart';
import 'package:todos/services/todo_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = TodoService();
  final _notificationService = TodoReminderNotificationService.instance;
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
      final warning = _service.lastFetchWarning;
      if (warning != null) {
        _showError(warning);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> pickReminder() async {
            final now = DateTime.now();
            final date = await showDatePicker(
              context: ctx,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(now.year, now.month, now.day),
              lastDate: DateTime(now.year + 5, now.month, now.day),
              locale: const Locale('fr'),
            );
            if (date == null || !ctx.mounted) return;

            final time = await showTimePicker(
              context: ctx,
              initialTime:
                  selectedTime ??
                  TimeOfDay.fromDateTime(
                    DateTime.now().add(const Duration(minutes: 5)),
                  ),
            );
            if (time == null) return;

            setDialogState(() {
              selectedDate = date;
              selectedTime = time;
            });
          }

          final reminderAt = _combineReminder(selectedDate, selectedTime);

          return AlertDialog(
            title: const Text('Nouvelle tâche'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Titre de la tâche',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => Navigator.pop(ctx, true),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: pickReminder,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(
                      reminderAt == null
                          ? 'Ajouter un rappel'
                          : _formatReminder(reminderAt),
                    ),
                  ),
                  if (reminderAt != null)
                    TextButton.icon(
                      onPressed: () => setDialogState(() {
                        selectedDate = null;
                        selectedTime = null;
                      }),
                      icon: const Icon(Icons.notifications_off_outlined),
                      label: const Text('Retirer le rappel'),
                    ),
                ],
              ),
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
          );
        },
      ),
    );

    final title = controller.text.trim();
    final reminderAt = _combineReminder(selectedDate, selectedTime);
    controller.dispose();
    if (confirmed != true || title.isEmpty) return;
    if (reminderAt != null && !reminderAt.isAfter(DateTime.now())) {
      _showError('Choisissez une date et une heure dans le futur.');
      return;
    }

    try {
      final created = await _service.create(title, reminderAt: reminderAt);
      if (created.reminderAt != null) {
        final scheduled = await _notificationService.scheduleForTodo(created);
        if (!scheduled) {
          _showError(
            'La tâche est créée, mais le rappel n\'a pas pu être programmé.',
          );
        }
      }
      setState(() => _todos.add(created));
    } catch (e) {
      _showError(e.toString());
    }
  }

  DateTime? _combineReminder(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatReminder(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'Rappel le $day/$month/${local.year} a $hour:$minute';
  }

  Future<void> _showRenameDialog(Todo todo) async {
    final controller = TextEditingController(text: todo.title);
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
    if (confirmed != true || title.isEmpty || title == todo.title) return;

    final updated = todo.copyWith(title: title);
    try {
      await _service.update(updated);
      await _notificationService.scheduleForTodo(updated);
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
      await _notificationService.scheduleForTodo(updated);
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
      await _notificationService.cancelForTodo(todo);
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
            tooltip: 'Actualiser',
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
              label: const Text('Réessayer'),
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
              'Aucune tâche pour le moment !',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer votre première tâche.',
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
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _TodoCard(
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
            await _notificationService.scheduleForTodo(updated);
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

String _formatReminder(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return 'Rappel le $day/$month/${local.year} a $hour:$minute';
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
                    tooltip: 'Renommer',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: widget.onDelete,
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
              if (widget.todo.reminderAt != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatReminder(widget.todo.reminderAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
