import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing/src/constants/_constants.dart';
import 'package:flutter_processing/src/math/_random.dart';
import 'package:flutter_processing/src/math/_trigonometry.dart';
import 'package:image/image.dart' as imageFormats;
import 'package:path/path.dart' as path;

import '_painting_context.dart';
import 'data/conversion.dart';
import 'input/time_and_date.dart';
import 'math/_calculations.dart';
import 'shape/shapes.dart';

part 'color/_setting.dart';
part 'image/_loading_and_displaying.dart';
part 'image/_pixels.dart';
part 'output/_image.dart';
part 'shape/_attributes.dart';
part 'shape/_two_d_primitives.dart';
part 'transform/_transform.dart';

class Processing extends StatefulWidget {
  const Processing({
    Key? key,
    this.focusNode,
    required this.sketch,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  final FocusNode? focusNode;
  final Sketch sketch;
  final Clip clipBehavior;

  @override
  _ProcessingState createState() => _ProcessingState();
}

class _ProcessingState extends State<Processing> with SingleTickerProviderStateMixin {
  final _controlKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.escape,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.pageDown,
  };

  final _sketchCanvasKey = GlobalKey();

  late Ticker _ticker;
  late FocusNode _focusNode;

  Image? _currentImage;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();

    _focusNode = widget.focusNode ?? FocusNode();

    widget.sketch
      .._onFrameAvailable = _onFrameAvailable
      .._onSizeChanged = _onSizeChanged
      .._loop = _loop
      .._noLoop = _noLoop;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.sketch._assetBundle = DefaultAssetBundle.of(context);
  }

  @override
  void didUpdateWidget(Processing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode = widget.focusNode ?? FocusNode();
    }

    if (widget.sketch != oldWidget.sketch) {
      oldWidget.sketch
        .._onFrameAvailable = null
        .._onSizeChanged = null
        .._loop = null
        .._noLoop = null;

      widget.sketch
        .._onFrameAvailable = _onFrameAvailable
        .._assetBundle = DefaultAssetBundle.of(context)
        .._onSizeChanged = _onSizeChanged
        .._loop = _loop
        .._noLoop = _noLoop;

      _ticker.stop();
      if (widget.sketch._isLooping) {
        _ticker.start();
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(elapsedTime) {
    widget.sketch._doDrawFrame(elapsedTime);
  }

  void _onFrameAvailable(Image newFrame) {
    if (mounted) {
      setState(() {
        _currentImage = newFrame;
      });
    }
  }

  void _onSizeChanged() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  void _noLoop() {
    if (_ticker.isTicking) {
      _ticker.stop();
    }
  }

  void _loop() {
    if (!_ticker.isTicking) {
      _ticker.start();
    }
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      widget.sketch._onKeyPressed(event.logicalKey);

      if (!_controlKeys.contains(event.logicalKey)) {
        widget.sketch._onKeyTyped(event.logicalKey);
      }
    } else if (event is RawKeyUpEvent) {
      widget.sketch._onKeyReleased(event.logicalKey);
    }
  }

  MouseButton _getMouseButton(int mouseButtonMask) {
    if (mouseButtonMask & kPrimaryMouseButton != 0) {
      return MouseButton.left;
    } else if (mouseButtonMask & kSecondaryMouseButton != 0) {
      return MouseButton.right;
    } else if (mouseButtonMask & kMiddleMouseButton != 0) {
      return MouseButton.center;
    } else {
      throw Exception('Invalid mouse button mask: $mouseButtonMask');
    }
  }

  Offset _getCanvasOffsetFromWidgetOffset(Offset widgetOffset) {
    final myBox = context.findRenderObject();
    final canvasBox = _sketchCanvasKey.currentContext!.findRenderObject() as RenderBox;
    return canvasBox.globalToLocal(widgetOffset, ancestor: myBox);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }

    final mouseButton = _getMouseButton(event.buttons);

    widget.sketch._pressedMouseButtons.add(mouseButton);
    widget.sketch
      .._mouseButton = mouseButton
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      .._onMousePressed();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }

    final mouseButton = _getMouseButton(event.buttons);

