part of '../_core.dart';

mixin SketchInputKeyboard {
  Set<LogicalKeyboardKey> _pressedKeys = {};

  bool get isKeyPressed => _pressedKeys.isNotEmpty;

  LogicalKeyboardKey? _key;
  LogicalKeyboardKey? get key => _key;

  void keyPressed() {}

  void keyTyped() {}

  void keyReleased() {}
}
