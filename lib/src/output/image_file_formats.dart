enum ImageFileFormat {
  png,
  jpeg,
  tiff,
  targa,
}

extension ImageMetaData on ImageFileFormat {
  String get extension {
    switch (this) {
      case ImageFileFormat.png:
        return 'png';
      case ImageFileFormat.jpeg:
        return 'jpg';
      case ImageFileFormat.tiff:
        return 'tif';
      case ImageFileFormat.targa:
        return 'tga';
    }
  }

  String get mimeType {
    switch (this) {
      case ImageFileFormat.png:
        return 'image/png';
      case ImageFileFormat.jpeg:
        return 'image/jepg';
      case ImageFileFormat.tiff:
        return 'image/tiff';
      case ImageFileFormat.targa:
        return 'image/targa';
    }
  }
}
