import 'dart:math';

import 'dart:ui';

class PVector {
  static PVector lerp(PVector start, PVector end, num percent) {
    return PVector(
      lerpDouble(start.x, end.x, percent.toDouble())!,
      lerpDouble(start.y, end.y, percent.toDouble())!,
    );
  }

  static num angleBetween(PVector v1, PVector v2) {
    return v2.heading - v1.heading;
  }

  factory PVector.random2D({int? seed}) {
    return PVector.fromAngle(Random(seed).nextDouble() * 2 * pi);
  }

  factory PVector.fromAngle(double radians) {
    return PVector(
      cos(radians),
      sin(radians),
    );
  }

  factory PVector.deg0() => PVector(1, 0);
  factory PVector.deg45() => PVector(sqrt(2) / 2, sqrt(2) / 2);
  factory PVector.deg90() => PVector(0, 1);
  factory PVector.deg135() => PVector(-sqrt(2) / 2, sqrt(2) / 2);
  factory PVector.deg180() => PVector(-1, 0);
  factory PVector.deg225() => PVector(-sqrt(2) / 2, -sqrt(2) / 2);
  factory PVector.deg270() => PVector(0, -1);
  factory PVector.deg315() => PVector(sqrt(2) / 2, -sqrt(2) / 2);

  PVector(this.x, this.y);

  num x;

  num y;

  void set(num x, num y) {
    x = x;
    y = y;
  }

  PVector operator +(PVector other) {
    return PVector(x + other.x, y + other.y);
  }

  void add(PVector other) {
    x += other.x;
    y += other.y;
  }

  PVector operator -(PVector other) {
    return PVector(x - other.x, y - other.y);
  }

  void sub(PVector other) {
    x -= other.x;
    y -= other.y;
  }

  PVector operator *(num scalar) {
    return PVector(x * scalar, y * scalar);
  }

  void mult(num scalar) {
    x *= scalar;
    y *= scalar;
  }

  PVector operator /(num scalar) {
    return PVector(x / scalar, y / scalar);
  }

  void div(num scalar) {
    x /= scalar;
    y /= scalar;
  }

  num get heading {
    return atan2(y, x);
  }

  void rotate(num radians) {
    final newHeading = heading + radians;
    final magnitude = mag;

    x = magnitude * cos(newHeading);
    y = magnitude * sin(newHeading);
  }

  num get mag {
    return sqrt(pow(x, 2) + pow(y, 2));
  }

  set mag(num magnitude) {
    if (magnitude < 0) {
      throw Exception("Magnitude must be >= 0");
    }

    final currentHeading = heading;
    x = magnitude * cos(currentHeading);
    y = magnitude * sin(currentHeading);
  }

  num get magSq {
    return pow(x, 2) + pow(y, 2);
  }

  void normalize() {
    mag = 1.0;
  }

  void limit(num magnitude) {
    if (mag > magnitude) {
      mag = magnitude;
    }
  }

  num dist(PVector other) {
    return PVector(other.x - x, other.y - y).mag;
  }

  num dot(PVector other) {
    return mag * other.mag * cos(angleBetween(this, other));
  }

  PVector cross(PVector other) {
    throw UnimplementedError(
        "Flutter Processing doesn't support this yet. We need 3D vectors to make this meaningful.");
  }

  List<num> get array {
    return [x, y];
  }

  PVector copy() {
    return PVector(x, y);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PVector && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => "($x, $y)";
}
