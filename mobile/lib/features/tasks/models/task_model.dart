class TaskModel {
  final int id;
  final int meetingId;
  final String title;
  final String? description;
  final int? assigneeId;
  final String? assigneeName;
  final String? assigneePhotoUrl;
  final DateTime? dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.meetingId,
    required this.title,
    this.description,
    this.assigneeId,
    this.assigneeName,
    this.assigneePhotoUrl,
    this.dueDate,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  String get displayStatus {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    return 'Pending';
  }

  String get dueStatusText {
    if (isCompleted) {
      if (completedAt != null) {
        return 'Done on ${completedAt!.toIso8601String().split('T')[0]}';
      }
      return 'Completed';
    }
    if (dueDate == null) return 'No deadline';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final diff = due.difference(today).inDays;

    if (diff < 0) {
      return 'Overdue by ${diff.abs()} ${diff.abs() == 1 ? "day" : "days"}';
    } else if (diff == 0) {
      return 'Due today';
    } else if (diff == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $diff days';
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      meetingId: json['meeting_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      assigneeId: json['assignee_id'] as int?,
      assigneeName: json['assignee_name'] as String?,
      assigneePhotoUrl: json['assignee_photo_url'] as String?,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      status: json['status'] as String? ?? 'Pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'title': title,
      'description': description,
      'assignee_id': assigneeId,
      'assignee_name': assigneeName,
      'assignee_photo_url': assigneePhotoUrl,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
