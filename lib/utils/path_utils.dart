import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:offline_first/utils/extensions.dart';
import 'package:path_provider/path_provider.dart' as p;

class PathUtil {
  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  ///
  /// On iOS, this uses the `NSDocumentDirectory` API. Consider using
  /// [getApplicationSupportDirectory] instead if the data is not user-generated.
  ///
  /// On Android, this uses the `getDataDirectory` API on the context. Consider
  /// using [getExternalStorageDirectory] instead if data is intended to be visible
  /// to the user.
  Future<String> getDocumentDirPath() async {
    if (!kIsWeb) {
      try {
        final dir = await p.getApplicationDocumentsDirectory();
        return dir.path;
      } on PlatformException catch (e, s) {
        debugPrintStack(stackTrace: s, label: e.message);
      }
    }

    return '';
  }

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  ///
  /// Files in this directory may be cleared at any time. This does *not* return
  /// a new temporary directory. Instead, the caller is responsible for creating
  /// (and cleaning up) files or directories within this directory. This
  /// directory is scoped to the calling application.
  Future<String> getTempDirPath() async {
    try {
      final dir = await p.getTemporaryDirectory();
      return dir.path;
    } on PlatformException catch (e, s) {
      debugPrintStack(stackTrace: s, label: e.message);
      return '';
    }
  }

  /// Path to the directory where application can store files that are persistent,
  /// backed up, and not visible to the user, such as sqlite.db.
  Future<String> getDatabaseStorageDirPath() async {
    try {
      final dir = defaultTargetPlatform == TargetPlatform.iOS
          ? await p.getLibraryDirectory()
          : await p.getApplicationDocumentsDirectory();
      return dir.path;
    } on PlatformException catch (e, s) {
      debugPrintStack(stackTrace: s, label: e.message);
      return '';
    }
  }

  String getFileNameFromPath(String path) {
    if (path.isNotNullAndNotEmpty) {
      return path.split('/').isNotNullAndNotEmpty ? path.split('/').last.split('.').first : path.split('.').first;
    }
    return '';
  }
}