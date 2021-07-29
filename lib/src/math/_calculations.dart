import 'dart:math' as math;
import 'dart:ui';

class SketchCalculations {
  num abs(num value) {
    return value.abs();
  }

  int ceil(num value) {
    return value.ceil();
  }

  num constrain(num value, num min, num max) {
    return value.clamp(min, max);
  }

  num dist(Offset p1, Offset p2) {
    return (p2 - p1).distance;
  }

  num exp(int n) {
    return math.pow(math.e, n);
  }

  int floor(num value) {
    return value.floor();
  }

  double lerp(num start, num end, double percent) {
    return lerpDouble(start, end, percent)!;
  }

  num log(num n) {
    return math.log(n);
  }

  num mag(int x, int y, [int z = 0]) {
    return math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2));
  }

  num map(num value, num domainMin, num domainMax, num rangeMin, num rangeMax) {
    final percent = value / (domainMax - domainMin);
    return lerp(rangeMin, rangeMax, percent);
  }

  num max(num a, num b, [num? c]) {
    final max = math.max(a, b);
    return c != null ? math.max(max, c) : max;
  }

  num maxInList(List<num> list) {
    assert(list.isNotEmpty);
    return list.fold(list.first, (previousMax, newValue) => math.max(previousMax, newValue));
  }

  num min(num a, num b, [num? c]) {
    final min = math.min(a, b);
    return c != null ? math.min(min, c) : min;
  }

  num minInList(List<num> list) {
    assert(list.isNotEmpty);
    return list.fold(list.first, (previousMin, newValue) => math.min(previousMin, newValue));
  }

  num norm(num value, num start, num stop) {
    return map(value, start, stop, 0, 1);
  }

  num pow(num base, num exponent) {
    return math.pow(base, exponent);
  }

  int round(num value) {
    return value.round();
  }

  num sq(num value) {
    return value * value;
  }

  num sqrt(num value) {
    return math.sqrt(value);
  }
}
