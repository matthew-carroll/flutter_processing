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

  void image({
    required Image image,
    Offset origin = Offset.zero,
    Size? displaySize,
  }) {
    // TODO: implement displaySize support.
    _paintingContext.canvas.drawImage(image, origin, Paint());

    _paintingContext.markHasUnappliedCanvasCommands();
  }
}
