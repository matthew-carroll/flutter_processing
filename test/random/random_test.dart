import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Random', () {
    testWidgets('random()', (tester) async {
      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) async {
              s
                ..noLoop()
                ..randomSeed(0);

              // with upper bound
              double randomValue = s.random(50);
              expect(randomValue, 41.27570359435851);

              // with lower and upper bound
              randomValue = s.random(-50, 50);
              expect(randomValue, 38.63148172405516);

              // with a lower bound that is larger than upper bound
              expectLater(() {
                s.random(10, 5);
              }, throwsA(isA<Exception>()));
            },
          ),
        ),
      );
    });
  });
}
