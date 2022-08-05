part of '../_core.dart';

mixin SketchImageLoadingAndDisplaying on BaseSketch {
  Future<PImage> loadImage(String filepath) async {
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

  Future<void> image({
    required PImage image,
    Offset origin = Offset.zero,
    double? width,
    double? height,
  }) async {
    print("PaintingContext before: ${_paintingContext.hashCode}");
    print("Canvas before image() load: ${_paintingContext.canvas.canvas.hashCode}");
    final horizontalScale = width != null ? width / image.width : 1.0;
    final verticalScale = height != null ? height / image.height : 1.0;

    final flutterImage = await image.toFlutterImage();

    print("PaintingContext after: ${_paintingContext.hashCode}");
    print("Canvas after image() load: ${_paintingContext.canvas.canvas.hashCode}");
    _paintingContext.canvas
      ..save()
      ..translate(origin.dx, origin.dy)
      ..scale(horizontalScale, verticalScale)
      ..drawImage(flutterImage, Offset.zero, Paint())
      ..restore();
  }
}
