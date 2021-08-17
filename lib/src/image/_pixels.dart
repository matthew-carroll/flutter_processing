part of '../_core.dart';

mixin SketchImagePixels on BaseSketch {
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
      imageWidth: _paintingContext.size.width.round(),
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
    _paintingContext.canvas.drawImage(image, Offset.zero, Paint());
    _paintingContext.markHasUnappliedCanvasCommands();

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
}
