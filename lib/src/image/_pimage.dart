import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_processing/flutter_processing.dart';

/// An image in Processing.
///
/// `PImage` provides APIs for accessing and altering bitmap data.
///
/// Use [toFlutterImage] to obtain a dart:ui [Image] to draw with
/// Flutter.
class PImage {
  static Color blendColor(Color c1, Color c2, SketchBlendMode mode) {
    // Blend mode equations taken from Wikipedia:
    // https://en.wikipedia.org/wiki/Blend_modes
    switch (mode) {
      case SketchBlendMode.blend:
        return Color.lerp(c1, c2, 0.5)!;
      case SketchBlendMode.add:
        return _colorFromPercentARGB(
          1.0,
          (c1.redPercent + c2.redPercent).clamp(0.0, 1.0),
          (c1.greenPercent + c2.greenPercent).clamp(0.0, 1.0),
          (c1.bluePercent + c2.bluePercent).clamp(0.0, 1.0),
        );
      case SketchBlendMode.subtract:
        return _colorFromPercentARGB(
          1.0,
          (c1.redPercent - c2.redPercent).clamp(0.0, 1.0),
          (c1.greenPercent - c2.greenPercent).clamp(0.0, 1.0),
          (c1.bluePercent - c2.bluePercent).clamp(0.0, 1.0),
        );
      case SketchBlendMode.darkest:
        return c1.computeLuminance() < c2.computeLuminance() ? c1 : c2;
      case SketchBlendMode.lightest:
        return c1.computeLuminance() > c2.computeLuminance() ? c1 : c2;
      case SketchBlendMode.difference:
        return _colorFromPercentARGB(
          1.0,
          (c1.redPercent - c2.redPercent).abs(),
          (c1.greenPercent - c2.greenPercent).abs(),
          (c1.bluePercent - c2.bluePercent).abs(),
        );
      case SketchBlendMode.exclusion:
        return _colorFromPercentARGB(
          1.0,
          0.5 - 2 * (c1.redPercent - 0.5) * (c2.redPercent - 0.5),
          0.5 - 2 * (c1.greenPercent - 0.5) * (c2.greenPercent - 0.5),
          0.5 - 2 * (c1.bluePercent - 0.5) * (c2.bluePercent - 0.5),
        );
      case SketchBlendMode.multiply:
        return _colorFromPercentARGB(
          1.0,
          c1.redPercent * c2.bluePercent,
          c1.greenPercent * c2.greenPercent,
          c1.bluePercent * c2.bluePercent,
        );
      case SketchBlendMode.screen:
        return _colorFromPercentARGB(
          1.0,
          1 - ((1 - c1.redPercent) * (1 - c2.redPercent)),
          1 - ((1 - c1.greenPercent) * (1 - c2.greenPercent)),
          1 - ((1 - c1.bluePercent) * (1 - c2.bluePercent)),
        );
      case SketchBlendMode.overlay:
        return _colorFromPercentARGB(
          1.0,
          c1.redPercent < 0.5
              ? 2 * c1.redPercent * c2.redPercent
              : 1 - (2 * (1 - c1.redPercent) * (1 - c2.redPercent)),
          c1.greenPercent < 0.5
              ? 2 * c1.greenPercent * c2.greenPercent
              : 1 - (2 * (1 - c1.greenPercent) * (1 - c2.greenPercent)),
          c1.bluePercent < 0.5
              ? 2 * c1.bluePercent * c2.bluePercent
              : 1 - (2 * (1 - c1.bluePercent) * (1 - c2.bluePercent)),
        );
      case SketchBlendMode.hardLight:
        // This is the same as Overlay but with the c1 and c2's switched
        return _colorFromPercentARGB(
          1.0,
          c2.redPercent < 0.5
              ? 2 * c2.redPercent * c1.redPercent
              : 1 - (2 * (1 - c2.redPercent) * (1 - c1.redPercent)),
          c2.greenPercent < 0.5
              ? 2 * c2.greenPercent * c1.greenPercent
              : 1 - (2 * (1 - c2.greenPercent) * (1 - c1.greenPercent)),
          c2.bluePercent < 0.5
              ? 2 * c2.bluePercent * c1.bluePercent
              : 1 - (2 * (1 - c2.bluePercent) * (1 - c1.bluePercent)),
        );
      case SketchBlendMode.softLight:
        return _colorFromPercentARGB(
          1.0,
          (1 - (2 * c2.redPercent)) * (pow(c1.redPercent, 2)) +
              (2 * c2.redPercent * c1.redPercent),
          (1 - (2 * c2.greenPercent)) * (pow(c1.greenPercent, 2)) +
              (2 * c2.greenPercent * c1.greenPercent),
          (1 - (2 * c2.bluePercent)) * (pow(c1.bluePercent, 2)) +
              (2 * c2.bluePercent * c1.bluePercent),
        );
      case SketchBlendMode.dodge:
        return _colorFromPercentARGB(
          1.0,
          (c1.redPercent / (1 - c2.redPercent)).clamp(0, 1),
          (c1.greenPercent / (1 - c2.greenPercent)).clamp(0, 1),
          (c1.bluePercent / (1 - c2.bluePercent)).clamp(0, 1),
        );
      case SketchBlendMode.burn:
        return _colorFromPercentARGB(
          1.0,
          (1 - ((1 - c1.redPercent) / c2.redPercent)).clamp(0, 1),
          (1 - ((1 - c1.greenPercent) / c2.greenPercent)).clamp(0, 1),
          (1 - ((1 - c1.bluePercent) / c2.bluePercent)).clamp(0, 1),
        );
    }
  }

