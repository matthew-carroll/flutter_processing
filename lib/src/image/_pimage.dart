import 'dart:io';
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
          c1.redPercent < 0.5 ? 2 * c1.redPercent * c2.redPercent : 1 - (2 * (1 - c1.redPercent) * (1 - c2.redPercent)),
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
          c2.redPercent < 0.5 ? 2 * c2.redPercent * c1.redPercent : 1 - (2 * (1 - c2.redPercent) * (1 - c1.redPercent)),
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
          (1 - (2 * c2.redPercent)) * (pow(c1.redPercent, 2)) + (2 * c2.redPercent * c1.redPercent),
          (1 - (2 * c2.greenPercent)) * (pow(c1.greenPercent, 2)) + (2 * c2.greenPercent * c1.greenPercent),
          (1 - (2 * c2.bluePercent)) * (pow(c1.bluePercent, 2)) + (2 * c2.bluePercent * c1.bluePercent),
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

  PImage.fromPixels(int width, int height, ByteData pixels, ImageFileFormat format)
      : _width = width,
        _height = height,
        _format = format,
        _pixels = pixels;

  int _width;
  int get width => _width;

  int _height;
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

  /// Returns a dart:io [Image] version of this [PImage] so that it
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

  /// Returns the ARGB color of the pixel at the given ([x], [y]).
  Color get(int x, int y) {
    final rgbaColor = pixels.getPixel(width, x, y).value;
    final argbColor = ((rgbaColor & 0x000000FF) << 24) | ((rgbaColor & 0xFFFFFF00) >> 8);
    return Color(argbColor);
  }

  /// Sets the ARGB [color] of the pixel at the given ([x],[y]).
  void set(int x, int y, Color color) {
    final argbColorInt = color.value;
    final rgbaColorInt = ((argbColorInt & 0xFF000000) >> 24) | ((argbColorInt & 0x00FFFFFF) << 8);
    pixels.setPixel(width, x, y, Color(rgbaColorInt));

    _isFlutterImageDirty = true;
  }

  /// Creates a returns a new [PImage] that replicates a region of this
  /// [PImage], defined by the given ([x],[y]) origin and the given
  /// [width] and [height].
  Future<PImage> getRegion({
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

    return PImage.fromPixels(width, height, ByteData.view(destinationData.buffer), format);
  }

  /// Copies the given [image] into this [PImage] at the given ([x],[y]).
  ///
  /// Any pixels in [image] that exceeds the available space in this [PImage]
  /// are ignored.
  ///
  /// The given ([x],[y]) must sit within the bounds of this [PImage].
  void setRegion({
    required PImage image,
    int x = 0,
    int y = 0,
  }) {
    if (x < 0) {
      throw Exception("x must be >= 0: $x");
    }
    if (x >= width) {
      throw Exception("x must be < this image's width - width: $width, y: $y");
    }
    if (y < 0) {
      throw Exception("y must be >= 0: $y");
    }
    if (y >= height) {
      throw Exception("y must be < this image's height - height: $height, y: $y");
    }

    for (int destX = x; (destX - x) < image.width && destX < this.width; x += 1) {
      for (int destY = y; (destY - y) < image.height && destY < this.height; y += 1) {
        set(destX, destY, image.get(destX - x, destY - y));
      }
    }
  }

  /// Loads this image's pixels into an pixel in-memory buffer.
  ///
  /// This is a no-op for [PImage] because pixels are always kept in
  /// an in-memory buffer.
  Future<void> loadPixels() async {
    // No-op: our pixels are always available in "pixels"
  }

  /// Applies all recent operations to the in-memory pixel buffer.
  ///
  /// This is a no-op for [PImage] because pixels are always kept in
  /// an in-memory buffer.
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

  /// Resizes this [PImage] to the given [width] and [height].
  ///
  /// The pixels in this [PImage] are scaled up or down in the x and
  /// y direction, to satisfy the given dimensions.
  ///
  /// To scale proportionally, pass in just a [width], or just a [height].
  /// The dimension that you leave out will be scaled up/down to retain
  /// the original aspect ratio of this [PImage].
  void resize({
    int? width,
    int? height,
  }) {
    if (width == null && height == null) {
      // This indicates no change in size. Don't do anything.
      return;
    }

    final newWidth = (width ?? (height! / this.height) * this.width).toInt();
    final newHeight = (height ?? (width! / this.width) * this.height).toInt();

    final newPixelBuffer = ByteData(newWidth * newHeight * 4);

    for (int x = 0; x < newWidth; x += 1) {
      for (int y = 0; y < newHeight; y += 1) {
        final sampledX = ((x / newWidth) * this.width).round();
        final sampledY = ((y / newHeight) * this.height).round();

        // TODO: de-dup this color calculation with the set() method. Consider creating
        //       a PixelBuffer class
        final argbColorInt = get(sampledX, sampledY).value;
        final rgbaColorInt = ((argbColorInt & 0xFF000000) >> 24) | ((argbColorInt & 0x00FFFFFF) << 8);

        newPixelBuffer.setPixel(newWidth, x, y, Color(rgbaColorInt));
      }
    }

    // Switch the new pixel buffer for the standard pixel buffer in this PImage.
    _pixels = newPixelBuffer;
    _width = newWidth;
    _height = newHeight;

    _isFlutterImageDirty = true;
  }

  /// Masks this [PImage] with the given [maskImage] or the given [maskPixels].
  ///
  /// [maskImage] or [maskPixels] must be provided, but not both.
  ///
  /// If a [maskImage] is provided, the alpha channel in this [PImage] is set
  /// equal to the blue channel of the pixels in the [maskImage]. A [maskImage]
  /// pixel with a blue value of `255` will fully reveal the pixel within this
  /// [PImage]. A pixel with a blue value of `0` will fully erase the pixel
  /// within this [PImage].
  ///
  /// If [maskPixels] is provided, the pixel alpha values in this [PImage] are
  /// set equal to the given [maskPixels] values.
  void mask({
    PImage? maskImage,
    List<int>? maskPixels,
  }) {
    if (maskImage == null && maskPixels == null) {
      throw Exception("PImage#mask() requires either a maskImage or maskPixels");
    }
    if (maskImage != null && maskPixels != null) {
      throw Exception("PImage#mask() should be given a maskImage or maskPixels, but not both");
    }
    if (maskImage != null) {
      if (maskImage.width != width || maskImage.height != height) {
        throw Exception(
            "PImage#mask() must use a maskImage (${maskImage.width}, ${maskImage.height}) with the same dimensions as the base image: ($width, $height)");
      }
    }
    if (maskPixels != null) {
      if (maskPixels.length != width * height) {
        throw Exception(
            "PImage#mask() must receive a maskPixels (${maskPixels.length}) with the same number of pixels as the base image (${width * height})");
      }
    }

    if (maskImage != null) {
      for (int x = 0; x < width; x += 1) {
        for (int y = 0; y < height; y += 1) {
          final existingColor = get(x, y);
          final maskAlpha = maskImage.get(x, y).blue;
          final newColor = maskAlpha == 0 ? const Color(0x00000000) : existingColor.withAlpha(maskAlpha);
          set(x, y, newColor);
        }
      }
    } else {
      for (int x = 0; x < width; x += 1) {
        for (int y = 0; y < height; y += 1) {
          final existingColor = get(x, y);
          final maskAlpha = maskPixels![_getBitmapPixelOffset(imageWidth: width, x: x, y: y)];
          final newColor = maskAlpha == 0 ? const Color(0x00000000) : existingColor.withAlpha(maskAlpha);
          set(x, y, newColor);
        }
      }
    }

    _isFlutterImageDirty = true;
  }

  void filter(ImageFilter filter, [double? value]) {
    switch (filter) {
      case ImageFilter.threshold:
        assert(value != null);
        _applyPixelTransform(
            this,
            this,
            (_, __, x, y, colorIn) =>
                HSVColor.fromColor(colorIn).value > value! ? const Color(0xFFFFFFFF) : const Color(0xFF000000));
        break;
      case ImageFilter.gray:
        _applyPixelTransform(
            this, this, (_, __, x, y, colorIn) => HSVColor.fromColor(colorIn).withSaturation(0).toColor());
        break;
      case ImageFilter.opaque:
        _applyPixelTransform(this, this, (_, __, x, y, colorIn) => colorIn.withOpacity(1.0));
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

  /// Runs the given [transform] function across every pixel in the [source]
  /// image, painting the transformed pixel value into the [dest] image.
  ///
  /// [source] and [dest] must have the same dimensions.
  void _applyPixelTransform(PImage source, PImage dest, _PixelTransform transform) {
    for (int col = 0; col < width; col += 1) {
      for (int row = 0; row < height; row += 1) {
        final oldColor = source.get(col, row);
        final newColor = transform(source, dest, col, row, oldColor);
        dest.set(col, row, newColor);
      }
    }

    _isFlutterImageDirty = true;
  }

  /// Copies and returns all, or part of, this [PImage].
  PImage copy([Rect? rect]) {
    final copyRect = rect ?? Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    if (copyRect.left < 0 || copyRect.top < 0 || copyRect.right > width || copyRect.bottom > height) {
      throw Exception("Invalid copy region passed to PImage#copy. Image size: ${width}x$height, rect: $copyRect");
    }

    final newImage = PImage.empty(copyRect.width.round(), copyRect.height.round(), ImageFileFormat.png);
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

  /// Blends pixels from the [other] image into this [PImage], using the
  /// given blend [mode].
  ///
  /// The [sourceRect] is the rectangle within the [other] image that's
  /// copied and blended into this [PImage]. The [destRect] is the rectangle
  /// within this [PImage] where the blend is painted. [sourceRect] and
  /// [destRect] must have the same dimensions.
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

  /// Saves this [PImage] to a file at the given [filePath].
  ///
  /// The [filePath] must include the file extension, and the extension
  /// determines the file format. The extension can be one of: ".png", ".jpg",
  /// ".tiff", ".tga".
  Future<void> save(String filePath) async {
    final file = File(filePath);
    saveBytesToFile(
      file: file,
      imageData: _pixels.buffer.asUint8List(),
      width: width,
      height: height,
    );
  }
}

/// Available modes for blending two pixels together.
///
/// These blend modes are similar to what you'll find in Photoshop, or
/// other bitmap manipulation tools.
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

/// Available pixel filters for [PImage]s.
///
/// Each [ImageFilter] represents a transformation that's applied to
/// pixels within an image. For example, [ImageFilter.gray] converts
/// all pixels to grayscale values, and [ImageFilter.invert] changes
/// every pixel color to the color that sits opposite in color space.
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

/// Function that calculates a new pixel color based on an existing [colorIn], as
/// well as the position of that pixel within a [source] image.
///
/// This signature is roughly equivalent to the information that's normally passed
/// to a GPU fragment shader, thus allowing for "software shaders", which are
/// dramatically less performant, but they can be written in Dart instead of
/// special shader languages.
typedef _PixelTransform = Color Function(PImage source, PImage dest, int x, int y, Color colorIn);

/// Creates a [Color] from ARGB percentage values.
Color _colorFromPercentARGB(double alpha, double red, double green, double blue) => Color.fromARGB(
      (alpha * 255).round(),
      (red * 255).round(),
      (green * 255).round(),
      (blue * 255).round(),
    );

/// Extension on [Color] that provides access to each color component as
/// a percentage, rather than an `int` in [0, 255].
extension on Color {
  double get redPercent => red.toDouble() / 255;

  double get greenPercent => green.toDouble() / 255;

  double get bluePercent => blue.toDouble() / 255;
}

/// Extension on [ByteData] that treats the bytes as pixels, providing common
/// image-related data access, e.g., retrieving an individual pixel value.
extension on ByteData {
  /// Returns the pixel color value at the given ([x],[y]), assuming the
  /// given [imageWidth].
  Color getPixel(int imageWidth, int x, int y) => Color(getUint32(getPixelIndex(imageWidth, x, y)));

  /// Sets the pixel color value at the given ([x],[y]), assuming the
  /// given [imageWidth].
  setPixel(int imageWidth, int x, int y, Color color) => setUint32(getPixelIndex(imageWidth, x, y), color.value);

  /// Calculates the byte index within this [ByteData] for the pixel at
  /// ([x],[y]), assuming the given [imageWidth].
  int getPixelIndex(int imageWidth, int x, int y) => (y * imageWidth + x) * 4;

  /// Copies all the data in this [ByteData] to a new [ByteData]
  /// and returns it.
  ByteData copy() {
    final copyBytes = ByteData(this.lengthInBytes);
    for (int i = 0; i < lengthInBytes; i += 1) {
      copyBytes.setUint8(i, this.getUint8(i));
    }
    return copyBytes;
  }
}
