import 'package:task_mobile/features/tasks/models/task_model.dart';

class KeyPointModel {
  final int id;
  final String content;

  KeyPointModel({required this.id, required this.content});

  factory KeyPointModel.fromJson(Map<String, dynamic> json) {
    return KeyPointModel(
      id: json['id'] as int,
      content: json['content'] as String,
    );
  }
}

class DecisionModel {
  final int id;
  final String content;

  DecisionModel({required this.id, required this.content});

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    return DecisionModel(
      id: json['id'] as int,
      content: json['content'] as String,
    );
  }
}

class MeetingModel {
  final int id;
  final int userId;
  final String title;
  final String? fileUrl;
  final String? transcript;
  final String? summary;
  final String processingStatus;
  final DateTime createdAt;
  final DateTime? processedAt;
  final List<KeyPointModel> keyPoints;
  final List<DecisionModel> decisions;
  final List<TaskModel> tasks;

  MeetingModel({
    required this.id,
    required this.userId,
    required this.title,
    this.fileUrl,
    this.transcript,
    this.summary,
    required this.processingStatus,
    required this.createdAt,
    this.processedAt,
    this.keyPoints = const [],
    this.decisions = const [],
    this.tasks = const [],
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      fileUrl: json['file_url'] as String?,
      transcript: json['transcript'] as String?,
      summary: json['summary'] as String?,
      processingStatus: json['processing_status'] as String? ?? 'Pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at'] as String) : null,
      keyPoints: (json['key_points'] as List<dynamic>?)
              ?.map((e) => KeyPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      decisions: (json['decisions'] as List<dynamic>?)
              ?.map((e) => DecisionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DashboardStatsModel {
  final int totalMeetings;
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;
  final int overdueTasks;
  final List<TaskModel> upcomingTasks;
  final List<MeetingModel> recentMeetings;

  DashboardStatsModel({
    required this.totalMeetings,
    required this.totalTasks,
    required this.pendingTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.upcomingTasks,
    required this.recentMeetings,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalMeetings: json['total_meetings'] as int,
      totalTasks: json['total_tasks'] as int,
      pendingTasks: json['pending_tasks'] as int,
      completedTasks: json['completed_tasks'] as int,
      overdueTasks: json['overdue_tasks'] as int,
      upcomingTasks: (json['upcoming_tasks'] as List<dynamic>)
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentMeetings: (json['recent_meetings'] as List<dynamic>)
          .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
