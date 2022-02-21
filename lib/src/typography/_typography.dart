part of '../_core.dart';

mixin SketchTypography on BaseSketch {
  void createFont() {
    throw UnimplementedError(
        "You don't need to 'createFont()' in flutter_processing. Instead, use the standard Flutter font configurations in pubspec.yaml.");
  }

  void loadFont() {
    throw UnimplementedError(
        "You don't need to 'loadFont()' in flutter_processing. Instead, use the standard Flutter font configurations in pubspec.yaml.");
  }

  void textFont(String fontName) {
    // TODO:
  }

  void text(String text, double x, double y) {
    final paragraphBuilder = ParagraphBuilder(ParagraphStyle())..addText(text);
    final paragraph = paragraphBuilder.build();
    _paintingContext.canvas.drawParagraph(paragraph, Offset(x, y));
  }

  void textAlign(TextAlign horizontalAlignment, [TextAlignVertical? verticalAlignment]) {
    // TODO:
  }

  void textLeading(double leading) {
    // TODO:
  }

  void textSize(double fontSize) {
    // TODO:
  }

  double textWidth(String character) {
    // TODO:
    return 0.0;
  }

  double textAscent() {
    // TODO:
    return 0.0;
  }

  double textDescent() {
    // TODO:
    return 0.0;
  }

  void textMode() {
    throw UnimplementedError("Flutter only supports one text painting mode, and it's SKIA-based rendering.");
  }
}
