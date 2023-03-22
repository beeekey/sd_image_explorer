import 'dart:io';

Future<List<FileSystemEntity>> listDir(String selectedDirectory) async {
  final dir = Directory(selectedDirectory);
  final List<FileSystemEntity> entities = await dir.list().toList();
  return entities;
}

Future<List<File>> getFiles(String selectedDirectory) async {
  // List<File> files = [];

  // List<FileSystemEntity> entities = await listDir(selectedDirectory);

  // for (var f in entities) {
  //   if (f is File &&
  //       (f.path.endsWith(".png") ||
  //           f.path.endsWith(".jpg") ||
  //           f.path.endsWith(".jpeg"))) {
  //     files.add(f);
  //   } else if (f is Directory) {
  //     files.addAll(await getFiles(f.path));
  //   }
  // }

  var fileList = Directory(selectedDirectory)
      .listSync()
      .map((item) => item as File)
      .where((item) {
    if (item.path.endsWith(".png") ||
        item.path.endsWith(".jpg") ||
        item.path.endsWith(".jpeg")) {
      return true;
    }
    return false;
  }).toList();

  // // Compute [FileStat] results for each file.  Use [Future.wait] to do it
  // // efficiently without needing to wait for each I/O operation sequentially.
  // var statResults = await Future.wait([
  //   for (var path in fileList) FileStat.stat(path.path),
  // ]);

  // // Map file paths to modification times.
  // var mtimes = <String, DateTime>{
  //   for (var i = 0; i < fileList.length; i += 1)
  //     fileList[i].path: statResults[i].changed,
  // };

  // // Sort [fileList] by modification times, from oldest to newest.
  // fileList.sort((a, b) => mtimes[a.path]!.compareTo(mtimes[b.path]!));

  fileList.sort((a, b) => a.path.compareTo(b.path));

  // entities.forEach(print);

  return fileList.reversed.toList();
}
