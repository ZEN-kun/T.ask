import 'dart:typed_data';
import 'file_picker_io.dart' if (dart.library.js_interop) 'file_picker_web.dart';

class PickedMeetingFile {
  final String name;
  final Uint8List bytes;

  PickedMeetingFile({required this.name, required this.bytes});

  String get extension {
    final idx = name.lastIndexOf('.');
    return idx != -1 ? name.substring(idx).toLowerCase() : '';
  }

  bool get isVideoOrAudio =>
      const {'.mp4', '.mp3', '.wav', '.m4a', '.webm', '.ogg', '.mpeg', '.aac'}.contains(extension);

  bool get isDocument =>
      const {'.txt', '.doc', '.docx', '.md', '.rtf'}.contains(extension);

  String get formattedSize {
    final kb = bytes.lengthInBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}

Future<PickedMeetingFile?> pickMeetingFile() => pickMeetingFileImpl();
Future<PickedMeetingFile?> pickAvatarImage() => pickAvatarImageImpl();
