part of '../_core.dart';

mixin SketchImageLoadingAndDisplaying on BaseSketch {
  Future<Image> loadImage(String filepath) async {
    final imageData = await _assetBundle!.load(filepath);
    final codec = await (await ImageDescriptor.encoded(
      await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
    ))
        .instantiateCodec();

    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<PImage> loadPImage(String filepath) async {
    final imageData = await _assetBundle!.load(filepath);
    final codec = await (await ImageDescriptor.encoded(
      await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
    ))
        .instantiateCodec();

    final frame = await codec.getNextFrame();
    return PImage.fromPixels(
      frame.image.width,
      frame.image.height,
      (await frame.image.toByteData())!,
      // TODO: choose image type by extension
      ImageFileFormat.png,
    );
  }

  void image({
    required Image image,
    Offset origin = Offset.zero,
    double? width,
    double? height,
  }) {
    final horizontalScale = width != null ? width / image.width : 1.0;
    final verticalScale = height != null ? height / image.height : 1.0;

    _paintingContext.canvas
      ..save()
      ..translate(origin.dx, origin.dy)
      ..scale(horizontalScale, verticalScale)
      ..drawImage(image, Offset.zero, Paint())
      ..restore();

    _paintingContext.markHasUnappliedCanvasCommands();
  }

  Future<void> pImage({
    required PImage image,
    Offset origin = Offset.zero,
    double? width,
    double? height,
  }) async {
    final horizontalScale = width != null ? width / image.width : 1.0;
    final verticalScale = height != null ? height / image.height : 1.0;

    final flutterImage = await image.toFlutterImage();

    _paintingContext.canvas
      ..save()
      ..translate(origin.dx, origin.dy)
      ..scale(horizontalScale, verticalScale)
      ..drawImage(flutterImage, Offset.zero, Paint())
      ..restore();

    _paintingContext.markHasUnappliedCanvasCommands();
  }
}