  PImage.empty(int width, int height, ImageFileFormat format)
      : _width = width,
        _height = height,
        _format = format {
    _pixels = ByteData(width * height * 4);
  }

  PImage.fromPixels(
      int width, int height, ByteData pixels, ImageFileFormat format)
      : _width = width,
        _height = height,
        _format = format,
        _pixels = pixels;

  final int _width;
  int get width => _width;

  final int _height;
  int get height => _height;

  final ImageFileFormat _format;
  ImageFileFormat get format => _format;

  late ByteData _pixels;
  ByteData get pixels => _pixels;

  /// Cached dart:io image that shows the same content as [pixels].
  ui.Image? _flutterImage;

  /// `true` if `_flutterImage` is out of date and needs to be
  /// redrawn before returning it from [toFlutterImage].
  bool _isFlutterImageDirty = true;

  /// Returns a dart:io [Image] version of this `PImage` so that it
  /// can be drawn with Flutter.
  Future<ui.Image> toFlutterImage() async {
    if (_isFlutterImageDirty) {
      final pixelsCodec = await ui.ImageDescriptor.raw(
        await ui.ImmutableBuffer.fromUint8List(pixels.buffer.asUint8List()),
        width: width.round(),
        height: height.round(),
        pixelFormat: ui.PixelFormat.rgba8888,
      ).instantiateCodec();

      _flutterImage = (await pixelsCodec.getNextFrame()).image;

      _isFlutterImageDirty = false;
    }

    return _flutterImage!;
  }

  Color get(int x, int y) {
    final pixelDataOffset = _getBitmapPixelOffset(
      imageWidth: width,
      x: x,
      y: y,
    );
    final rgbaColor = pixels.getUint32(pixelDataOffset);
    final argbColor =
        ((rgbaColor & 0x000000FF) << 24) | ((rgbaColor & 0xFFFFFF00) >> 8);
    return Color(argbColor);
  }

