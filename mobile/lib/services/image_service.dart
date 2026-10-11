import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static const int maxSize = 200 * 1024; // FR-M4: < 200KB

  static Future<File?> compress(File source) async {
    final tempDir = await getTemporaryDirectory();
    final target = p.join(
      tempDir.path,
      'akeep_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    Future<File?> compressAtQuality(int quality) async {
      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        target,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return result == null ? null : File(result.path);
    }

    var compressed = await compressAtQuality(80);
    if (compressed == null) return null;

    // Retry with lower quality if still above limit
    if (compressed.lengthSync() > maxSize) {
      compressed = await compressAtQuality(50);
    }
    return compressed;
  }

  static Future<String> toBase64(File image) async {
    final bytes = await image.readAsBytes();
    return 'data:image/jpeg;base64,${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }
}
