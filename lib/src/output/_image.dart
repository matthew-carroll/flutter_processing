part of '../_core.dart';

mixin SketchOutputImage on BaseSketch {
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
    if (_paintingContext.pixels == null) {
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
    final rawImageData = _paintingContext.pixels!.buffer.asUint8List();

    // Convert the pixel data to the desired format.
    late List<int> formattedImageData;
    switch (imageFormat) {
      case ImageFileFormat.png:
        formattedImageData = imageFormats.encodePng(
          imageFormats.Image.fromBytes(
              _paintingContext.size.width.round(), _paintingContext.size.height.round(), rawImageData),
        );
        break;
      case ImageFileFormat.jpeg:
        formattedImageData = imageFormats.encodeJpg(
          imageFormats.Image.fromBytes(
              _paintingContext.size.width.round(), _paintingContext.size.height.round(), rawImageData),
        );
        break;
      case ImageFileFormat.tiff:
        throw UnimplementedError('Tiff images are not supported in save()');
      case ImageFileFormat.targa:
        formattedImageData = imageFormats.encodeTga(
          imageFormats.Image.fromBytes(
              _paintingContext.size.width.round(), _paintingContext.size.height.round(), rawImageData),
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
}
