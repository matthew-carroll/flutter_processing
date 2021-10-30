import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Color', () {
    group('setting', () {
      processingLegacySpecTest('background(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..background(color: const Color(0xFF404040));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_background-example-1');
      });

      processingLegacySpecTest('background(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..background(color: const Color(0xFFFFCC00));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_background-example-2');
      });

      processingLegacySpecTest('user can paint background in setup()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              setup: (s) async {
                s
                  ..noLoop()
                  ..background(color: const Color(0xFF404040));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_background-in-setup');
      });

      processingLegacySpecTest('background in draw() replaces background in setup()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              setup: (s) async {
                s
                  ..noLoop()
                  ..background(color: const Color(0xFFFF0000));
              },
              draw: (s) async {
                s.background(color: const Color(0xFF404040));
              },
            ),
          ),
        );

        await screenMatchesGolden(
            tester,
            'color_setting_background-setup-and'
            '-draw');
      });

      processingLegacySpecTest('fill(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..fill(color: const Color(0xFF969696))
                  ..rect(rect: Rect.fromLTWH(30, 20, 55, 55));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_fill-example-1');
      });

      processingLegacySpecTest('fill(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..fill(color: const Color(0xFFCC6600))
                  ..rect(rect: Rect.fromLTWH(30, 20, 55, 55));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_fill-example-2');
      });

      processingLegacySpecTest('noFill(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..rect(rect: Rect.fromLTWH(15, 10, 55, 55))
                  ..noFill()
                  ..rect(rect: Rect.fromLTWH(30, 20, 55, 55));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_nofill-example-1');
      });

      processingLegacySpecTest('stroke(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..stroke(color: const Color(0xFFAAAAAA))
                  ..rect(rect: Rect.fromLTWH(30, 20, 55, 55));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_stroke-example-1');
      });

      processingLegacySpecTest('stroke(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..stroke(color: const Color(0xFFCC6600))
                  ..rect(rect: Rect.fromLTWH(30, 20, 55, 55));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_stroke-example-2');
      });

      processingLegacySpecTest('noStroke(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..noLoop()
                  ..noStroke()
                  ..rect(rect: Rect.fromLTWH(30, 20, 55, 55));
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'color_setting_nostroke-example-1');
      });
    });
  });
}
