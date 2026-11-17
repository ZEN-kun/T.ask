import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';
import 'package:task_mobile/features/meetings/models/meeting_model.dart';
import 'package:task_mobile/features/tasks/models/task_model.dart';

// Live stream of all meetings for the current user/company from Cloud Firestore
final firestoreMeetingsProvider = StreamProvider<List<MeetingModel>>((ref) {
  final authState = ref.watch(authProvider);
  final firestore = ref.watch(firestoreProvider);
  final user = authState.user;

  if (user == null) return const Stream.empty();

  Query query = firestore.collection('meetings');

  if (user.isManager) {
    query = query.where('creator_id', isEqualTo: user.uid);
  } else {
    // Employee sees meetings belonging to their manager/company
    if (user.managerId != null) {
      query = query.where('creator_id', isEqualTo: user.managerId);
    }
  }

  return query.snapshots().map((snapshot) {
    final meetings = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MeetingModel(
        id: int.tryParse(doc.id) ?? (doc.id.hashCode & 0x7FFFFFFF),
        userId: int.tryParse(user.uid) ?? 1,
        title: data['title'] ?? 'Untitled Meeting',
        fileUrl: data['file_url'],
        transcript: data['transcript'],
        summary: data['summary'],
        processingStatus: data['processing_status'] ?? 'Completed',
        createdAt: data['created_at'] != null 
            ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        keyPoints: (data['key_points'] as List<dynamic>?)
                ?.map((e) => KeyPointModel(id: 0, content: e.toString()))
                .toList() ?? [],
        decisions: (data['decisions'] as List<dynamic>?)
                ?.map((e) => DecisionModel(id: 0, content: e.toString()))
                .toList() ?? [],
      );
    }).toList();
    // Sort in-memory to avoid requiring Firestore composite indexes
    meetings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return meetings;
  });
});

// Live stream of all tasks with strict privacy:
// Managers see all team tasks; Employees see ONLY their own assigned tasks.
final firestoreTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final authState = ref.watch(authProvider);
  final firestore = ref.watch(firestoreProvider);
  final user = authState.user;

  if (user == null) return const Stream.empty();

  Query query = firestore.collection('tasks');

  if (user.isManager) {
    query = query.where('manager_id', isEqualTo: user.uid);
  } else {
    // Employee sees only their manager's tasks, filtered strictly in-memory
    if (user.managerId != null) {
      query = query.where('manager_id', isEqualTo: user.managerId);
    }
  }

  return query.snapshots().map((snapshot) {
    final allTasks = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final dueStr = data['due_date']?.toString();
      DateTime? dueDate;
      if (dueStr != null && dueStr.isNotEmpty) {
        dueDate = DateTime.tryParse(dueStr);
      }

      return TaskModel(
        id: int.tryParse(doc.id) ?? (doc.id.hashCode & 0x7FFFFFFF),
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
    }).toList();

    // Strict Employee Isolation:
    // If not a manager, filter so the employee ONLY sees tasks assigned to them
    List<TaskModel> visibleTasks;
    if (user.isManager) {
      visibleTasks = allTasks;
    } else {
      final userLower = user.name.toLowerCase().trim();
      visibleTasks = allTasks.where((t) {
        final taskName = (t.assigneeName ?? '').toLowerCase().trim();
        return taskName.isNotEmpty && (taskName.contains(userLower) || userLower.contains(taskName));
      }).toList();
    }

    // Sort Urgency Order:
    // 1. Overdue tasks first (most urgent)
    // 2. Upcoming Pending tasks (nearest due date first)
    // 3. No deadline tasks
    // 4. Completed tasks last
    visibleTasks.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      if (a.isCompleted && b.isCompleted) {
        return (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt);
      }

      // Both pending / overdue
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      // If both overdue or both pending, sort closest deadline first
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;

      return b.createdAt.compareTo(a.createdAt);
    });

    return visibleTasks;
  });
});
