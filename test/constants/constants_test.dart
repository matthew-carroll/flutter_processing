import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Constants', () {
    processingLegacySpecTest('constants', (tester) async {
      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s.noLoop();

              final x = s.width / 2;
              final y = s.height / 2;
              final d = s.width * 0.8;
              s.arc(
                ellipse: Ellipse.fromCenter(center: Offset(x, y), width: d, height: d),
                startAngle: 0,
                endAngle: s.QUARTER_PI,
              );
              s.arc(
                ellipse: Ellipse.fromCenter(center: Offset(x, y), width: d - 20, height: d - 20),
                startAngle: 0,
                endAngle: s.HALF_PI,
              );
              s.arc(
                ellipse: Ellipse.fromCenter(center: Offset(x, y), width: d - 40, height: d - 40),
                startAngle: 0,
                endAngle: s.PI,
              );
              s.arc(
                ellipse: Ellipse.fromCenter(center: Offset(x, y), width: d - 60, height: d - 60),
                startAngle: 0,
                endAngle: s.TAU,
              );
            },
          ),
        ),
      );

      await screenMatchesGolden(
        tester,
        'constants',
      );
    });
  });
}
