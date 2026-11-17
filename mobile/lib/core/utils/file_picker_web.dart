import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'file_picker_helper.dart';

Future<PickedMeetingFile?> pickMeetingFileImpl() async {
  final completer = Completer<PickedMeetingFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.mp4,.mp3,.wav,.m4a,.webm,.ogg,.txt,.doc,.docx,.md';

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.length == 0) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files.item(0);
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final reader = web.FileReader();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result != null) {
        final buffer = (result as JSArrayBuffer).toDart;
        final bytes = Uint8List.view(buffer);
        if (!completer.isCompleted) {
          completer.complete(PickedMeetingFile(name: file.name, bytes: bytes));
        }
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
    });
    reader.readAsArrayBuffer(file);
  });

  input.click();
  return completer.future;
}

Future<PickedMeetingFile?> pickAvatarImageImpl() async {
  final completer = Completer<PickedMeetingFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*,.png,.jpg,.jpeg,.webp,.gif,.bmp';

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.length == 0) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files.item(0);
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final reader = web.FileReader();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result != null) {
        final buffer = (result as JSArrayBuffer).toDart;
        final bytes = Uint8List.view(buffer);
        if (!completer.isCompleted) {
          completer.complete(PickedMeetingFile(name: file.name, bytes: bytes));
        }
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
    });
    reader.readAsArrayBuffer(file);
  });

  input.click();
  return completer.future;
}
