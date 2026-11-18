import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'file_picker_helper.dart';

Future<PickedMeetingFile?> pickMeetingFileImpl() async {
  try {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4',
        'mp3',
        'wav',
        'm4a',
        'webm',
        'ogg',
        'aac',
        'txt',
        'doc',
        'docx',
        'md',
      ],
    );

    if (files.isNotEmpty) {
      final file = files.first;
      final bytes = await file.readAsBytes();
      return PickedMeetingFile(name: file.name, bytes: bytes);
    }
  } catch (e) {
    if (Platform.isWindows) {
      return _pickWindowsFile(
        "Meeting Media & Docs (*.mp4;*.mp3;*.wav;*.m4a;*.txt;*.doc;*.docx)|*.mp4;*.mp3;*.wav;*.m4a;*.webm;*.ogg;*.txt;*.doc;*.docx|All Files (*.*)|*.*",
        "Select Meeting Video, Audio, or Transcript File",
      );
    }
  }
  return null;
}

Future<PickedMeetingFile?> pickAvatarImageImpl() async {
  try {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.image,
    );

    if (files.isNotEmpty) {
      final file = files.first;
      final bytes = await file.readAsBytes();
      return PickedMeetingFile(name: file.name, bytes: bytes);
    }
  } catch (e) {
    if (Platform.isWindows) {
      return _pickWindowsFile(
        "Image Files (*.png;*.jpg;*.jpeg;*.webp;*.gif;*.bmp)|*.png;*.jpg;*.jpeg;*.webp;*.gif;*.bmp|All Files (*.*)|*.*",
        "Select Profile Avatar Photo",
      );
    }
  }
  return null;
}

Future<PickedMeetingFile?> _pickWindowsFile(String filter, String title) async {
  if (!Platform.isWindows) return null;
  final script = '''
Add-Type -AssemblyName System.Windows.Forms
\$dlg = New-Object System.Windows.Forms.OpenFileDialog
\$dlg.Filter = "$filter"
\$dlg.Title = "$title"
if (\$dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
  Write-Output \$dlg.FileName
}
''';
  final result = await Process.run('powershell', ['-NoProfile', '-STA', '-Command', script]);
  final path = (result.stdout as String).trim();
  if (path.isNotEmpty) {
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final name = path.split(Platform.pathSeparator).last;
      return PickedMeetingFile(name: name, bytes: bytes);
    }
  }
  return null;
}
