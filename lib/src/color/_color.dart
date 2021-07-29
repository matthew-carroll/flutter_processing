import 'package:flutter/painting.dart';

class SketchColor {
  ColorMode _colorMode = ColorMode.rgb;
  void colorMode(ColorMode newMode) {
    _colorMode = newMode;
  }

  Color color({
    int? grey,
    int alpha = 255,
    int? comp1,
    int? comp2,
    int? comp3,
  }) {
    assert(grey != null || (comp1 != null && comp2 != null && comp3 != null));

    if (grey != null) {
      return Color.fromARGB(alpha, grey, grey, grey);
    } else {
      switch (_colorMode) {
        case ColorMode.rgb:
          return Color.fromARGB(alpha, comp1!, comp2!, comp3!);
        case ColorMode.hsb:
          final hsvColor = HSVColor.fromAHSV(alpha / 255, comp1! / 255, comp2! / 255, comp3! / 255);
          return hsvColor.toColor();
      }
    }
  }

  Color lerpColor(Color color1, Color color2, double percent) => Color.lerp(color1, color2, percent)!;

  int red(Color color) => color.red;
  int green(Color color) => color.green;
  int blue(Color color) => color.blue;
  int alpha(Color color) => color.alpha;

  int hue(Color color) => (HSVColor.fromColor(color).hue * 255).round();
  int saturation(Color color) => (HSVColor.fromColor(color).saturation * 255).round();
  int brightness(Color color) => (HSVColor.fromColor(color).value * 255).round();
}

enum ColorMode {
  rgb,
  hsb,
}
