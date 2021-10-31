import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Input', () {
    group('Keyboard', () {
      testWidgets('keypress lifecycle', (tester) async {
        LogicalKeyboardKey? key;
        bool isKeyPressed = false;
        int keyPressedCallCount = 0;
        int keyReleasedCallCount = 0;

        final focusNode = FocusNode();
        focusNode.requestFocus();

        await tester.pumpWidget(
          Processing(
            focusNode: focusNode,
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();
              },
              keyPressed: (s) {
                keyPressedCallCount += 1;
                isKeyPressed = s.isKeyPressed;
                key = s.key;
              },
              keyReleased: (s) {
                keyReleasedCallCount += 1;
                isKeyPressed = s.isKeyPressed;
                key = s.key;
              },
            ),
          ),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        expect(keyPressedCallCount, 1);
        expect(isKeyPressed, true);
        expect(key, LogicalKeyboardKey.keyA);
        expect(keyReleasedCallCount, 0);

        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        expect(keyPressedCallCount, 1);
        expect(keyReleasedCallCount, 1);
        expect(isKeyPressed, false);
        expect(key, LogicalKeyboardKey.keyA);
      });

      testWidgets('keyTyped invoked for non-control key', (tester) async {
        int keyTypedCallCount = 0;

        final focusNode = FocusNode();
        focusNode.requestFocus();

        await tester.pumpWidget(
          Processing(
            focusNode: focusNode,
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();
              },
              keyTyped: (s) {
                keyTypedCallCount += 1;
              },
            ),
          ),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        expect(keyTypedCallCount, 1);
      });

      testWidgets('keyTyped NOT invoked for control key', (tester) async {
        int keyTypedCallCount = 0;

        final focusNode = FocusNode();
        focusNode.requestFocus();

        await tester.pumpWidget(
          Processing(
            focusNode: focusNode,
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();
              },
              keyTyped: (s) {
                keyTypedCallCount += 1;
              },
            ),
          ),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.pumpAndSettle();

        expect(keyTypedCallCount, 0);
      });
    });
  });
}
