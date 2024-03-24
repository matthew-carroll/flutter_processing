import 'dart:io';
import 'dart:ui';

import 'package:flutter_processing/flutter_processing.dart';
import 'package:image/image.dart' as gif;

class GifGenerator {
  GifGenerator({
    required Duration duration,
    required int gifFrameRateFps,
  })  : _totalDuration = duration,
        _totalDesiredFrameCount = ((duration.inMilliseconds / 1000) * gifFrameRateFps).floor(),
        _gifFrameRateFps = Duration(milliseconds: (1000 / gifFrameRateFps).floor()),
        _gifEncoder = gif.GifEncoder();

  final Duration _totalDuration;
  final int _totalDesiredFrameCount;
  final Duration _gifFrameRateFps;
  final gif.GifEncoder _gifEncoder;

  // Cached frames, which are written to a file at the end of recording.
  //
  // We cache the frames because it takes a long time to encode a single
  // frame, and that encoding happens on the main thread. We choose to
  // lock up the UI for a long time at the end of the recording, instead
  // of locking up every frame during recording.
  final List<gif.Image> _frames = [];
  int _addedFrameCount = 0;
  Duration _elapsedSketchTime = Duration.zero;
  Duration _nextFrameTime = Duration.zero;
  bool get isDoneAddingFrames => _addedFrameCount >= _totalDesiredFrameCount;

  bool _hasSavedToFile = false;
  bool get hasSavedToFile => _hasSavedToFile;

  Future<void> addFrameFromSketch(Sketch sketch) async {
    if (isDoneAddingFrames) {
      return;
    }

    await sketch.loadPixels();

    final gifFrame = gif.Image.fromBytes(width: sketch.width, height: sketch.height, bytes: sketch.pixels!.buffer);
    final timeInHundredths = (_gifFrameRateFps.inMilliseconds / 10).round();
    _gifEncoder.addFrame(gifFrame, duration: timeInHundredths);
    _addedFrameCount += 1;

    print('${(100 * _addedFrameCount / _totalDesiredFrameCount).round()}% gif frames generated');
  }

  Future<void> addFrame(Image frame, Duration sketchFrameRate) async {
    if (isDoneAddingFrames) {
      return;
    }

    // Compute the effective frame rate from the sketch's perspective, then
    // compare to the desired GIF frame rate to determine if we want to save
    // this frame, or wait for a future frame.
    //
    // Note: the sketch's frame rate can change programmatically, which is
    // why we take the sketch frame rate as a parameter to this method, rather
    // than a class-wide property.
    _elapsedSketchTime += sketchFrameRate; // Add one frame of elapsed time.
    if (_elapsedSketchTime < _nextFrameTime) {
      // This frame comes too soon for us to save it and achieve our desired
      // output frame rate. We need to wait for a future frame.
      return;
    }

    final frameBytes = await frame.toByteData();
    final gifFrame = gif.Image.fromBytes(width: frame.width, height: frame.height, bytes: frameBytes!.buffer);
    _frames.add(gifFrame);
    // final timeInHundredths = (_gifFrameRateFps.inMilliseconds / 10).round();
    // _gifEncoder.addFrame(gifFrame, duration: timeInHundredths);
    _addedFrameCount += 1;
    _nextFrameTime += _gifFrameRateFps;

    print('${(100 * _addedFrameCount / _totalDesiredFrameCount).round()}% gif frames generated');
  }

  Future<void> saveGif(File file) async {
    print('Writing gif to file');
    print(' - Duration: ${_totalDuration.inSeconds}s, FPS: $_gifFrameRateFps');
    print(' - Frame count: $_totalDesiredFrameCount');
    _hasSavedToFile = true;

    final timeInHundredths = (_gifFrameRateFps.inMilliseconds / 10).round();
    for (int i = 0; i < _frames.length; i += 1) {
      print(" - Writing frame $i (don't interrupt this process!)");
      _gifEncoder.addFrame(_frames[i], duration: timeInHundredths);
    }

    final gifData = _gifEncoder.finish();
    await file.writeAsBytes(gifData!);

    // Clear out all the frame data, because it's probably taking up
    // **a lot** of space.
    _frames.clear();

    print('Done writing gif');
  }
}

enum GenerationStatus {
  notStarted,
  generating,
  done,
}
