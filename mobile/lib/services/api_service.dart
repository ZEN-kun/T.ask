import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:task_mobile/core/network/api_client.dart';
import 'package:task_mobile/features/auth/models/user_model.dart';
import 'package:task_mobile/features/meetings/models/meeting_model.dart';
import 'package:task_mobile/features/tasks/models/task_model.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  Dio get _dio => _client.dio;

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Dashboard
  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await _dio.get('/meetings/dashboard/stats');
    return DashboardStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Meetings
  Future<List<MeetingModel>> getMeetings() async {
    final response = await _dio.get('/meetings');
    final list = response.data as List<dynamic>;
    return list.map((e) => MeetingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MeetingModel> getMeetingDetails(int id) async {
    final response = await _dio.get('/meetings/$id');
    return MeetingModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteMeeting(int id) async {
    await _dio.delete('/meetings/$id');
  }

  Future<MeetingModel> createMeeting({
    required String title,
    String? transcript,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final rawMap = <String, dynamic>{
      'title': title,
      if (transcript != null && transcript.isNotEmpty) 'transcript': transcript,
      if (fileBytes != null && fileName != null)
        'audio_file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    };
    final formData = FormData.fromMap(rawMap);
    final response = await _dio.post(
      '/meetings',
      data: formData,
      options: Options(extra: {
        'raw_form_map': {
          'title': title,
          if (transcript != null && transcript.isNotEmpty) 'transcript': transcript,
          if (fileBytes != null && fileName != null)
            'audio_file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        }
      }),
    );
    return MeetingModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MeetingModel> processMeeting(
    int id, {
    List<Map<String, dynamic>>? attendees,
    String? managerPhone,
    String? managerName,
  }) async {
    final response = await _dio.post(
      '/meetings/$id/process',
      data: {
        ?attendees != null ? 'attendees': attendees : null,
        ?managerPhone != null ? 'manager_phone': managerPhone : null,
        ?managerName != null ? 'manager_name': managerName : null,
      }..removeWhere((k, v) => v == null),
    );
    return MeetingModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Tasks
  Future<List<TaskModel>> getTasks({String? status, int? meetingId}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (meetingId != null) queryParams['meeting_id'] = meetingId;

    final response = await _dio.get('/tasks', queryParameters: queryParams);
    final list = response.data as List<dynamic>;
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> updateTaskStatus(int id, String status) async {
    final response = await _dio.patch('/tasks/$id', data: {'status': status});
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    await _dio.delete('/tasks/$id');
  }
}
