import 'dart:io';
import 'file_picker_helper.dart';

Future<PickedMeetingFile?> pickMeetingFileImpl() async {
  if (Platform.isWindows) {
    final script = '''
Add-Type -AssemblyName System.Windows.Forms
\$dlg = New-Object System.Windows.Forms.OpenFileDialog
\$dlg.Filter = "Meeting Media & Docs (*.mp4;*.mp3;*.wav;*.m4a;*.txt;*.doc;*.docx)|*.mp4;*.mp3;*.wav;*.m4a;*.webm;*.ogg;*.txt;*.doc;*.docx|All Files (*.*)|*.*"
\$dlg.Title = "Select Meeting Video, Audio, or Transcript File"
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
  }
  return null;
}

Future<PickedMeetingFile?> pickAvatarImageImpl() async {
  if (Platform.isWindows) {
    final script = '''
Add-Type -AssemblyName System.Windows.Forms
\$dlg = New-Object System.Windows.Forms.OpenFileDialog
\$dlg.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.webp;*.gif;*.bmp)|*.png;*.jpg;*.jpeg;*.webp;*.gif;*.bmp|All Files (*.*)|*.*"
\$dlg.Title = "Select Profile Avatar Photo"
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
  }
  return null;
}
