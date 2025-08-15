import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;
import 'package:task_manager/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_state.dart';
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:task_manager/features/tasks/presentation/widgets/blue_text_field.dart'; // added

class AddTaskSheet extends StatefulWidget {
  final Task? initialTask; // null => create
  const AddTaskSheet({super.key, this.initialTask});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _deadline = DateTime.now();
  TaskStatus _status = TaskStatus.inProgress;
  bool _saving = false;
  bool _deleting = false; // added

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _deadline,
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_deadline));
    setState(() {
      if (time == null) {
        _deadline = DateTime(date.year, date.month, date.day, _deadline.hour, _deadline.minute);
      } else {
        _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final editing = widget.initialTask != null;
    try {
      final base = widget.initialTask;
      final task = Task(
        id: editing ? base!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        status: _status,
        deadline: _deadline,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (editing) {
        await context.read<TaskCubit>().updateTask(task);
      } else {
        await context.read<TaskCubit>().addTask(task);
      }
      await context.read<TaskCubit>().loadTasks(); // added
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.initialTask == null) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: app_colors.red1),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    setState(() => _deleting = true);
    try {
      await context.read<TaskCubit>().deleteTask(widget.initialTask!.id);
      await context.read<TaskCubit>().loadTasks(); // added
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final t = widget.initialTask;
    if (t != null) {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _deadline = t.deadline;
      _status = t.status;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitting = context.watch<TaskCubit>().state is TaskSubmitting;
    final disabled = _saving || submitting || _deleting;
    final isEditing = widget.initialTask != null;
    // removed local fieldBorder/focusedBorder/label styles (moved into reusable widget)
    return Material(
      color: app_colors.white,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 5,
                  // margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(3)),
                ),
                Row(
                  children: [
                    Expanded(child: Text(isEditing ? 'Edit Task' : 'Add Task', style: theme.textTheme.titleLarge)),
                    if (isEditing)
                      ElevatedButton(
                        onPressed: disabled ? null : _delete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: app_colors.red1,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: _deleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Delete Task', style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                BlueTextFormField(
                  controller: _titleCtrl,
                  label: 'Title',
                  enabled: !disabled,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                BlueTextFormField(
                  controller: _descCtrl,
                  label: 'Description (optional)',
                  enabled: !disabled,
                  maxLines: 1,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: disabled ? null : _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Deadline'),
                          child: Text(
                            '${_deadline.year}-${_deadline.month.toString().padLeft(2, '0')}-${_deadline.day.toString().padLeft(2, '0')} '
                            '${_deadline.hour.toString().padLeft(2, '0')}:${_deadline.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: app_colors.gray2),
                        onPressed: disabled ? null : () => Navigator.of(context).maybePop(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEditing ? app_colors.orange1 : app_colors.blue1,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: disabled ? null : _save,
                        child: disabled
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(isEditing ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
