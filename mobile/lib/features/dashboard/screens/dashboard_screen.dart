import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/core/widgets/floating_bottom_nav_bar.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';
import 'package:task_mobile/features/dashboard/providers/dashboard_firestore_provider.dart';
import 'package:task_mobile/features/meetings/models/meeting_model.dart';
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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    // Direct Real-Time Streams from Cloud Firestore
    final tasksAsync = ref.watch(firestoreTasksProvider);
    final meetingsAsync = ref.watch(firestoreMeetingsProvider);

    return GlossyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('Error loading Firestore data: $err', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          data: (allTasks) {
            // Compute Real-Time Statistics
            final totalTasks = allTasks.length;
            final pendingTasks = allTasks.where((t) => !t.isCompleted && !t.isOverdue).length;
            final completedTasks = allTasks.where((t) => t.isCompleted).length;
            final overdueTasks = allTasks.where((t) => t.isOverdue).length;

            final upcomingTasks = allTasks
                .where((t) => !t.isCompleted)
                .take(5)
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Executive Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Brand Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 14),
                      // Greeting & Role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user?.name ?? 'User',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary(context),
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentTint(context),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    (user?.role ?? 'User').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentBlue(context),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // User Profile Avatar with Ring
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => context.push('/profile'),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.accentBlue(context).withValues(alpha: 0.3), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.accentBlue(context),
                            backgroundImage: _resolveAvatar(user?.photoUrl),
                            child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                                ? Text(
                                    user?.name.isNotEmpty ?? false ? user!.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KPI 2x2 Metric Grid (FinovAi Style)
                  Row(
                    children: [
                      _buildMetricCard(
                        context: context,
                        title: 'Total Tasks',
                        value: totalTasks.toString(),
                        indicatorColor: AppTheme.accentBlue(context),
                        icon: Icons.checklist_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        context: context,
                        title: 'Pending',
                        value: pendingTasks.toString(),
                        indicatorColor: AppTheme.statusPendingTextColor(context),
                        icon: Icons.hourglass_top_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricCard(
                        context: context,
                        title: 'Completed',
                        value: completedTasks.toString(),
                        indicatorColor: AppTheme.statusCompletedTextColor(context),
                        icon: Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        context: context,
                        title: 'Overdue',
                        value: overdueTasks.toString(),
                        indicatorColor: AppTheme.statusOverdueTextColor(context),
                        icon: Icons.alarm_on_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Manager Primary CTA: "Process New Meeting"
                  if (user?.isManager ?? true) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/meetings/create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ctaBackground(context),
                          foregroundColor: AppTheme.ctaForeground(context),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mic_rounded, color: AppTheme.brandGold, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Process New Meeting',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ctaForeground(context),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('✦', style: TextStyle(color: AppTheme.brandGold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Upcoming Tasks Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Tasks',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/tasks'),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.accentBlue(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (upcomingTasks.isEmpty)
                    _buildEmptyState(context, 'No upcoming tasks pending. Great job!')
                  else
                    ...upcomingTasks.map((t) => _buildExecutiveTaskTile(context, t)),

                  const SizedBox(height: 24),

                  // Recent Meetings Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Meetings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/meetings'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.brandBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  meetingsAsync.when(
                    loading: () => const Center(
                      child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (e, _) => Text('Error loading meetings: $e'),
                    data: (meetings) {
                      if (meetings.isEmpty) {
                        return _buildEmptyState(context, 'No meetings recorded yet');
                      }
                      return Column(
                        children: meetings.take(5).map((m) => _buildExecutiveMeetingTile(context, m)).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 0),
    ),
  );
}

Widget _buildMetricCard({
  required BuildContext context,
  required String title,
  required String value,
  required Color indicatorColor,
  required IconData icon,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withValues(alpha: 0.22)
                : const Color(0xFF3E679B).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(icon, size: 17, color: AppTheme.textSecondary(context).withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: indicatorColor == AppTheme.statusOverdueTextColor(context)
                  ? indicatorColor
                  : AppTheme.textPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEmptyState(BuildContext context, String text) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    decoration: BoxDecoration(
      color: AppTheme.cardBg(context),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
      boxShadow: [
        BoxShadow(
          color: AppTheme.isDark(context)
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFF3E679B).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Center(
      child: Text(text, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13.5)),
    ),
  );
}

Widget _buildExecutiveTaskTile(BuildContext context, TaskModel task) {
  final statusBg = task.isCompleted
      ? AppTheme.statusCompletedBackground(context)
      : (task.isOverdue ? AppTheme.statusOverdueBackground(context) : AppTheme.statusPendingBackground(context));
  final statusColor = task.isCompleted
      ? AppTheme.statusCompletedTextColor(context)
      : (task.isOverdue ? AppTheme.statusOverdueTextColor(context) : AppTheme.statusPendingTextColor(context));

  final isOverdue = task.isOverdue && !task.isCompleted;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppTheme.cardBg(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isOverdue ? AppTheme.overdueBorderColor(context) : AppTheme.cardBorder(context),
        width: isOverdue ? 1.3 : 1.1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.isDark(context)
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFF3E679B).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.recessedSurface(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          task.isCompleted ? Icons.check_circle_rounded : Icons.assignment_outlined,
          color: AppTheme.accentBlue(context),
          size: 20,
        ),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppTheme.textPrimary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${task.assigneeName ?? 'Unassigned'} • Due ${task.dueDate?.toIso8601String().split('T')[0] ?? 'None'}',
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
      onTap: () => context.push('/tasks/${task.id}'),
    ),
  );
}

Widget _buildExecutiveMeetingTile(BuildContext context, MeetingModel meeting) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppTheme.cardBg(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
      boxShadow: [
        BoxShadow(
          color: AppTheme.isDark(context)
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFF3E679B).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.recessedSurface(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.mic_rounded, color: AppTheme.accentBlue(context), size: 20),
      ),
      title: Text(
        meeting.title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppTheme.textPrimary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${meeting.processingStatus} • ${meeting.createdAt.toIso8601String().split('T')[0]}',
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
      ),
      trailing: Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary(context)),
      onTap: () => context.push('/meetings/${meeting.id}'),
    ),
  );
}
}
