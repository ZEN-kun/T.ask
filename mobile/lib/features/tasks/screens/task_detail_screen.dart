import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';
import 'package:task_mobile/features/tasks/models/task_model.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  TaskModel? _task;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchTask();
  }

  Future<void> _fetchTask() async {
    try {
      final firestore = ref.read(firestoreProvider);
      final doc = await firestore.collection('tasks').doc(widget.taskId.toString()).get();
      if (doc.exists) {
        final data = doc.data()!;
        final dueStr = data['due_date']?.toString();
        DateTime? dueDate;
        if (dueStr != null && dueStr.isNotEmpty) {
          dueDate = DateTime.tryParse(dueStr);
        }

        if (mounted) {
          setState(() {
            _task = TaskModel(
              id: int.tryParse(doc.id) ?? widget.taskId,
              meetingId: int.tryParse(data['meeting_id']?.toString() ?? '1') ?? 1,
              title: data['title'] ?? 'Action Item',
              description: data['description'],
              assigneeId: data['assignee_id'] != null ? int.tryParse(data['assignee_id'].toString()) : null,
              assigneeName: data['assignee_name'],
              assigneePhotoUrl: data['assignee_photo_url'],
              dueDate: dueDate,
              status: data['status'] ?? 'Pending',
              createdAt: data['created_at'] != null 
                  ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
                  : DateTime.now(),
              completedAt: data['completed_at'] != null
                  ? DateTime.tryParse(data['completed_at'].toString())
                  : null,
            );
            _isLoading = false;
          });
          return;
        }
      }

      // Fallback to SQLite API
      final tasks = await ref.read(apiServiceProvider).getTasks();
      final found = tasks.firstWhere((t) => t.id == widget.taskId);
      if (mounted) {
        setState(() {
          _task = found;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleStatus() async {
    if (_task == null) return;
    final newStatus = _task!.isCompleted ? 'Pending' : 'Completed';

    setState(() => _isUpdating = true);
    try {
      // 1. Update SQLite API
      try {
        await ref.read(apiServiceProvider).updateTaskStatus(widget.taskId, newStatus);
      } catch (_) {}

      // 2. Update Firestore
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('tasks').doc(widget.taskId.toString()).update({
        'status': newStatus,
        'completed_at': newStatus == 'Completed' ? DateTime.now().toIso8601String() : null,
      });

      if (mounted) {
        setState(() {
          _task = TaskModel(
            id: _task!.id,
            meetingId: _task!.meetingId,
            title: _task!.title,
            description: _task!.description,
            assigneeId: _task!.assigneeId,
            assigneeName: _task!.assigneeName,
            assigneePhotoUrl: _task!.assigneePhotoUrl,
            dueDate: _task!.dueDate,
            status: newStatus,
            createdAt: _task!.createdAt,
            completedAt: newStatus == 'Completed' ? DateTime.now() : null,
          );
          _isUpdating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete Task #${widget.taskId}? This will remove it from the system.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      // 1. Delete from SQLite API
      try {
        await ref.read(apiServiceProvider).deleteTask(widget.taskId);
      } catch (_) {}

      // 2. Delete from Cloud Firestore
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('tasks').doc(widget.taskId.toString()).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            content: Text('Task #${widget.taskId} deleted successfully.'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Failed to delete task: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final isManager = currentUser?.isManager ?? false;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found')),
      );
    }

    final task = _task!;
    final statusColor = task.isCompleted
        ? AppTheme.statusCompletedTextColor(context)
        : (task.isOverdue ? AppTheme.statusOverdueTextColor(context) : AppTheme.statusPendingTextColor(context));

    final statusBg = task.isCompleted
        ? AppTheme.statusCompletedBackground(context)
        : (task.isOverdue ? AppTheme.statusOverdueBackground(context) : AppTheme.statusPendingBackground(context));

    return GlossyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Task #${task.id}',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
          actions: [
            if (isManager)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppTheme.statusOverdueTextColor(context)),
                tooltip: 'Delete Task',
                onPressed: _isDeleting ? null : _confirmDeleteTask,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge & Title Card (Frosted Glass)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: task.isOverdue && !task.isCompleted
                        ? AppTheme.overdueBorderColor(context)
                        : AppTheme.cardBorder(context),
                    width: 1.0,
                  ),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.displayStatus.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary(context),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary(context),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Metadata 2-Column Grid Card (Frosted Glass)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.cardBorder(context), width: 1.0),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildMetaItem(Icons.person_outline_rounded, 'Assignee', task.assigneeName ?? 'Unassigned')),
                        Expanded(child: _buildMetaItem(Icons.calendar_today_outlined, 'Due Date', task.dueDate?.toIso8601String().split('T')[0] ?? 'None', textColor: statusColor)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: AppTheme.cardBorder(context)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildMetaItem(Icons.history_rounded, 'Created', task.createdAt.toIso8601String().split('T')[0])),
                        if (task.completedAt != null)
                          Expanded(child: _buildMetaItem(Icons.check_circle_outline_rounded, 'Completed', task.completedAt!.toIso8601String().split('T')[0], textColor: AppTheme.statusCompletedTextColor(context))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Source Meeting Interactive Card (Frosted Tint)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.recessedSurface(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder(context), width: 1.0),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.accentTint(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.mic_rounded, color: AppTheme.accentBlue(context), size: 20),
                  ),
                  title: Text(
                    'Source Meeting',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    'Meeting #${task.meetingId}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.accentBlue(context)),
                  onTap: () => context.push('/meetings/${task.meetingId}'),
                ),
              ),
              const SizedBox(height: 28),

              // Primary Toggle Button (FinovAi Pill Style)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(task.isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded, size: 18),
                  label: Text(task.isCompleted ? 'Mark as Pending' : 'Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: task.isCompleted
                        ? AppTheme.recessedSurface(context)
                        : AppTheme.ctaBackground(context),
                    foregroundColor: task.isCompleted
                        ? AppTheme.textSecondary(context)
                        : AppTheme.ctaForeground(context),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 0,
                  ),
                  onPressed: _isUpdating || _isDeleting ? null : _toggleStatus,
                ),
              ),
              const SizedBox(height: 12),

              // Delete Task Button at bottom for manager
              if (isManager) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete_outline_rounded, color: AppTheme.statusOverdueTextColor(context), size: 18),
                    label: Text(
                      'Delete This Task',
                      style: TextStyle(color: AppTheme.statusOverdueTextColor(context), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.overdueBorderColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: _isDeleting ? null : _confirmDeleteTask,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value, {Color? textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
