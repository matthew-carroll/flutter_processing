import 'dart:io';
import 'dart:ui';

import 'package:flutter_processing/flutter_processing.dart';
import 'package:image/image.dart' as gif;

class GifGenerator {
  GifGenerator({
    required int totalDesiredFrameCount,
    required int gifFrameRateFps,
  })  : _totalDesiredFrameCount = totalDesiredFrameCount,
        _gifFrameRateFps = Duration(milliseconds: (1000 / gifFrameRateFps).floor()),
        _gifEncoder = gif.GifEncoder();

  final int _totalDesiredFrameCount;
  final Duration _gifFrameRateFps;
  final gif.GifEncoder _gifEncoder;

  int _addedFrameCount = 0;
  bool get isDoneAddingFrames => _addedFrameCount >= _totalDesiredFrameCount;

  bool _hasSavedToFile = false;
  bool get hasSavedToFile => _hasSavedToFile;

  Future<void> addFrameFromSketch(Sketch sketch) async {
    if (isDoneAddingFrames) {
      return;
    }

    await sketch.loadPixels();

    final gifFrame = gif.Image.fromBytes(sketch.width, sketch.height, sketch.pixels!.buffer.asUint8List());
    final timeInHundredths = (_gifFrameRateFps.inMilliseconds / 10).round();
    _gifEncoder.addFrame(gifFrame, duration: timeInHundredths);
    _addedFrameCount += 1;

    print('${(100 * _addedFrameCount / _totalDesiredFrameCount).round()}% gif frames generated');
  }

  Future<void> addFrame(Image frame) async {
    if (isDoneAddingFrames) {
      return;
    }

    final frameBytes = await frame.toByteData();
    final gifFrame = gif.Image.fromBytes(frame.width, frame.height, frameBytes!.buffer.asUint8List());
    final timeInHundredths = (_gifFrameRateFps.inMilliseconds / 10).round();
    _gifEncoder.addFrame(gifFrame, duration: timeInHundredths);
    _addedFrameCount += 1;

    print('${(100 * _addedFrameCount / _totalDesiredFrameCount).round()}% gif frames generated');
  }

  Future<void> saveGif(File file) async {
    print('Writing gif to file');
    _hasSavedToFile = true;
    final gifData = _gifEncoder.finish();
    await file.writeAsBytes(gifData!);
    print('Done writing gif');
  }
}

enum GenerationStatus {
  notStarted,
  generating,
  done,
}
