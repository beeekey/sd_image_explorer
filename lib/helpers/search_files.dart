import 'dart:io';

Future<List<FileSystemEntity>> listDir(String selectedDirectory) async {
  final dir = Directory(selectedDirectory);
  final List<FileSystemEntity> entities = await dir.list().toList();
  return entities;
}

Future<List<File>> getFiles(String selectedDirectory) async {
  List<File> files = [];

  List<FileSystemEntity> entities = await listDir(selectedDirectory);

  for (var f in entities) {
    if (f is File &&
        (f.path.endsWith(".png") ||
            f.path.endsWith(".jpg") ||
            f.path.endsWith(".jpeg"))) {
      files.add(f);
    } else if (f is Directory) {
      files.addAll(await getFiles(f.path));
    }
  }

  // entities.forEach(print);

  return files.reversed.toList();
}
