import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

import 'gif/gif.dart';

abstract class ProcessingState<T extends StatefulWidget> extends State<T> {
  GifGenerator? _gifGenerator;

  @protected
  int get gifFps => 30;

  @protected
  Duration get gifDuration => const Duration(seconds: 5);

  @protected
  String get gifFilepath;

  @protected
  void startRecordingGif() {
    _gifGenerator = GifGenerator(
      totalDesiredFrameCount: gifFps * gifDuration.inSeconds,
      gifFrameRateFps: gifFps,
    );
  }

  @protected
  Future<void> saveGifFrameIfDesired(Sketch s) async {
    if (_gifGenerator != null && !_gifGenerator!.isDoneAddingFrames) {
      await _gifGenerator!.addFrame(s);

      if (_gifGenerator!.isDoneAddingFrames && !_gifGenerator!.hasSavedToFile) {
        saveGifToFile();
      }
    }
  }

  @protected
  Future<void> saveGifToFile() async {
    if (_gifGenerator == null) {
      return;
    }

    await _gifGenerator!.saveGif(
      File(gifFilepath),
    );
  }

  Sketch createSketch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Processing(
        sketch: createSketch(),
      ),
    );
  }
}
