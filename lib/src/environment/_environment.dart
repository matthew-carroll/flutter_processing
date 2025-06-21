part of '../_core.dart';

mixin SketchEnvironment on BaseSketch, SketchColorSetting {
  Duration _elapsedTime = Duration.zero;
  void _updateElapsedTime(Duration newElapsedTime) => _elapsedTime = newElapsedTime;

  Duration? _lastDrawTime;

  int _frameCount = 0;
  int get frameCount => _frameCount;

  int _actualFrameRate = 10;
  int get frameRate => _actualFrameRate;

  Duration _desiredFrameTime = Duration(milliseconds: (1000.0 / 60).floor());
  set frameRate(int frameRate) {
    _desiredFrameTime = Duration(milliseconds: (1000.0 / frameRate).floor());
  }

  int _desiredWidth = 100;
  int _desiredHeight = 100;

  int get width => _desiredWidth;

  int get height => _desiredHeight;

  Size get _size => Size(width.toDouble(), height.toDouble());

  void size({
    required int width,
    required int height,
  }) {
    if (width == _desiredWidth && height == _desiredHeight) {
      return;
    }

    _desiredWidth = width;
    _desiredHeight = height;

    // To change size, we need to throw out the current bitmap cache and create a new one.
    // Instruct the current canvas to stop recording. Then, create a new canvas and start
    // recording again.
    _paintingContext.canvas.finishRecording();
    _paintingContext.replaceBitmapCanvas(BitmapCanvas(size: _size));
    _paintingContext.canvas.startRecording();

    background(color: _backgroundColor);
  }
}
