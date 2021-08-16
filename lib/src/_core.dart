import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing/src/constants/_constants.dart';
import 'package:flutter_processing/src/math/_random.dart';
import 'package:flutter_processing/src/math/_trigonometry.dart';
import 'package:flutter_processing/src/shape/_two_d_primitives.dart';
import 'package:image/image.dart' as imageFormats;
import 'package:path/path.dart' as path;

import '_painting_context.dart';
import 'data/conversion.dart';
import 'input/time_and_date.dart';
import 'math/_calculations.dart';

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

  @protected
  SketchPaintingContext get paintingContext => _paintingContext;
}

class Sketch extends BaseSketch
    with
        SketchConstants,
        SketchMathCalculations,
        SketchMathTrigonometry,
        SketchMathRandom,
        SketchInputTimeAndDate,
        SketchDataConversion,
        SketchColor,
        SketchShapeTwoDPrimitives {
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

  AssetBundle? _assetBundle;

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

  Color _backgroundColor = const Color(0xFFC5C5C5);

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

  //------ Start Color/Setting -----
  void background({
    required Color color,
  }) {
    _backgroundColor = color;

    final paint = Paint()..color = color;
    _paintingContext.canvas.drawRect(Offset.zero & _paintingContext.size, paint);

    _paintingContext.markHasUnappliedCanvasCommands();
  }

  void fill({
    required Color color,
  }) {
    _paintingContext.fillPaint.color = color;
  }

  void noFill() {
    _paintingContext.fillPaint.color = const Color(0x00000000);
  }

  void stroke({
    required Color color,
  }) {
    _paintingContext.strokePaint.color = color;
  }

  void noStroke() {
    _paintingContext.strokePaint.color = const Color(0x00000000);
  }
  //------- End Color/Setting -----

  //------- Start Image/Loading & Displaying -----
  Future<Image> loadImage(String filepath) async {
    final imageData = await _assetBundle!.load(filepath);
    final codec = await (await ImageDescriptor.encoded(
      await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
    ))
        .instantiateCodec();

    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void image({
    required Image image,
    Offset origin = Offset.zero,
    Size? displaySize,
  }) {
    // TODO: implement displaySize support.
    _paintingContext.canvas.drawImage(image, origin, Paint());

    _paintingContext.markHasUnappliedCanvasCommands();
  }

  //------- Start Image/Pixels -----
  Future<Color> get(int x, int y) async {
    await _paintingContext.doIntermediateRasterization();
    final sourceImage = (_paintingContext.intermediateImage ?? _paintingContext.publishedImage)!;

    final pixelDataOffset = _getBitmapPixelOffset(
      imageWidth: sourceImage.width,
      x: x,
      y: y,
    );
    final imageData = await sourceImage.toByteData();
    final rgbaColor = imageData!.getUint32(pixelDataOffset);
    final argbColor = ((rgbaColor & 0x000000FF) << 24) | ((rgbaColor & 0xFFFFFF00) >> 8);
    return Color(argbColor);
  }

  Future<Image> getRegion({
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    await _paintingContext.doIntermediateRasterization();
    final sourceImage = (_paintingContext.intermediateImage ?? _paintingContext.publishedImage)!;

    final sourceData = await sourceImage.toByteData();
    final destinationData = Uint8List(width * height * 4);
    final rowLength = width * 4;

    for (int row = 0; row < height; row += 1) {
      final sourceRowOffset = _getBitmapPixelOffset(
        imageWidth: sourceImage.width,
        x: x,
        y: y + row,
      );
      final destinationRowOffset = _getBitmapPixelOffset(
        imageWidth: width,
        x: 0,
        y: row,
      );

      destinationData.setRange(
        destinationRowOffset,
        destinationRowOffset + rowLength - 1,
        Uint8List.view(sourceData!.buffer, sourceRowOffset, rowLength),
      );
    }

    final codec = await ImageDescriptor.raw(
      await ImmutableBuffer.fromUint8List(destinationData),
      width: width,
      height: height,
      pixelFormat: PixelFormat.rgba8888,
    ).instantiateCodec();

    return (await codec.getNextFrame()).image;
  }

  Future<void> loadPixels() async {
    await _paintingContext.loadPixels();
  }

  ByteData? get pixels => _paintingContext.pixels;

  void set({
    required int x,
    required int y,
    required Color color,
  }) {
    if (pixels == null) {
      throw Exception('Must call loadPixels() before calling updatePixels()');
    }

    final pixelIndex = _getBitmapPixelOffset(
      imageWidth: width,
      x: x,
      y: y,
    );

    final argbColorInt = color.value;
    final rgbaColorInt = ((argbColorInt & 0xFF000000) >> 24) | ((argbColorInt & 0x00FFFFFF) << 8);
    pixels!.setUint32(pixelIndex, rgbaColorInt);
  }

  Future<void> setRegion({
    required Image image,
    int x = 0,
    int y = 0,
  }) async {
    if (pixels == null) {
      throw Exception('Must call loadPixels() before calling updatePixels()');
    }

    // In theory, this method should copy each pixels in the given image
    // into the pixels buffer. But, it's easier for us to utilize the Canvas
    // to accomplish the same thing. To use the Canvas, we must first ensure
    // that any intermediate values in the pixels buffer are applied back to
    // the intermediate image. For example, if the user called set() on any
    // pixels but has not yet called updatePixels(), those pixels would be
    // lost during an intermediate rasterization. Therefore, the first thing
    // we do is updatePixels().
    await updatePixels();

    // Use the Canvas to draw the given image at the desired offset.
    this.image(image: image, origin: Offset(x.toDouble(), y.toDouble()));

    // Rasterize the Canvas image command and load the latest image data
    // into the pixels buffer.
    await _paintingContext.loadPixels();
  }

  Future<void> updatePixels() async {
    await _paintingContext.updatePixels();
  }

  int _getBitmapPixelOffset({
    required int imageWidth,
    required int x,
    required int y,
  }) {
    return ((y * imageWidth) + x) * 4;
  }

  //----- Start Shape/Attributes ----
  void strokeWeight(double newWeight) {
    if (newWeight < 0) {
      throw Exception('Stroke weight must be >= 0');
    }

    _paintingContext.strokePaint.strokeWidth = newWeight.toDouble();
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

  //------- Start Output/Image -----
  /// Saves the current [pixels] buffer data to the given [file].
  ///
  /// The [file]'s extension is used to infer the desired image format.
  /// The extension may be one of ".png", ".jpg", ".tif", or ".tga".
  ///
  /// To override the file extension, or use a file name without an
  /// extension, specify the desired [format].
  ///
  /// `save()` does not call [loadPixels]. The caller is responsible
  /// for ensuring that the [pixels] buffer contains the desired
  /// pixels to paint to the [file].
  Future<void> save({
    required File file,
    ImageFileFormat? format,
  }) async {
    if (pixels == null) {
      throw Exception('You must call loadPixels() before calling save()');
    }

    late ImageFileFormat imageFormat;
    if (format != null) {
      imageFormat = format;
    } else {
      final imageFormatFromFile = _getImageFileFormatFromFilePath(file.path);
      if (imageFormatFromFile == null) {
        throw Exception('Cannot save image to file with invalid extension and no explicit image type: ${file.path}');
      }
      imageFormat = imageFormatFromFile;
    }

    // Retrieve the pixel data for the current sketch painting.
    final rawImageData = pixels!.buffer.asUint8List();

    // Convert the pixel data to the desired format.
    late List<int> formattedImageData;
    switch (imageFormat) {
      case ImageFileFormat.png:
        formattedImageData = imageFormats.encodePng(
          imageFormats.Image.fromBytes(width, height, rawImageData),
        );
        break;
      case ImageFileFormat.jpeg:
        formattedImageData = imageFormats.encodeJpg(
          imageFormats.Image.fromBytes(width, height, rawImageData),
        );
        break;
      case ImageFileFormat.tiff:
        throw UnimplementedError('Tiff images are not supported in save()');
      case ImageFileFormat.targa:
        formattedImageData = imageFormats.encodeTga(
          imageFormats.Image.fromBytes(width, height, rawImageData),
        );
        break;
    }

    // Write the formatted pixels to the given file.
    await file.writeAsBytes(formattedImageData);
  }

  /// Saves a numbered sequence of images, one image each time the
  /// function is run, saved in the given [dirctory].
  ///
  /// By default, the generated file is named "screen-####.png", where
  /// the "####" is replaced by the index of the new image. The file
  /// index is the smallest number that doesn't conflict with an existing
  /// file in the given [directory].
  ///
  /// To customize the name of the files, provide the desired naming pattern
  /// to [namingPattern].
  ///
  /// The [namingPattern]'s extension is used to infer the desired image
  /// format. The extension may be one of ".png", ".jpg", ".tif", or ".tga".
  ///
  /// To override the file extension, or use a file name without an
  /// extension, provide the desired [format].
  ///
  /// `saveFrame()` does not call [loadPixels]. The caller is responsible
  /// for ensuring that the [pixels] buffer contains the desired pixels to
  /// paint to the file.
  Future<void> saveFrame({
    required Directory directory,
    String namingPattern = 'screen-####.png',
    ImageFileFormat? format,
  }) async {
    late ImageFileFormat imageFormat;
    if (format != null) {
      imageFormat = format;
    } else {
      final imageFormatFromFile = _getImageFileFormatFromFilePath(namingPattern);
      if (imageFormatFromFile == null) {
        throw Exception('Cannot save image to file with invalid extension and no explicit image type: $namingPattern');
      }
      imageFormat = imageFormatFromFile;
    }

    final hashMatcher = RegExp('(#)+');
    final hashMatches = hashMatcher.allMatches(namingPattern);
    if (hashMatches.isEmpty) {
      throw Exception('namingPattern is missing a hash pattern');
    } else if (hashMatches.length > 1) {
      throw Exception(
          'namingPattern has too many hash patterns in it. There must be exactly one series of hashes in namingPattern.');
    }

    final digitCount = hashMatches.first.end - hashMatches.first.start;

    int index = 0;
    late File file;
    do {
      final fileName = namingPattern.replaceAll(hashMatcher, '$index'.padLeft(digitCount, '0'));
      file = File('${directory.path}${Platform.pathSeparator}$fileName');
      index += 1;
    } while (file.existsSync());

    await save(file: file, format: imageFormat);
  }

  ImageFileFormat? _getImageFileFormatFromFilePath(String filePath) {
    final fileExtension = path.extension(filePath);
    switch (fileExtension) {
      case '.png':
        return ImageFileFormat.png;
      case '.jpg':
        return ImageFileFormat.jpeg;
      case '.tif':
        return ImageFileFormat.tiff;
      case '.tga':
        return ImageFileFormat.targa;
      default:
        return null;
    }
  }

  //------- Start Transform ------
  void translate({
    double? x,
    double? y,
    double? z,
  }) {
    if (z != null) {
      throw UnimplementedError('3D translations are not yet supported.');
    }

    _paintingContext.canvas.translate(x ?? 0, y ?? 0);

    _paintingContext.markHasUnappliedCanvasCommands();
  }

  void rotate(double angleInRadians) {
    _paintingContext.canvas.rotate(angleInRadians);
    _paintingContext.markHasUnappliedCanvasCommands();
  }

  // TODO: implement all other Processing APIs
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
