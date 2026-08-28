import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

final _fileName = RegExp(r'[^/\\]+$');

String nameOf(String path) => _fileName.firstMatch(path)?.group(0) ?? path;

Future<String> readJson(String path) => File(path).readAsString();

Future<String?> pickOpenPath() async {
  final result = await FilePicker.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: ["json"],
  );
  return result?.files.first.path;
}

Future<String?> pickSavePath() => FilePicker.saveFile(
  dialogTitle: "Please select an output file",
  fileName: "output.json",
);

Future<String?> writeJson(String path, dynamic content) async {
  try {
    await File(path).writeAsString(json.encode(content));
    return null;
  } on FileSystemException catch (e) {
    return e.osError?.message ?? e.message;
  } on JsonUnsupportedObjectError catch (e) {
    return "Cannot encode ${e.unsupportedObject.runtimeType}";
  }
}
