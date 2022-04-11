part of '../_core.dart';

mixin SketchTypography on BaseSketch {
  String? _fontName;
  double _fontSize = 24;
  double? _textLeading;
  TextAlignHorizontal _textAlignHorizontal = TextAlignHorizontal.left;
  TextAlignVertical _textAlignVertical = TextAlignVertical.top;

  void createFont() {
    throw UnimplementedError(
        "You don't need to 'createFont()' in flutter_processing. Instead, use the standard Flutter font configurations in pubspec.yaml.");
  }

  void loadFont() {
    throw UnimplementedError(
        "You don't need to 'loadFont()' in flutter_processing. Instead, use the standard Flutter font configurations in pubspec.yaml.");
  }

  /// Set the font used to render text by providing a [fontName].
  void textFont(String fontName) {
    _fontName = fontName;
  }

  /// Paint the given [text] at the given ([x],[y]), using the current
  /// horizontal and vertical text alignment and text size.
  void text(String text, double x, double y) {
    final paragraphBuilder = ParagraphBuilder(ParagraphStyle(
      fontFamily: _fontName,
      fontSize: _fontSize,
      textAlign: _textAlignHorizontal.toFlutterAlign(),
    ))
      ..pushStyle(TextStyle(
        color: _paintingContext.fillPaint.color,
        height: _textLeading != null ? _textLeading! / _fontSize : null,
      ))
      ..addText(text);
    final paragraph = paragraphBuilder.build()
      ..layout(
        const ParagraphConstraints(width: double.infinity),
      );

    late double textX;
    late double textY;
    switch (_textAlignHorizontal) {
      case TextAlignHorizontal.left:
        textX = x;
        break;
      case TextAlignHorizontal.center:
        textX = x - (paragraph.maxIntrinsicWidth / 2);
        break;
      case TextAlignHorizontal.right:
        textX = x - paragraph.maxIntrinsicWidth;
        break;
    }

    switch (_textAlignVertical) {
      case TextAlignVertical.top:
        // We adjust the top alignment to deal with leading. Flutter applies extra
        // leading to the first line of text, but Processing wants the top of the
        // first line to sit exactly on the given `y` value. We do our best to
        // correct for that, here.
        final firstCharacterHeight = paragraph.getBoxesForRange(0, 1).first.toRect().height;
        final leadingAdjustment = _textLeading != null ? (_textLeading! - firstCharacterHeight) : 0;

        textY = y - leadingAdjustment;
        break;
      case TextAlignVertical.center:
        textY = y - (paragraph.height / 2);
        break;
      case TextAlignVertical.baseline:
        textY = y - paragraph.alphabeticBaseline;
        break;
      case TextAlignVertical.bottom:
        textY = y - paragraph.height;
        break;
    }

    _paintingContext.canvas.drawParagraph(paragraph, Offset(textX, textY));
  }

  /// Set the horizontal and vertical text alignment for text that's painted
  /// with the [text()] method.
  void textAlign(TextAlignHorizontal horizontalAlignment, [TextAlignVertical? verticalAlignment]) {
    _textAlignHorizontal = horizontalAlignment;
    _textAlignVertical = verticalAlignment ?? TextAlignVertical.baseline;
  }

  /// Sets the leading for text that is painted with the [text()] method.
  void textLeading(double leading) {
    _textLeading = leading;
  }

  /// Sets the size of the text that is painted with the [text()] method.
  void textSize(double fontSize) {
    _fontSize = fontSize;
    _textLeading = null;
  }

  /// Calculates and returns the width of the given [text], sized and spaced
  /// based on the current text configuration.
  double textWidth(String text) {
    final paragraphBuilder = ParagraphBuilder(ParagraphStyle(
      fontFamily: _fontName,
      fontSize: _fontSize,
      textAlign: _textAlignHorizontal.toFlutterAlign(),
    ))
      ..pushStyle(TextStyle(
        color: _paintingContext.fillPaint.color,
      ))
      ..addText(text);
    final paragraph = paragraphBuilder.build()
      ..layout(
        const ParagraphConstraints(width: double.infinity),
      );
    return paragraph.maxIntrinsicWidth;
  }

  /// Returns the ascent length for the current font, at the current font size.
  double textAscent() {
    final paragraphBuilder = ParagraphBuilder(ParagraphStyle(
      fontFamily: _fontName,
      fontSize: _fontSize,
      textAlign: _textAlignHorizontal.toFlutterAlign(),
    ))
      ..pushStyle(TextStyle(
        color: _paintingContext.fillPaint.color,
        height: _textLeading != null ? _textLeading! / _fontSize : null,
      ))
      ..addText("d");
    final paragraph = paragraphBuilder.build()
      ..layout(
        const ParagraphConstraints(width: double.infinity),
      );

    return paragraph.computeLineMetrics().first.ascent;
  }

  /// Returns the descent length for the current font, at the current font size.
  double textDescent() {
    final paragraphBuilder = ParagraphBuilder(ParagraphStyle(
      fontFamily: _fontName,
      fontSize: _fontSize,
      textAlign: _textAlignHorizontal.toFlutterAlign(),
    ))
      ..pushStyle(TextStyle(
        color: _paintingContext.fillPaint.color,
        height: _textLeading != null ? _textLeading! / _fontSize : null,
      ))
      ..addText("p");
    final paragraph = paragraphBuilder.build()
      ..layout(
        const ParagraphConstraints(width: double.infinity),
      );

    return paragraph.computeLineMetrics().first.descent;
  }

  void textMode() {
    throw UnimplementedError("Flutter only supports one text painting mode, and it's SKIA-based rendering.");
  }
}

enum TextAlignHorizontal {
  left,
  center,
  right,
}

extension on TextAlignHorizontal {
  TextAlign toFlutterAlign() {
    switch (this) {
      case TextAlignHorizontal.left:
        return TextAlign.left;
      case TextAlignHorizontal.center:
        return TextAlign.center;
      case TextAlignHorizontal.right:
        return TextAlign.right;
    }
  }
}

enum TextAlignVertical {
  top,
  center,
  baseline,
  bottom,
}
