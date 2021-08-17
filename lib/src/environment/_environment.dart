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
  VoidCallback? _onSizeChanged;

  int get width => _desiredWidth;

  int get height => _desiredHeight;

  void size({
    required int width,
    required int height,
  }) {
    _desiredWidth = width;
    _desiredHeight = height;
    _paintingContext.size = Size(width.toDouble(), height.toDouble());
    _onSizeChanged?.call();

    background(color: _backgroundColor);
  }
}
