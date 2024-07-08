import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class VideoTrimmer {
  static Future<String> copyAssetToFile(String assetPath) async {
    // Load asset data
    ByteData data = await rootBundle.load(assetPath);

    // Get temporary directory
    final Directory tempDir = await getTemporaryDirectory();

    // Create a file path for the temporary file
    String tempPath = path.join(tempDir.path, path.basename(assetPath));
    File tempFile = File(tempPath);

    // Write data to the file
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

    return tempFile.path;
  }

  static Future<File> trimVideo(String inputPath, int durationSeconds) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath = path.join(tempDir.path, 'trimmed_video.mp4');

    final String ffmpegCommand =
        '-i $inputPath -t $durationSeconds -c copy $outputPath';
    await FFmpegKit.execute(ffmpegCommand);

    return File(outputPath);
  }

  static Future<File> trimAssetVideo(String assetPath, int durationSeconds) async {
    String inputPath = await copyAssetToFile(assetPath);
    return await trimVideo(inputPath, durationSeconds);
  }
}
