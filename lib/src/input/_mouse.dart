part of '../_core.dart';

mixin SketchInputMouse {
  int _mouseX = 0;
  int get mouseX => _mouseX;

  int _mouseY = 0;
  int get mouseY => _mouseY;

  int _pmouseX = 0;
  int get pmouseX => _pmouseX;

  int _pmouseY = 0;
  int get pmouseY => _pmouseY;

  void _updateMousePosition(Offset newPosition) {
    _pmouseX = _mouseX;
    _pmouseY = _mouseY;

    _mouseX = newPosition.dx.round();
    _mouseY = newPosition.dy.round();
  }

  Set<MouseButton> _pressedMouseButtons = {};

  bool get isMousePressed => _pressedMouseButtons.isNotEmpty;

  MouseButton? _mouseButton;
  MouseButton? get mouseButton => _mouseButton;

  void mousePressed() {}

  void mouseDragged() {}

  void mouseReleased() {}

  void mouseClicked() {}

  void mouseMoved() {}

  void mouseWheel(double count) {}
}
