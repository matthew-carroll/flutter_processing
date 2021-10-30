import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Shape', () {
    group('Attributes', () {
      processingLegacySpecTest('strokeWeight(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..strokeWeight(1)
                  ..line(Offset(20, 20), Offset(80, 20))
                  ..strokeWeight(4)
                  ..line(Offset(20, 40), Offset(80, 40))
                  ..strokeWeight(10)
                  ..line(Offset(20, 70), Offset(80, 70));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_attributes_stroke-weight-example-1');
      });

      testWidgets('strokeWeight() invalid value', (tester) async {
        await expectLater(
          () => Sketch.simple()..strokeWeight(-1),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
