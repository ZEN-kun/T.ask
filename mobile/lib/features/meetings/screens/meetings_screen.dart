import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/core/widgets/floating_bottom_nav_bar.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';
import 'package:task_mobile/features/meetings/models/meeting_model.dart';

final meetingsListProvider = FutureProvider.autoDispose<List<MeetingModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMeetings();
});

final meetingSearchProvider = StateProvider.autoDispose<String>((ref) => '');
final meetingFilterProvider = StateProvider.autoDispose<String>((ref) => 'All');

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  Future<void> _confirmDeleteMeeting(BuildContext context, WidgetRef ref, MeetingModel meeting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Meeting?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
        ),
        content: Text(
          "Are you sure you want to delete '${meeting.title}'? All associated action items and transcripts will be removed. Remaining task IDs will be automatically re-sequenced.",
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
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

    if (confirmed == true) {
      try {
        final api = ref.read(apiServiceProvider);
        await api.deleteMeeting(meeting.id);
        ref.invalidate(meetingsListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meeting deleted and task IDs re-sequenced.'),
              backgroundColor: AppTheme.brandDark,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsListProvider);
    final searchQuery = ref.watch(meetingSearchProvider).toLowerCase().trim();
    final currentFilter = ref.watch(meetingFilterProvider);

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
                        'Meetings',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Audio, video & transcript summaries',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)),
                      ),
                    ],
                  ),
                  // New Meeting Quick Action
                  ElevatedButton(
                    onPressed: () async {
                      await context.push('/meetings/create');
                      ref.invalidate(meetingsListProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ctaBackground(context),
                      foregroundColor: AppTheme.ctaForeground(context),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 16, color: AppTheme.brandGold),
                        const SizedBox(width: 4),
                        Text(
                          'New',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ctaForeground(context),
                          ),
                        ),
                      ],
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
                  onChanged: (v) => ref.read(meetingSearchProvider.notifier).state = v,
                  style: TextStyle(color: AppTheme.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Search meetings or transcripts...',
                    hintStyle: TextStyle(color: AppTheme.textTertiary(context), fontSize: 13.5),
                    prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary(context), size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Filter Tabs Row (Frosted Glass)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: ['All', 'Completed', 'Processing'].map((filter) {
                  final isSelected = currentFilter == filter;
                  final isDark = AppTheme.isDark(context);
                  final activeBg = AppTheme.selectedPillBg(context);
                  final activeBorder = AppTheme.selectedPillBorder(context);
                  final activeColor = AppTheme.selectedPillText(context);
                  final inactiveBg = AppTheme.cardBg(context);
                  final inactiveBorder = AppTheme.cardBorder(context);
                  final inactiveColor = AppTheme.textSecondary(context);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => ref.read(meetingFilterProvider.notifier).state = filter,
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
                                  : (isDark
                                      ? Colors.black.withValues(alpha: 0.15)
                                      : const Color(0xFF3E679B).withValues(alpha: 0.04)),
                              blurRadius: isSelected ? 8 : 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Meetings List Body
            Expanded(
              child: meetingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.brandBlue),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      const Text('Failed to load meetings', style: TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(meetingsListProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (allMeetings) {
                  // Filter by Search & Status
                  final filtered = allMeetings.where((m) {
                    final matchSearch = m.title.toLowerCase().contains(searchQuery) ||
                        (m.summary?.toLowerCase().contains(searchQuery) ?? false) ||
                        (m.transcript?.toLowerCase().contains(searchQuery) ?? false);
                    if (!matchSearch) return false;

                    if (currentFilter == 'Completed') return m.processingStatus.toLowerCase() == 'completed';
                    if (currentFilter == 'Processing') return m.processingStatus.toLowerCase() != 'completed';
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
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
                              child: const Icon(Icons.mic_none_rounded, size: 40, color: AppTheme.brandBlue),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No meetings found',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Record or upload a meeting recording to extract automated tasks.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(meetingsListProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final meeting = filtered[index];
                        final isCompleted = meeting.processingStatus.toLowerCase() == 'completed';
                        final statusBg = isCompleted
                            ? AppTheme.statusCompletedBackground(context)
                            : AppTheme.statusPendingBackground(context);
                        final statusColor = isCompleted
                            ? AppTheme.statusCompletedTextColor(context)
                            : AppTheme.statusPendingTextColor(context);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg(context),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.isDark(context)
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : const Color(0xFF3E679B).withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => context.push('/meetings/${meeting.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Icon + Title + Status Pill
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.recessedSurface(context),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          Icons.mic_rounded,
                                          color: AppTheme.accentBlue(context),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              meeting.title,
                                              style: TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary(context),
                                                letterSpacing: -0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              meeting.createdAt.toIso8601String().split('T')[0],
                                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          meeting.processingStatus.toUpperCase(),
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

                                  // Summary Preview
                                  if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      meeting.summary!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary(context),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 14),
                                  Divider(height: 1, color: AppTheme.solidCardBorder(context)),
                                  const SizedBox(height: 10),

                                  // Footer Row: Metadata Badges
                                  Row(
                                    children: [
                                      // Extracted Tasks Count Chip
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentTint(context),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.task_alt_rounded, size: 13, color: AppTheme.accentBlue(context)),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${meeting.tasks.length} Tasks',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.accentBlue(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (meeting.decisions.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.recessedSurface(context),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${meeting.decisions.length} Decisions',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textSecondary(context),
                                            ),
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.textSecondary(context)),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Delete Meeting',
                                        onPressed: () => _confirmDeleteMeeting(context, ref, meeting),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary(context)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 2),
    ),
  );
  }
}
