import 'dart:math';

import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Math', () {
    group('PVector', () {
      test('create random', () {
        final seed = 12345;
        final randomVector = PVector.random2D(seed: seed);

        expect(randomVector, equals(PVector(0.9170641544216254, -0.39873968535242293)));
        expect(randomVector.mag, equals(1.0));
      });

      test('create from angle', () {
        expect(PVector.fromAngle(0), equals(PVector(1, 0)));

        // The following angle calculations result in very tiny
        // lengths that should technically be zero. Therefore,
        // rather than compare equality, we ensure that each
        // vector created from an angle is very close to what it
        // should be.

        expect(
          PVector.angleBetween(PVector.fromAngle(pi / 2), PVector(0, 1)).abs(),
          lessThan(1e-15),
        );

        expect(
          PVector.angleBetween(PVector.fromAngle(pi), PVector(-1, 0)).abs(),
          lessThan(1e-15),
        );

        expect(
          PVector.angleBetween(PVector.fromAngle(3 * pi / 2), PVector(0, -1)).abs(),
          lessThan(1e-15),
        );

        expect(
          PVector.angleBetween(PVector.fromAngle(2 * pi), PVector(1, 0)).abs(),
          lessThan(1e-15),
        );
      });

      test('lerp', () {
        expect(
          PVector.lerp(PVector(-1, -1), PVector(1, 1), 0.5),
          equals(PVector(0, 0)),
        );

        expect(
          PVector.lerp(PVector(-1, 1), PVector(1, 1), 0.5),
          equals(PVector(0, 1)),
        );

        expect(
          PVector.lerp(PVector(-1, 1), PVector(1, 1), 0.25),
          equals(PVector(-0.5, 1)),
        );
      });

      test('set components', () {
        expect(
          PVector(1, 2)..set(3, 4),
          PVector(3, 4),
        );
      });

      test('angle between', () {
        expect(
          PVector.angleBetween(PVector(1, 1), PVector(1, 1)),
          equals(0.0),
        );

        expect(
          PVector.angleBetween(PVector(0, -1), PVector(0, 1)).abs(),
          equals(pi),
        );

        expect(
          PVector.angleBetween(PVector(-1, 0), PVector(-sqrt(2), sqrt(2))).abs(),
          equals(pi / 4),
        );
      });

      test('add vectors', () {
        expect(
          PVector(1, 0) + PVector(0, 1),
          equals(PVector(1, 1)),
        );

        expect(
          PVector(1, 0) + PVector(-1, 0),
          equals(PVector(0, 0)),
        );

        expect(
          PVector.deg45() + PVector.deg315(),
          equals(PVector(sqrt(2), 0)),
        );
      });

      test('subtract vectors', () {
        expect(
          PVector(1, 0) - PVector(0, 1),
          equals(PVector(1, -1)),
        );

        expect(
          PVector(1, 0) - PVector(-1, 0),
          equals(PVector(2, 0)),
        );

        expect(
          PVector.deg45() - PVector.deg315(),
          equals(PVector(0, sqrt(2))),
        );
      });

      test('multiplication', () {
        final p1 = PVector(1, 1) * 2;
        expect(p1, equals(PVector(2, 2)));

        final p2 = PVector(1, 1) * 0.5;
        expect(p2, equals(PVector(0.5, 0.5)));

        final p3 = PVector(1, 1) * -2;
        expect(p3, equals(PVector(-2, -2)));
      });

      test('division', () {
        final p1 = PVector(1, 1) / 2;
        expect(p1, equals(PVector(0.5, 0.5)));

        final p2 = PVector(1, 1) / 0.5;
        expect(p2, equals(PVector(2, 2)));

        final p3 = PVector(1, 1) / -2;
        expect(p3, equals(PVector(-0.5, -0.5)));
      });

      test('heading', () {
        expect(PVector(1, 0).heading, equals(0.0));

        // 45 degrees
        expect(PVector(1, 1).heading, equals(pi / 4));

        // 90 degrees
        expect(PVector(0, 1).heading, equals(pi / 2));

        // 135 degrees
        expect(PVector(-1, 1).heading, equals(3 * pi / 4));

        // 180 degrees
        expect(PVector(-1, 0).heading, equals(pi));

        // 225 degrees
        expect(PVector(-1, -1).heading, equals(-3 * pi / 4));

        // 270 degrees
        expect(PVector(0, -1).heading, equals(-pi / 2));

        // 315 degrees
        expect(PVector(1, -1).heading, equals(-pi / 4));
      });

      test('rotate', () {
        expect(
          PVector.deg0()..rotate(pi / 4),
          equivalentVector(PVector.deg45()),
        );

        expect(
          PVector.deg45()..rotate(pi / 4),
          equivalentVector(PVector.deg90()),
        );

        expect(
          PVector.deg90()..rotate(pi / 4),
          equivalentVector(PVector.deg135()),
        );

        expect(
          PVector.deg135()..rotate(pi / 4),
          equivalentVector(PVector.deg180()),
        );

        expect(
          PVector.deg180()..rotate(pi / 4),
          equivalentVector(PVector.deg225()),
        );

        expect(
          PVector.deg225()..rotate(pi / 4),
          equivalentVector(PVector.deg270()),
        );

        expect(
          PVector.deg270()..rotate(pi / 4),
          equivalentVector(PVector.deg315()),
        );

        expect(
          PVector.deg315()..rotate(pi / 4),
          equivalentVector(PVector.deg0()),
        );
      });

      test('magnitude', () {
        expect(PVector(1, 0).mag, 1);
        expect(PVector(2, 0).mag, 2);
        expect(PVector(0, -2).mag, 2);
        expect(PVector(-2, 0).mag, 2);

        expect(PVector.deg0()..mag = 2, equivalentVector(PVector(2, 0)));
        expect(PVector.deg180()..mag = 2, equivalentVector(PVector(-2, 0)));
        expect(PVector.deg315()..mag = 0.5, equivalentVector(PVector(sqrt(2) / 4, -sqrt(2) / 4)));
      });

      test('normalize', () {
        expect(PVector(2, 0)..normalize(), equivalentVector(PVector(1, 0)));
        expect(PVector(-2, 0)..normalize(), equivalentVector(PVector(-1, 0)));
        expect(PVector(3, 3)..normalize(), equivalentVector(PVector.deg45()));
      });

      test('limit magnitude', () {
        expect(PVector(2, 0)..limit(1.5), equivalentVector(PVector(1.5, 0)));
        expect(PVector(-2, 0)..limit(2), equivalentVector(PVector(-2, 0)));
        expect(PVector(3, 3)..limit(1), equivalentVector(PVector.deg45()));
      });

      test('distance', () {
        expect(PVector(10, 20).dist(PVector(60, 80)), 78.10249675906654);
      });

      test('dot product', () {
        expect(PVector(10, 20).dot(PVector(60, 80)), 2200);
      });
    });
  });
}

Matcher equivalentVector(PVector expected) => _EquivalentVectorMatcher(expected);

class _EquivalentVectorMatcher extends Matcher {
  _EquivalentVectorMatcher(this._expected);

  final PVector _expected;

  @override
  bool matches(item, Map matchState) {
    if (item is! PVector) {
      return false;
    }

    return (_expected.heading - item.heading).abs() < 1e-15 && (_expected.mag - item.mag).abs() < 1e-15;
  }

  @override
  Description describe(Description description) {
    return description.addDescriptionOf(_expected);
  }
}
