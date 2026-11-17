import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/core/utils/file_picker_helper.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/models/app_user.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';

// Stream of employees managed by the currently logged-in manager
final teamEmployeesStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final authState = ref.watch(authProvider);
  final firestore = ref.watch(firestoreProvider);
  final currentUserId = authState.user?.uid;

  if (currentUserId == null) return const Stream.empty();

  return firestore
      .collection('users')
      .where('role', isEqualTo: 'employee')
      .where('manager_id', isEqualTo: currentUserId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();
  });
});

class CreateMeetingScreen extends ConsumerStatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  ConsumerState<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends ConsumerState<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _transcriptController = TextEditingController();

  // Selected attendees set
  final Set<AppUser> _selectedAttendees = {};

  // Uploaded media (.mp4, .mp3, .wav, .m4a) or document (.txt, .doc, .docx)
  PickedMeetingFile? _pickedFile;

  bool _isProcessing = false;
  String _processingStep = '';

  @override
  void dispose() {
    _titleController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _handlePickFile() async {
    try {
      final picked = await pickMeetingFile();
      if (picked == null) return;

      setState(() {
        _pickedFile = picked;
        // If it's a plain .txt/.md file, also populate the text preview for convenience
        if (picked.extension == '.txt' || picked.extension == '.md') {
          try {
            final text = utf8.decode(picked.bytes, allowMalformed: true).trim();
            if (text.isNotEmpty && _transcriptController.text.trim().isEmpty) {
              _transcriptController.text = text;
            }
          } catch (_) {}
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not attach file: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null && _transcriptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Please upload a meeting file (.mp4, .mp3, .txt, .docx) or enter transcript text.'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingStep = _pickedFile != null
          ? 'Uploading ${_pickedFile!.name} & preparing attendees...'
          : 'Preparing meeting details & attendees...';
    });

    try {
      final api = ref.read(apiServiceProvider);

      // 1. Create meeting entry (with optional .mp4/.mp3/.wav/.txt/.doc/.docx file)
      setState(() {
        _processingStep = _pickedFile != null
            ? 'Uploading ${_pickedFile!.name}...'
            : 'Creating meeting record...';
      });

      final meeting = await api.createMeeting(
        title: _titleController.text.trim(),
        transcript: _transcriptController.text.trim(),
        fileBytes: _pickedFile?.bytes,
        fileName: _pickedFile?.name,
      );

      // 2. Process meeting with Model 1, 2, 3 & 4 (WhatsApp Dispatch)
      setState(() {
        _processingStep = _pickedFile != null && _pickedFile!.isVideoOrAudio
            ? 'Transcribing audio/video with Whisper ASR...'
            : 'Analyzing transcript & extracting tasks with AI...';
      });

      final currentUser = ref.read(authProvider).user;
      final teamList = ref.read(teamEmployeesStreamProvider).valueOrNull ?? [];
      final effectiveAttendees = _selectedAttendees.isNotEmpty ? _selectedAttendees.toList() : teamList;
      final allCandidates = <AppUser>[
        ...effectiveAttendees,
        ...?currentUser != null ? [currentUser] : null,
      ];

      final managerPhone = (currentUser?.phone != null && currentUser!.phone.trim().isNotEmpty)
          ? currentUser.phone.trim()
          : '917981929830';

      final processedMeeting = await api.processMeeting(
        meeting.id,
        attendees: effectiveAttendees
            .map((a) => {'name': a.name, 'phone': a.phone, 'uid': a.uid})
            .toList(),
        managerPhone: managerPhone,
        managerName: currentUser?.name ?? 'Mohammed Hifzan',
      );

      // 3. Sync to Cloud Firestore for real-time mobile dashboard & task tracking
      final currentUserId = currentUser?.uid;
      final firestore = ref.read(firestoreProvider);

      if (currentUserId != null) {
        setState(() {
          _processingStep = 'Syncing ${processedMeeting.tasks.length} tasks to Firestore & WhatsApp dispatched!';
        });

        await firestore.collection('meetings').doc(processedMeeting.id.toString()).set({
          'creator_id': currentUserId,
          'title': processedMeeting.title,
          'transcript': processedMeeting.transcript,
          'summary': processedMeeting.summary,
          'key_points': processedMeeting.keyPoints.map((k) => k.content).toList(),
          'decisions': processedMeeting.decisions.map((d) => d.content).toList(),
          'processing_status': 'Completed',
          'created_at': DateTime.now().toIso8601String(),
        });

        for (final task in processedMeeting.tasks) {
          AppUser? matchedAttendee;
          if (task.assigneeName != null && task.assigneeName!.isNotEmpty) {
            final targetName = task.assigneeName!.toLowerCase();
            for (final att in allCandidates) {
              final attLower = att.name.toLowerCase();
              if (attLower.contains(targetName) || targetName.contains(attLower)) {
                matchedAttendee = att;
                break;
              }
            }
          }

          await firestore.collection('tasks').doc(task.id.toString()).set({
            'meeting_id': processedMeeting.id,
            'manager_id': currentUserId,
            'title': task.title,
            'description': task.description,
            'assignee_name': matchedAttendee?.name ?? task.assigneeName ?? 'Unassigned',
            'assignee_id': matchedAttendee?.uid,
            'assignee_phone': matchedAttendee?.phone,
            'due_date': task.dueDate?.toIso8601String(),
            'status': task.status,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }

      setState(() {
        _processingStep = 'Completed!';
      });

      if (mounted) {
        context.pushReplacement('/meetings/${processedMeeting.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Failed to process meeting: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(teamEmployeesStreamProvider);

    return GlossyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'New Meeting',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meeting Title
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: AppTheme.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Meeting Title',
                  hintText: 'e.g. Sprint Planning, Backend Review',
                  prefixIcon: Icon(Icons.title_outlined, color: AppTheme.textSecondary(context)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),

              // ================= ATTENDEE SELECTOR CHIPS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Meeting Attendees',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  Text(
                    '${_selectedAttendees.length} selected',
                    style: TextStyle(fontSize: 12, color: AppTheme.accentBlue(context), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Selecting attendees helps the AI accurately bind tasks to Indian names.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
              ),
              const SizedBox(height: 10),

              employeesAsync.when(
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.accentBlue(context)),
                  ),
                ),
                error: (err, _) => Text('Error loading team: $err', style: TextStyle(color: AppTheme.statusOverdueTextColor(context))),
                data: (team) {
                  if (team.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.recessedSurface(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.cardBorder(context)),
                      ),
                      child: Text(
                        'No employees registered under your team yet. Direct text names will be matched automatically.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: team.map((emp) {
                      final isSelected = _selectedAttendees.contains(emp);
                      return FilterChip(
                        selected: isSelected,
                        backgroundColor: AppTheme.recessedSurface(context),
                        selectedColor: AppTheme.selectedPillBg(context),
                        avatar: CircleAvatar(
                          backgroundColor: isSelected ? Colors.transparent : AppTheme.cardBorder(context),
                          child: Text(
                            emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.selectedPillText(context) : AppTheme.textPrimary(context),
                            ),
                          ),
                        ),
                        label: Text(emp.name),
                        side: BorderSide(
                          color: isSelected ? AppTheme.selectedPillBorder(context) : AppTheme.cardBorder(context),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.selectedPillText(context) : AppTheme.textPrimary(context),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        checkmarkColor: isSelected ? AppTheme.selectedPillText(context) : null,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAttendees.add(emp);
                            } else {
                              _selectedAttendees.remove(emp);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ================= FILE UPLOAD (MP4 / AUDIO / TXT / DOCX) =================
              Text(
                'Upload Recording or Transcript File (Optional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Supports video/audio (.mp4, .mp3, .wav, .m4a) and documents (.txt, .doc, .docx)',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
              ),
              const SizedBox(height: 10),

              if (_pickedFile == null)
                OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _handlePickFile,
                  icon: Icon(Icons.upload_file_outlined, color: AppTheme.accentBlue(context)),
                  label: Text('Choose .MP4, Audio, .TXT, or .DOCX File', style: TextStyle(color: AppTheme.textPrimary(context))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    side: BorderSide(color: AppTheme.cardBorder(context)),
                    backgroundColor: AppTheme.recessedSurface(context),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.recessedSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentBlue(context).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _pickedFile!.isVideoOrAudio ? Icons.videocam_outlined : Icons.description_outlined,
                        color: AppTheme.accentBlue(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pickedFile!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textPrimary(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_pickedFile!.formattedSize} • ${_pickedFile!.isVideoOrAudio ? "Video/Audio (Whisper ASR)" : "Document Transcript"}',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: AppTheme.textSecondary(context)),
                        tooltip: 'Remove file',
                        onPressed: _isProcessing
                            ? null
                            : () {
                                setState(() {
                                  _pickedFile = null;
                                });
                              },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ================= TRANSCRIPT OR AUDIO INPUT =================
              TextFormField(
                controller: _transcriptController,
                maxLines: 7,
                style: TextStyle(color: AppTheme.textPrimary(context)),
                decoration: const InputDecoration(
                  labelText: 'Meeting Transcript or Verbal Notes',
                  hintText: 'Paste spoken notes or transcription here (or upload a file above).\nExample:\nRafey: I will complete the API tests by Friday.\nHifzan: I will review the database schema before Monday.',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (_pickedFile != null) return null;
                  if (v == null || v.trim().isEmpty) {
                    return 'Please provide transcript text or upload a file above';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Progress Status Card
              if (_isProcessing) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder(context)),
                    boxShadow: AppTheme.cardShadow(context),
                  ),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.accentBlue(context)),
                      const SizedBox(height: 14),
                      Text(
                        _processingStep,
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary(context)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'T.ask is matching commitments to your selected team members...',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              ElevatedButton.icon(
                icon: const Icon(Icons.bolt, size: 20),
                label: const Text('Process Meeting with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ctaBackground(context),
                  foregroundColor: AppTheme.ctaForeground(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
