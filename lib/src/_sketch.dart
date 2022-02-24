part of '_core.dart';

class Sketch extends BaseSketch
    with
        SketchColor,
        SketchColorSetting,
        SketchConstants,
        SketchDataConversion,
        SketchEnvironment,
        SketchInputKeyboard,
        SketchInputMouse,
        SketchImageLoadingAndDisplaying,
        SketchImagePixels,
        SketchInputTimeAndDate,
        SketchMathCalculations,
        SketchMathTrigonometry,
        SketchMathRandom,
        SketchOutputImage,
        SketchRendering,
        SketchShapeAttributes,
        SketchShapeTwoDPrimitives,
        SketchShapeVertex,
        SketchStructure,
        SketchTransform,
        SketchTypography {
  Sketch.simple({
    FutureOr<void> Function(Sketch)? setup,
    FutureOr<void> Function(Sketch)? draw,
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

  void dispose() {
    clearOnFrameAvailableCallbacks();
  }

  FutureOr<void> Function(Sketch)? _setup;
  FutureOr<void> Function(Sketch)? _draw;
  void Function(Sketch)? _keyPressed;
  void Function(Sketch)? _keyTyped;
  void Function(Sketch)? _keyReleased;
  void Function(Sketch)? _mousePressed;
  void Function(Sketch)? _mouseDragged;
  void Function(Sketch)? _mouseReleased;
  void Function(Sketch)? _mouseClicked;
  void Function(Sketch)? _mouseMoved;
  void Function(Sketch, double count)? _mouseWheel;

  Image? get publishedFrame => _paintingContext.publishedImage;

  final _onFrameAvailableCallbacks = <FrameCallback>{};

  void addOnFrameAvailableCallback(FrameCallback callback) {
    _onFrameAvailableCallbacks.add(callback);
  }

  void removeOnFrameAvailableCallback(FrameCallback callback) {
    _onFrameAvailableCallbacks.remove(callback);
  }

  void clearOnFrameAvailableCallbacks() {
    _onFrameAvailableCallbacks.clear();
  }

  bool _isDrawing = false;

  bool _hasDoneSetup = false;

  Future<void> _doDrawFrame(Duration elapsedTime) async {
    if (_isDrawing || (_hasDoneSetup && !_isLooping)) {
      return;
    }

    _updateElapsedTime(elapsedTime);
    if (_lastDrawTime != null && (_elapsedTime - _lastDrawTime! < _desiredFrameTime)) {
      return;
    }

    _isDrawing = true;

    _paintingContext.startRecording();

    // Run Processing setup method.
    await _doSetup();

    // Run Processing draw method.
    await _onDraw();

    await _paintingContext.finishRecording();

    // Let all interested listeners know that we've produced a new frame.
    for (final callback in _onFrameAvailableCallbacks) {
      await callback(_paintingContext.publishedImage!);
    }

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

  FutureOr<void> setup() async {
    await _setup?.call(this);
  }

  Future<void> _onDraw() async {
    if (_paintingContext.publishedImage != null) {
      _paintingContext.canvas.drawImage(_paintingContext.publishedImage!, Offset.zero, Paint());
    }

    await draw();

    _frameCount += 1;
    _lastDrawTime = _elapsedTime;

    final secondsFraction = _elapsedTime.inMilliseconds / 1000.0;
    _actualFrameRate = secondsFraction > 0 ? (_frameCount / secondsFraction).round() : _actualFrameRate;
  }

  FutureOr<void> draw() async {
    await _draw?.call(this);
  }

  @override
  void keyPressed() {
    _keyPressed?.call(this);
  }

  @override
  void keyTyped() {
    _keyTyped?.call(this);
  }

  @override
  void keyReleased() {
    _keyReleased?.call(this);
  }

  @override
  void mousePressed() {
    _mousePressed?.call(this);
  }

  @override
  void mouseDragged() {
    _mouseDragged?.call(this);
  }

  @override
  void mouseReleased() {
    _mouseReleased?.call(this);
  }

  @override
  void mouseClicked() {
    _mouseClicked?.call(this);
  }

  @override
  void mouseMoved() {
    _mouseMoved?.call(this);
  }

  @override
  void mouseWheel(double count) {
    _mouseWheel?.call(this, count);
  }
}

typedef FrameCallback = FutureOr<void> Function(Image);