    widget.sketch
      .._mouseButton = mouseButton
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      .._onMouseDragged();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }

    // TODO: the PointerUpEvent does not report which button was relased,
    //       therefore we don't know which one to remove from the set.
    //       For now, we remove all pressed button.
    //
    //       Find an appropriate solution to handle concurrent mouse button
    //       presses and releases.
    widget.sketch._pressedMouseButtons.clear();
    widget.sketch
      .._mouseButton = null
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      .._onMouseReleased()
      .._onMouseClicked();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }

    // TODO: the PointerUpEvent does not report which button was relased,
    //       therefore we don't know which one to remove from the set.
    //       For now, we remove all pressed button.
    //
    //       Find an appropriate solution to handle concurrent mouse button
    //       presses and releases.
    widget.sketch._pressedMouseButtons.clear();
    widget.sketch
      .._mouseButton = null
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      .._onMouseReleased();
  }

  void _onPointerHover(PointerHoverEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }

    widget.sketch
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      .._onMouseMoved();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    widget.sketch._onMouseWheel(event.scrollDelta.dy);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _onKey,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        onPointerHover: _onPointerHover,
        onPointerSignal: _onPointerSignal,
        child: Center(
          child: _currentImage != null
              ? OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    width: _currentImage!.width.toDouble(),
                    height: _currentImage!.height.toDouble(),
                    child: RawImage(
                      key: _sketchCanvasKey,
                      image: _currentImage,
                    ),
                  ),
                )
              : SizedBox(
                  key: _sketchCanvasKey,
                ),
        ),
      ),
    );
  }
}

abstract class BaseSketch {
  SketchPaintingContext _paintingContext = SketchPaintingContext();

  AssetBundle? _assetBundle;
}

