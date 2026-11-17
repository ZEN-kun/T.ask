import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';
import 'package:task_mobile/features/meetings/models/meeting_model.dart';
import 'package:task_mobile/features/tasks/models/task_model.dart';

final meetingDetailProvider = FutureProvider.family.autoDispose<MeetingModel, int>((ref, meetingId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMeetingDetails(meetingId);
});

class MeetingDetailScreen extends ConsumerStatefulWidget {
  final int meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen> {
  bool _isTranscriptExpanded = false;

  Future<void> _confirmDeleteMeeting(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Meeting?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
        ),
        content: const Text(
          'Are you sure you want to delete this meeting? All associated action items, decisions, and transcripts will be permanently removed. Remaining task IDs will be automatically re-sequenced.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusOverdueText,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final api = ref.read(apiServiceProvider);
        await api.deleteMeeting(widget.meetingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meeting deleted and task IDs re-sequenced.'),
              backgroundColor: AppTheme.brandDark,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete meeting: $e'),
              backgroundColor: AppTheme.statusOverdueText,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingAsync = ref.watch(meetingDetailProvider(widget.meetingId));

    return GlossyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Meeting Overview',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: AppTheme.statusOverdueTextColor(context)),
              tooltip: 'Delete Meeting',
              onPressed: () => _confirmDeleteMeeting(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: meetingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.brandBlue),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.textMuted),
                const SizedBox(height: 12),
                const Text('Could not load meeting details', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => ref.invalidate(meetingDetailProvider(widget.meetingId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (meeting) {
          final isDark = AppTheme.isDark(context);
          final isCompleted = meeting.processingStatus.toLowerCase() == 'completed';
          final statusBg = isCompleted
              ? AppTheme.statusCompletedBackground(context)
              : AppTheme.statusPendingBackground(context);
          final statusColor = isCompleted
              ? AppTheme.statusCompletedTextColor(context)
              : AppTheme.statusPendingTextColor(context);

          final heroGradient = isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF192231), // Dark Slate Blue undertone
                    Color(0xFF22201B), // Dark Warm Butter Gold undertone
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEDF3FA), // Brand Tint Blue
                    Color(0xFFFDF8EA), // Warm Pastel Gold
                  ],
                );

          final heroBorder = isDark ? const Color(0xFF2B3445) : AppTheme.border;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: heroGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: heroBorder),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              meeting.processingStatus.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Text(
                            meeting.createdAt.toIso8601String().split('T')[0],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        meeting.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Quick Metric Badges Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildHeroBadge(context, Icons.task_alt_rounded, '${meeting.tasks.length} Tasks', AppTheme.accentBlue(context)),
                          _buildHeroBadge(context, Icons.fact_check_outlined, '${meeting.decisions.length} Decisions', isDark ? const Color(0xFF5CD699) : const Color(0xFF1F7A4C)),
                          _buildHeroBadge(context, Icons.lightbulb_outline_rounded, '${meeting.keyPoints.length} Key Points', isDark ? const Color(0xFFFBE094) : const Color(0xFF9A7414)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Executive AI Summary Card
                if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
                  _buildSectionCard(
                    context: context,
                    title: 'Executive AI Summary',
                    icon: Icons.auto_awesome_rounded,
                    iconColor: AppTheme.brandGold,
                    child: Text(
                      meeting.summary!,
                      style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary(context), height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 2. Decisions Agreed Card
                if (meeting.decisions.isNotEmpty) ...[
                  _buildSectionCard(
                    context: context,
                    title: 'Decisions Agreed (${meeting.decisions.length})',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: isDark ? const Color(0xFF5CD699) : const Color(0xFF1F7A4C),
                    child: Column(
                      children: meeting.decisions.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_rounded, size: 16, color: isDark ? const Color(0xFF5CD699) : const Color(0xFF1F7A4C)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.content,
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. Extracted Tasks Card
                if (meeting.tasks.isNotEmpty) ...[
                  _buildSectionCard(
                    context: context,
                    title: 'Extracted Tasks (${meeting.tasks.length})',
                    icon: Icons.checklist_rounded,
                    iconColor: AppTheme.accentBlue(context),
                    child: Column(
                      children: meeting.tasks.map((task) => _buildExecutiveTaskTile(context, task)).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Key Discussion Points Card
                if (meeting.keyPoints.isNotEmpty) ...[
                  _buildSectionCard(
                    context: context,
                    title: 'Key Discussion Points',
                    icon: Icons.format_list_bulleted_rounded,
                    iconColor: AppTheme.accentBlue(context),
                    child: Column(
                      children: meeting.keyPoints.map((kp) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                kp.content,
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Collapsible Original Transcript Card (Refined Chat Thread Style)
                if (meeting.transcript != null && meeting.transcript!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF3E679B).withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => setState(() => _isTranscriptExpanded = !_isTranscriptExpanded),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentTint(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppTheme.accentBlue(context)),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Meeting Transcript',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  _isTranscriptExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isTranscriptExpanded) ...[
                          Divider(height: 1, color: AppTheme.solidCardBorder(context)),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: _buildChatTranscript(context, meeting.transcript!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildHeroBadge(BuildContext context, IconData icon, String text, Color color) {
  final isDark = AppTheme.isDark(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E2430) : Colors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isDark ? const Color(0xFF2C3545) : Colors.white, width: 1.1),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF3E679B).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    ),
  );
}

Widget _buildSectionCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Color iconColor,
  required Widget child,
}) {
  final isDark = AppTheme.isDark(context);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppTheme.cardBg(context),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF3E679B).withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
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

  final isDark = AppTheme.isDark(context);

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkRecessed : Colors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppTheme.darkRecessedBorder : Colors.white, width: 1.1),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF3E679B).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: () => context.push('/tasks/${task.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textPrimary(context)),
                ),
                const SizedBox(height: 3),
                Text(
                  'Assignee: ${task.assigneeName ?? "Unassigned"} • Due: ${task.dueDate?.toIso8601String().split('T')[0] ?? "None"}',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary(context)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.displayStatus.toUpperCase(),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildChatTranscript(BuildContext context, String transcript) {
  final isDark = AppTheme.isDark(context);
  final lines = transcript.split('\n').where((l) => l.trim().isNotEmpty).toList();

  return Column(
    children: lines.map((line) {
      final colonIdx = line.indexOf(':');
      final hasSpeaker = colonIdx != -1 && colonIdx < 30;
      final speaker = hasSpeaker ? line.substring(0, colonIdx).trim() : '';
      final speech = hasSpeaker ? line.substring(colonIdx + 1).trim() : line.trim();

      final initial = speaker.isNotEmpty ? speaker[0].toUpperCase() : '•';
      final isManager = speaker.toLowerCase().contains('manager');

      // Dark Mode chat bubble styling
      final bubbleBg = isDark
          ? (isManager ? const Color(0xFF1D2533) : const Color(0xFF1A1E26))
          : AppTheme.canvasBg;
      final bubbleBorder = isDark
          ? (isManager ? const Color(0xFF2B3545) : const Color(0xFF262C38))
          : AppTheme.border;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isManager
                  ? (isDark ? const Color(0xFF5D8CC7) : AppTheme.brandDark)
                  : AppTheme.accentTint(context),
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isManager
                      ? (isDark ? const Color(0xFF111318) : Colors.white)
                      : AppTheme.accentBlue(context),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: bubbleBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bubbleBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (speaker.isNotEmpty) ...[
                      Text(
                        speaker,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentBlue(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      speech,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
}