  Future<ui.Image> getRegion({
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final destinationData = Uint8List(width * height * 4);
    final rowLength = width * 4;

    for (int row = 0; row < height; row += 1) {
      final sourceRowOffset = _getBitmapPixelOffset(
        imageWidth: width,
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
        Uint8List.view(pixels.buffer, sourceRowOffset, rowLength),
      );
    }

    final codec = await ui.ImageDescriptor.raw(
      await ui.ImmutableBuffer.fromUint8List(destinationData),
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    ).instantiateCodec();

    return (await codec.getNextFrame()).image;
  }

  Future<void> loadPixels() async {
    // No-op: our pixels are always available in "pixels"
  }

  void set(int x, int y, Color color) {
    final pixelIndex = _getBitmapPixelOffset(
      imageWidth: width,
      x: x,
      y: y,
    );

    final argbColorInt = color.value;
    final rgbaColorInt = ((argbColorInt & 0xFF000000) >> 24) |
        ((argbColorInt & 0x00FFFFFF) << 8);
    pixels.setUint32(pixelIndex, rgbaColorInt);

    _isFlutterImageDirty = true;
  }

  Future<void> setRegion({
    required ui.Image image,
    int x = 0,
    int y = 0,
  }) async {
    // Use the Canvas to draw the given image at the desired offset.
    //
    // Using a canvas removes our responsibility to calculate appropriate
    // pixels offsets for a sub-region. However, this approach requires a
    // bunch of async calls that would otherwise be unnecessary.
    // TODO: copy pixels directly, using pixel offsets
    final pixelsCodec = await ui.ImageDescriptor.raw(
      await ui.ImmutableBuffer.fromUint8List(pixels.buffer.asUint8List()),
      width: width.round(),
      height: height.round(),
      pixelFormat: ui.PixelFormat.rgba8888,
    ).instantiateCodec();
    final me = (await pixelsCodec.getNextFrame()).image;

    final paint = Paint();

    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..drawImage(me, Offset.zero, paint)
      ..drawImage(image, Offset(x.toDouble(), y.toDouble()), paint);
    final picture = recorder.endRecording();

    final newImage = await picture.toImage(width, height);

    _pixels = (await newImage.toByteData())!;

    _isFlutterImageDirty = true;
  }

  Future<void> updatePixels() async {
    // No-op: our pixels are always updated
  }

  int _getBitmapPixelOffset({
    required int imageWidth,
    required int x,
    required int y,
  }) {
    return ((y * imageWidth) + x) * 4;
  }

  void resize() {
    // TODO:
    throw UnimplementedError();

    _isFlutterImageDirty = true;
  }

  void mask({
    PImage? maskImage,
    ByteData? maskPixels,
  }) {
    if (maskImage == null && maskPixels == null) {
      throw Exception(
          "PImage#mask() requires either a maskImage or maskPixels");
    }
    if (maskImage != null && maskPixels != null) {
      throw Exception(
          "PImage#mask() should be given a maskImage or maskPixels, but not both");
    }

    // TODO:
    throw UnimplementedError();

    _isFlutterImageDirty = true;
  }

  void filter(ImageFilter filter, [double? value]) {
    switch (filter) {
      case ImageFilter.threshold:
        assert(value != null);
        _applyPixelTransform(
            this,
            this,
            (_, __, x, y, colorIn) => HSVColor.fromColor(colorIn).value > value!
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF000000));
        break;
      case ImageFilter.gray:
        _applyPixelTransform(
            this,
            this,
            (_, __, x, y, colorIn) =>
                HSVColor.fromColor(colorIn).withSaturation(0).toColor());
        break;
      case ImageFilter.opaque:
        _applyPixelTransform(
            this, this, (_, __, x, y, colorIn) => colorIn.withOpacity(1.0));
        break;
      case ImageFilter.invert:
        _applyPixelTransform(
            this,
            this,
            (_, __, x, y, colorIn) => _colorFromPercentARGB(
                  colorIn.opacity,
                  1.0 - colorIn.redPercent,
                  1.0 - colorIn.greenPercent,
                  1.0 - colorIn.bluePercent,
                ));
        break;
      case ImageFilter.posterize:
        if (value == null) {
          throw Exception("You must provide a value to posterize an image");
        }
        if (value < 2 || value > 255) {
          throw Exception("The posterize value must be between [2, 255]");
        }

        final level = value.round();

        // Filter code adapted from the P5.js implementation
        _applyPixelTransform(
            this,
            this,
            (_, __, x, y, colorIn) => Color.fromARGB(
                  colorIn.alpha,
                  (((colorIn.red * level) >> 8) * 255 / (level - 1)).round(),
                  (((colorIn.green * level) >> 8) * 255 / (level - 1)).round(),
                  (((colorIn.blue * level) >> 8) * 255 / (level - 1)).round(),
                ));
        break;
      case ImageFilter.erode:
        final outBuffer = copy();
        _applyPixelTransform(this, outBuffer, _erode);
        _pixels = outBuffer.pixels;
        break;
      case ImageFilter.dilate:
        final outBuffer = copy();
        _applyPixelTransform(this, outBuffer, _dilate);
        _pixels = outBuffer.pixels;
        break;
      case ImageFilter.blur:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _erode(PImage source, PImage dest, int x, int y, Color colorIn) {
    // This implementation was adapted from P5.js
    final colorLeft = x > 0 ? source.get(x - 1, y) : colorIn;
    final colorRight = x < width - 1 ? source.get(x + 1, y) : colorIn;
    final colorUp = y > 0 ? source.get(x, y - 1) : colorIn;
    final colorDown = y < height - 1 ? source.get(x, y + 1) : colorIn;

    final lumIn = colorIn.computeLuminance();
    final lumLeft = colorLeft.computeLuminance();
    final lumRight = colorRight.computeLuminance();
    final lumUp = colorUp.computeLuminance();
    final lumDown = colorDown.computeLuminance();

    // Find the neighboring color with the lowest luminance and
    // use that as the out-bound color.
    Color colorOut = colorIn;
    double lumOut = lumIn;
    if (lumLeft < lumOut) {
      colorOut = colorLeft;
      lumOut = lumLeft;
    }
    if (lumRight < lumOut) {
      colorOut = colorRight;
      lumOut = lumRight;
    }
    if (lumUp < lumOut) {
      colorOut = colorUp;
      lumOut = lumUp;
    }
    if (lumDown < lumOut) {
      colorOut = colorDown;
      lumOut = lumDown;
    }

    return colorOut;
  }

  Color _dilate(PImage source, PImage dest, int x, int y, Color colorIn) {
    // This implementation was adapted from P5.js
    final colorLeft = x > 0 ? source.get(x - 1, y) : colorIn;
    final colorRight = x < width - 1 ? source.get(x + 1, y) : colorIn;
    final colorUp = y > 0 ? source.get(x, y - 1) : colorIn;
    final colorDown = y < height - 1 ? source.get(x, y + 1) : colorIn;

    final lumIn = colorIn.computeLuminance();
    final lumLeft = colorLeft.computeLuminance();
    final lumRight = colorRight.computeLuminance();
    final lumUp = colorUp.computeLuminance();
    final lumDown = colorDown.computeLuminance();

    // Find the neighboring color with the lowest luminance and
    // use that as the out-bound color.
    Color colorOut = colorIn;
    double lumOut = lumIn;
    if (lumLeft > lumOut) {
      colorOut = colorLeft;
      lumOut = lumLeft;
    }
    if (lumRight > lumOut) {
      colorOut = colorRight;
      lumOut = lumRight;
    }
    if (lumUp > lumOut) {
      colorOut = colorUp;
      lumOut = lumUp;
    }
    if (lumDown > lumOut) {
      colorOut = colorDown;
      lumOut = lumDown;
    }

    return colorOut;
  }

  void _applyPixelTransform(
      PImage source, PImage dest, _PixelTransform transform) {
    for (int col = 0; col < width; col += 1) {
      for (int row = 0; row < height; row += 1) {
        final oldColor = source.get(col, row);
        final newColor = transform(source, dest, col, row, oldColor);
        dest.set(col, row, newColor);
      }
    }

    _isFlutterImageDirty = true;
  }

  PImage copy([Rect? rect]) {
    final copyRect =
        rect ?? Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    if (copyRect.left < 0 ||
        copyRect.top < 0 ||
        copyRect.right > width ||
        copyRect.bottom > height) {
      throw Exception(
          "Invalid copy region passed to PImage#copy. Image size: ${width}x$height, rect: $copyRect");
    }
    print("Copy rect: $copyRect");

    final newImage = PImage.empty(
        copyRect.width.round(), copyRect.height.round(), ImageFileFormat.png);
    final colStart = copyRect.left.round();
    final colEnd = copyRect.right.round();
    final rowStart = copyRect.top.round();
    final rowEnd = copyRect.bottom.round();

    for (int col = colStart; col < colEnd; col += 1) {
      for (int row = rowStart; row < rowEnd; row += 1) {
        newImage.set(col - colStart, row - rowStart, get(col, row));
      }
    }

    return newImage;
  }

  /// Copies pixels into this `PImage` from the given [source], or
  /// replicates a region of this `PImage` within itself if no
  /// source is provided.
  ///
  /// The [sourceRect] is the area that is copied, and the
  /// [destRect] is the area within this `PImage` where the
  /// copy will painted.
  void copyFrom({
    PImage? source,
    required Rect sourceRect,
    required Rect destRect,
  }) {
    source ??= this;

    final copyImage = source.copy(sourceRect);

    _add(copyImage, destRect.topLeft);
  }

  void _add(PImage source, Offset destOrigin) {
    for (int sourceCol = 0; sourceCol < source.width; sourceCol += 1) {
      final destCol = destOrigin.dx.round() + sourceCol;
      if (destCol < 0) {
        // The source image has an origin off the left side of
        // this image. Skip all the columns to left of us.
        continue;
      }
      if (destCol >= width) {
        // The source image goes further to the right than we do.
        // There's nothing more for us to paint into ourself.
        break;
      }

      for (int sourceRow = 0; sourceRow < source.height; sourceRow += 1) {
        final destRow = destOrigin.dy.round() + sourceRow;
        if (destRow < 0) {
          // The source image has an origin above the top side of
          // this image. Skip all the rows above us.
          continue;
        }
        if (destRow >= height) {
          // The source image goes further down than we do.
          // There are no more rows for us to paint into ourself
          // for this column.
          break;
        }

        // Copy a pixel from source to destination.
        set(destCol, destRow, source.get(sourceCol, sourceRow));
      }
    }
  }

  void blend(
    PImage other, {
    required Rect sourceRect,
    required Rect destRect,
    required SketchBlendMode mode,
  }) {
    if (sourceRect.width != destRect.width) {
      throw Exception(
          "PImage#blend() source and destination rects must have same width. Actually: ${sourceRect.width} vs ${destRect.width}");
    }
    if (sourceRect.height != destRect.height) {
      throw Exception(
          "PImage#blend() source and destination rects must have same height. Actually: ${sourceRect.height} vs ${destRect.height}");
    }

    final sourceOrigin = sourceRect.topLeft;
    final destOrigin = destRect.topLeft;
    for (int col = 0; col < sourceRect.width; col += 1) {
      for (int row = 0; row < sourceRect.height; row += 1) {
        final pixelBlendColor = blendColor(
          get(col + sourceOrigin.dx.floor(), row + sourceOrigin.dy.floor()),
          other.get(col + destOrigin.dx.floor(), row + destOrigin.dy.floor()),
          mode,
        );

        set(
          col + sourceOrigin.dx.floor(),
          row + sourceOrigin.dy.floor(),
          pixelBlendColor,
        );
      }
    }

    _isFlutterImageDirty = true;
  }

  Future<void> save(String fileName) async {
    throw UnimplementedError();
  }
}

enum SketchBlendMode {
  blend,
  add,
  subtract,
  darkest,
  lightest,
  difference,
  exclusion,
  multiply,
  screen,
  overlay,
  hardLight,
  softLight,
  dodge,
  burn,
}

enum ImageFilter {
  threshold,
  gray,
  opaque,
  invert,
  posterize,
  blur,
  erode,
  dilate,
}

typedef _PixelTransform = Color Function(
    PImage source, PImage dest, int x, int y, Color colorIn);

Color _colorFromPercentARGB(
        double alpha, double red, double green, double blue) =>
    Color.fromARGB(
      (alpha * 255).round(),
      (red * 255).round(),
      (green * 255).round(),
      (blue * 255).round(),
    );

extension on Color {
  double get redPercent => red.toDouble() / 255;

  double get greenPercent => green.toDouble() / 255;

  double get bluePercent => blue.toDouble() / 255;
}

extension on ByteData {
  Color get(int imageWidth, int x, int y) =>
      Color(getUint32(getPixelIndex(imageWidth, x, y)));

  set(int imageWidth, int x, int y, Color color) =>
      setUint32(getPixelIndex(imageWidth, x, y), color.value);

  int getPixelIndex(int imageWidth, int x, int y) => (y * imageWidth + x) * 4;

  ByteData copy() {
    final copyBytes = ByteData(this.lengthInBytes);
    for (int i = 0; i < lengthInBytes; i += 1) {
      copyBytes.setUint8(i, this.getUint8(i));
    }
    return copyBytes;
  }
}