class Sketch extends BaseSketch
    with
        SketchColor,
        SketchColorSetting,
        SketchConstants,
        SketchDataConversion,
        SketchImageLoadingAndDisplaying,
        SketchImagePixels,
        SketchInputTimeAndDate,
        SketchMathCalculations,
        SketchMathTrigonometry,
        SketchMathRandom,
        SketchOutputImage,
        SketchShapeAttributes,
        SketchShapeTwoDPrimitives,
        SketchTransform {
  Sketch.simple({
    Future<void> Function(Sketch)? setup,
    Future<void> Function(Sketch)? draw,
    void Function(Sketch)? keyPressed,
    void Function(Sketch)? keyTyped,
    void Function(Sketch)? keyReleased,
    void Function(Sketch)? mousePressed,
    void Function(Sketch)? mouseDragged,
    void Function(Sketch)? mouseReleased,
    void Function(Sketch)? mouseClicked,
    void Function(Sketch)? mouseMoved,
    void Function(Sketch, double)? mouseWheel,
  })  : _setup = setup,
        _draw = draw,
        _keyPressed = keyPressed,
        _keyTyped = keyTyped,
        _keyReleased = keyReleased,
        _mousePressed = mousePressed,
        _mouseDragged = mouseDragged,
        _mouseReleased = mouseReleased,
        _mouseClicked = mouseClicked,
        _mouseMoved = mouseMoved,
        _mouseWheel = mouseWheel;

  Sketch();

  Future<void> Function(Sketch)? _setup;
  Future<void> Function(Sketch)? _draw;
  void Function(Sketch)? _keyPressed;
  void Function(Sketch)? _keyTyped;
  void Function(Sketch)? _keyReleased;
  void Function(Sketch)? _mousePressed;
  void Function(Sketch)? _mouseDragged;
  void Function(Sketch)? _mouseReleased;
  void Function(Sketch)? _mouseClicked;
  void Function(Sketch)? _mouseMoved;
  void Function(Sketch, double count)? _mouseWheel;

  void Function(Image newFrame)? _onFrameAvailable;
  bool _isDrawing = false;

  bool _hasDoneSetup = false;

  Future<void> _doDrawFrame(Duration elapsedTime) async {
    if (_isDrawing || (_hasDoneSetup && !_isLooping)) {
      return;
    }

    _isDrawing = true;

    _updateElapsedTime(elapsedTime);

    _paintingContext.startRecording();

    // Run Processing setup method.
    await _doSetup();

    // Run Processing draw method.
    await _onDraw();

    await _paintingContext.finishRecording();

    _onFrameAvailable?.call(_paintingContext.publishedImage!);
    _isDrawing = false;
  }

  Future<void> _doSetup() async {
    assert(_assetBundle != null);

    if (_hasDoneSetup) {
      return;
    }
    _hasDoneSetup = true;

    // By default fill the background with a light grey.
    background(color: _backgroundColor);

    await setup();
  }

  Future<void> setup() async {
    await _setup?.call(this);
  }

  Future<void> _onDraw() async {
    // TODO: figure out how to correctly support varying frame rates
    // if (_lastDrawTime != null) {
    //   if (_elapsedTime - _lastDrawTime! < _desiredFrameTime) {
    //     return;
    //   }
    // }

    if (_paintingContext.publishedImage != null) {
      _paintingContext.canvas.drawImage(_paintingContext.publishedImage!, Offset.zero, Paint());
    }

    await draw();

    _frameCount += 1;
    _lastDrawTime = _elapsedTime;

    final secondsFraction = _elapsedTime.inMilliseconds / 1000.0;
    _actualFrameRate = secondsFraction > 0 ? (_frameCount / secondsFraction).round() : _actualFrameRate;
  }

  Future<void> draw() async {
    await _draw?.call(this);
  }

  void _onKeyPressed(LogicalKeyboardKey key) {
    _pressedKeys.add(key);
    _key = key;

    keyPressed();
  }

  void keyPressed() {
    _keyPressed?.call(this);
  }

  void _onKeyTyped(LogicalKeyboardKey key) {
    keyTyped();
  }

  void keyTyped() {
    _keyTyped?.call(this);
  }

  void _onKeyReleased(LogicalKeyboardKey key) {
    _pressedKeys.remove(key);
    _key = key;

    keyReleased();
  }

  void keyReleased() {
    _keyReleased?.call(this);
  }

  void _onMousePressed() {
    mousePressed();
  }

  void mousePressed() {
    _mousePressed?.call(this);
  }

  void _onMouseDragged() {
    mouseDragged();
  }

  void mouseDragged() {
    _mouseDragged?.call(this);
  }

  void _onMouseReleased() {
    mouseReleased();
  }

  void mouseReleased() {
    _mouseReleased?.call(this);
  }

  void _onMouseClicked() {
    mouseClicked();
  }

  void mouseClicked() {
    _mouseClicked?.call(this);
  }

  void _onMouseMoved() {
    mouseMoved();
  }

  void mouseMoved() {
    _mouseMoved?.call(this);
  }

  void _onMouseWheel(double count) {
    mouseWheel(count);
  }

  void mouseWheel(double count) {
    _mouseWheel?.call(this, count);
  }

  int _desiredWidth = 100;
  int _desiredHeight = 100;
  VoidCallback? _onSizeChanged;

  //------ Start Structure -----
  bool _isLooping = true;
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

  //------ Start Environment -----
  Duration _elapsedTime = Duration.zero;
  void _updateElapsedTime(Duration newElapsedTime) => _elapsedTime = newElapsedTime;

  Duration? _lastDrawTime;

  int _frameCount = 0;
  int get frameCount => _frameCount;

  int _actualFrameRate = 10;
  int get frameRate => _actualFrameRate;

  Duration _desiredFrameTime = Duration(milliseconds: (1000.0 / 60).floor());
  set frameRate(int frameRate) {
    print('WARNING: non-natural frame rates are very buggy at this time');

    _desiredFrameTime = Duration(milliseconds: (1000.0 / frameRate).floor());
  }

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

  //----- Start Input/Mouse ----
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

  //----- Start Input/Keyboard ----
  Set<LogicalKeyboardKey> _pressedKeys = {};

  bool get isKeyPressed => _pressedKeys.isNotEmpty;

  LogicalKeyboardKey? _key;
  LogicalKeyboardKey? get key => _key;
}

enum MouseButton {
  left,
  center,
  right,
}

enum ImageFileFormat {
  png,
  jpeg,
  tiff,
  targa,
}
