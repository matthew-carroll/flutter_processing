import 'dart:math' as math;

mixin SketchMathTrigonometry {
  double degrees(num angleInRadians) {
    return (angleInRadians / math.pi) * 180;
  }

  double radians(num degrees) {
    return (degrees / 180) * math.pi;
  }

  double sin(num angleInRadians) {
    return math.sin(angleInRadians);
  }

  double cos(num angleInRadians) {
    return math.cos(angleInRadians);
  }

  double tan(num angleInRadians) {
    return math.tan(angleInRadians);
  }

  double asin(num value) {
    return math.asin(value);
  }

  double acos(num value) {
    return math.acos(value);
  }

  double atan(num value) {
    return math.atan(value);
  }

  double atan2(num y, num x) {
    return math.atan2(y, x);
  }
}
