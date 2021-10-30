import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('core', () {
    processingLegacySpecTest('setup() paints light grey background by default', (tester) async {
      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(setup: (s) async {
            s.noLoop();
          }),
        ),
      );

      await screenMatchesGolden(tester, 'core_setup-paints-default-background');
    });
  });
}
