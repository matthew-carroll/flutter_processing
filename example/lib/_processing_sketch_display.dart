import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

import 'gif/gif.dart';

abstract class ProcessingState<T extends StatefulWidget> extends State<T> {
  Sketch? _sketch;

  Color _backgroundColor = const Color(0xFF222222);

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
    _sketch ??= createSketch();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Processing(
              sketch: _sketch!,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBackgroundColorChooser(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorChooser() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildColorDot(const Color(0xFF222222)),
          SizedBox(width: 24),
          _buildColorDot(const Color(0xFFFFFFFF)),
          SizedBox(width: 24),
          _buildColorDot(const Color(0xFFFFFF00)),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _backgroundColor = color;
          });
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
