import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/core/widgets/floating_bottom_nav_bar.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';
import 'package:task_mobile/features/dashboard/providers/dashboard_firestore_provider.dart';
import 'package:task_mobile/features/tasks/models/task_model.dart';

ImageProvider? _resolveAvatar(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('data:image')) {
    try {
      final comma = photoUrl.indexOf(',');
      if (comma != -1) {
        return MemoryImage(base64Decode(photoUrl.substring(comma + 1)));
      }
    } catch (_) {}
  }
  return NetworkImage(photoUrl);
}

final taskFilterProvider = StateProvider.autoDispose<String>((ref) => 'All');
final taskSearchProvider = StateProvider.autoDispose<String>((ref) => '');

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(firestoreTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final searchQuery = ref.watch(taskSearchProvider).toLowerCase().trim();
    final user = ref.watch(authProvider).user;

    return GlossyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasks Register',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Action items & urgency tracking',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)),
                        ),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => context.push('/profile'),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentBlue(context).withValues(alpha: 0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.accentBlue(context),
                          backgroundImage: _resolveAvatar(user?.photoUrl),
                          child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                              ? Text(
                                  user?.name.isNotEmpty ?? false ? user!.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar (Frosted Glass)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.isDark(context)
                            ? Colors.black.withValues(alpha: 0.2)
                            : const Color(0xFF3E679B).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => ref.read(taskSearchProvider.notifier).state = val,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      hintText: 'Search tasks by title or assignee...',
                      hintStyle: TextStyle(color: AppTheme.textTertiary(context), fontSize: 13.5),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppTheme.textSecondary(context)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

            // Filter Tabs Row
            tasksAsync.maybeWhen(
              data: (allTasks) {
                final overdueCount = allTasks.where((t) => t.isOverdue).length;
                final pendingCount = allTasks.where((t) => !t.isCompleted && !t.isOverdue).length;
                final completedCount = allTasks.where((t) => t.isCompleted).length;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _buildFilterChip(context, ref, 'All (${allTasks.length})', 'All', currentFilter == 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, ref, 'Overdue ($overdueCount)', 'Overdue', currentFilter == 'Overdue'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, ref, 'Pending ($pendingCount)', 'Pending', currentFilter == 'Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, ref, 'Completed ($completedCount)', 'Completed', currentFilter == 'Completed'),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),

            // Tasks List
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.brandBlue),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      Text('Error loading tasks: $err', style: const TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(firestoreTasksProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (allTasks) {
                  // Filter by Search & Status Filter
                  final filteredTasks = allTasks.where((task) {
                    final matchesSearch = task.title.toLowerCase().contains(searchQuery) ||
                        (task.assigneeName?.toLowerCase().contains(searchQuery) ?? false);
                    if (!matchesSearch) return false;

                    if (currentFilter == 'Overdue') return task.isOverdue;
                    if (currentFilter == 'Pending') return !task.isCompleted && !task.isOverdue;
                    if (currentFilter == 'Completed') return task.isCompleted;
                    return true;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: AppTheme.brandTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.checklist_rounded, size: 40, color: AppTheme.brandBlue),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tasks found',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tasks extracted from meetings will appear here sorted by due date.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskRowCard(context, task);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 1),
    ),
  );
}

Widget _buildFilterChip(BuildContext context, WidgetRef ref, String label, String filterKey, bool isSelected) {
  final isDark = AppTheme.isDark(context);
  final activeBg = AppTheme.selectedPillBg(context);
  final activeBorder = AppTheme.selectedPillBorder(context);
  final activeColor = AppTheme.selectedPillText(context);
  final inactiveBg = AppTheme.cardBg(context);
  final inactiveBorder = AppTheme.cardBorder(context);
  final inactiveColor = AppTheme.textSecondary(context);

  return InkWell(
    borderRadius: BorderRadius.circular(999),
    onTap: () => ref.read(taskFilterProvider.notifier).state = filterKey,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected ? activeBorder : inactiveBorder,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.black.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0xFF3E679B).withValues(alpha: 0.04)),
            blurRadius: isSelected ? 8 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: isSelected ? activeColor : inactiveColor,
        ),
      ),
    ),
  );
}

Widget _buildTaskRowCard(BuildContext context, TaskModel task) {
  final statusBg = task.isCompleted
      ? AppTheme.statusCompletedBackground(context)
      : (task.isOverdue ? AppTheme.statusOverdueBackground(context) : AppTheme.statusPendingBackground(context));
  final statusColor = task.isCompleted
      ? AppTheme.statusCompletedTextColor(context)
      : (task.isOverdue ? AppTheme.statusOverdueTextColor(context) : AppTheme.statusPendingTextColor(context));

  final isOverdue = task.isOverdue && !task.isCompleted;
  final isDark = AppTheme.isDark(context);

  return Container(
    decoration: BoxDecoration(
      color: AppTheme.cardBg(context),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isOverdue ? AppTheme.overdueBorderColor(context) : AppTheme.cardBorder(context),
        width: isOverdue ? 1.3 : 1.1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF3E679B).withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/tasks/${task.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Task ID + Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTint(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${task.id}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppTheme.accentBlue(context),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.displayStatus.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              task.title,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            Divider(height: 1, color: AppTheme.solidCardBorder(context)),
            const SizedBox(height: 10),

            // Bottom Metadata Row: Assignee Avatar + Name + Due Date
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.accentTint(context),
                  backgroundImage: _resolveAvatar(task.assigneePhotoUrl),
                  child: (task.assigneePhotoUrl == null || task.assigneePhotoUrl!.isEmpty)
                      ? Text(
                          task.assigneeName?.isNotEmpty ?? false ? task.assigneeName![0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.accentBlue(context)),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  task.assigneeName ?? 'Unassigned',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600),
                ),
                const Spacer(),

                Icon(
                  task.isOverdue ? Icons.alarm_on_rounded : Icons.calendar_today_outlined,
                  size: 13,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  task.dueStatusText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
