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
              draw: (s) {
                s
                  ..noLoop()
                  ..strokeWeight(1)
                  ..line(const Offset(20, 20), const Offset(80, 20))
                  ..strokeWeight(4)
                  ..line(const Offset(20, 40), const Offset(80, 40))
                  ..strokeWeight(10)
                  ..line(const Offset(20, 70), const Offset(80, 70));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_attributes_stroke-weight-example-1');
      });

      testWidgets('strokeWeight() invalid value', (tester) async {
        expect(
          () => Sketch.simple()..strokeWeight(-1),
          throwsException,
        );
      });
    });
  });
}
