import 'dart:typed_data';
import 'dart:ui';

/// Bitmap painter, which forms the core painting APIs for Flutter Processing.
///
/// Clients must adhere to the lifecycle contract of this object.
///
/// **Start a new frame:**
/// [startRecording()], which prepares a new frame for painting.
///
/// **Paint desired content:**
///
///  * Call any [canvas] commands.
///  * [doIntermediateRasterization()], which immediately rasterizes
///    any queued [Canvas] commands to [intermediateImage].
///  * [loadPixels()], which runs [doIntermediateRasterization()],
///    and then makes the pixel data in [intermediateImage] available via
///    the [pixels] property.
///
/// **Produce the final frame image:**
/// [finishRecording()], which produces the final [publishedImage].
class SketchPaintingContext {
  SketchPaintingContext({
    this.size = const Size(100, 100),
  });

  /// The size of the painting region.
  Size size;

  late PictureRecorder _recorder;
  late Canvas _canvas;

  /// The target for drawing commands.
  ///
  /// A [Canvas] collects drawing operations, which are eventually
  /// send to the GPU for rasterization.
  ///
  /// Direct pixel manipulation is incompatible with a [Canvas], and
  /// drawing commands, so before manipulating any pixels directly,
  /// clients should invoke [doIntermediateRasterization()] or
  /// [loadPixels()], depending on the client's needs.
  Canvas get canvas => _canvas;

  /// The [Paint] that all clients should use when filling a shape.
  late Paint fillPaint;

  /// The [Paint] that all clients should use when drawing a stroke.
  late Paint strokePaint;

  Image? _intermediateImage;

  /// A bitmap image, to which the latest [Canvas] commands are
  /// applied each time [doIntermediateRasterization()] is called.
  Image? get intermediateImage => _intermediateImage;

  ByteData? _pixels;

  /// A pixel buffer that's loaded whenever a client calls
  /// [loadPixels()].
  ByteData? get pixels => _pixels;

  bool _hasUnappliedCanvasCommands = false;

  /// Informs this [SketchPaintingContext] that there is some number
  /// of [Canvas] commands which have not yet been rasterized to
  /// [intermediateImage].
  void markHasUnappliedCanvasCommands() => _hasUnappliedCanvasCommands = true;

  Image? _publishedImage;

  /// The latest image to be produced by this [SketchPaintingContext].
  Image? get publishedImage => _publishedImage;

  /// Starts a new frame painting.
  void startRecording() {
    // By default, the fill color is white and the stroke is 1px black.
    fillPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    strokePaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    _intermediateImage = null;

    _recorder = PictureRecorder();
    _canvas = Canvas(_recorder);
  }

  /// Does an intermediate rasterization into [intermediateImage] and then
  /// loads the rasterized data into [pixels].
  ///
  /// If there are no intermediate drawing operations since the previous
  /// frame, then [publishedImage] is loaded into [pixels].
  Future<void> loadPixels() async {
    await doIntermediateRasterization();

    final sourceImage = (intermediateImage ?? publishedImage)!;
    _pixels = await sourceImage.toByteData();
  }

  /// Paints the latest [pixels] onto the [canvas].
  ///
  /// This operation is the logical inverse of [loadPixels()].
  Future<void> updatePixels() async {
    if (pixels == null) {
      throw Exception('Must call loadPixels() before calling updatePixels()');
    }

    final pixelsCodec = await ImageDescriptor.raw(
      await ImmutableBuffer.fromUint8List(pixels!.buffer.asUint8List()),
      width: size.width.round(),
      height: size.height.round(),
      pixelFormat: PixelFormat.rgba8888,
    ).instantiateCodec();

    final pixelsImage = (await pixelsCodec.getNextFrame()).image;

    canvas.drawImage(pixelsImage, Offset.zero, Paint());
    markHasUnappliedCanvasCommands();
  }

  /// Immediately applies any outstanding [canvas] operations to
  /// produce a new [intermediateImage] bitmap.
  Future<void> doIntermediateRasterization() async {
    if (!_hasUnappliedCanvasCommands) {
      // There are no commands to rasterize
      return;
    }

    _intermediateImage = await _rasterize();

    _recorder = PictureRecorder();
    _canvas = Canvas(_recorder)..drawImage(_intermediateImage!, Offset.zero, Paint());

    _hasUnappliedCanvasCommands = false;
  }

  /// Rasterizes any outstanding [canvas] commands to produce a new [publishedImage].
  Future<void> finishRecording() async {
    _publishedImage = await _rasterize();
  }

  Future<Image> _rasterize() async {
    final picture = _recorder.endRecording();
    return await picture.toImage(size.width.round(), size.height.round());
  }
}
