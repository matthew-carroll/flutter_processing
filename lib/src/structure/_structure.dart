part of '../_core.dart';

mixin SketchStructure {
  bool _isLooping = true;
  bool get isLooping => _isLooping;

  VoidCallback? _loop;
  VoidCallback? _noLoop;

  void loop() {
    _isLooping = true;
    _loop?.call();
  }

  void noLoop() {
    _isLooping = false;
    _noLoop?.call();
  }
}
