import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Processing widget', () {
    testWidgets('automatically receives focus', (tester) async {
      int keyTypeCount = 0;

      await tester.pumpWidget(
        _buildApp(
          child: Processing(
            sketch: Sketch.simple(
              keyTyped: (s) {
                keyTypeCount += 1;
              },
            ),
          ),
        ),
      );

      // The Processing widget should automatically take focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);

      expect(keyTypeCount, 1);
    });

    testWidgets('blocks upstream key events when it has focus', (tester) async {
      int upstreamKeyEvent = 0;

      await tester.pumpWidget(
        _buildApp(
          child: Focus(
            focusNode: FocusNode(),
            onKey: (node, rawKeyEvent) {
              upstreamKeyEvent += 1;
              return KeyEventResult.ignored;
            },
            child: Processing(
              sketch: Sketch.simple(),
            ),
          ),
        ),
      );

      // The Processing widget should automatically take focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);

      expect(upstreamKeyEvent, 0);
    });

    testWidgets("passes upstream key events when it doesn't have focus", (tester) async {
      final outerFocusNode = FocusNode();
      int upstreamKeyEvent = 0;

      await tester.pumpWidget(
        _buildApp(
          child: Focus(
            focusNode: outerFocusNode,
            onKey: (node, rawKeyEvent) {
              upstreamKeyEvent += 1;
              return KeyEventResult.ignored;
            },
            child: Processing(
              sketch: Sketch.simple(),
            ),
          ),
        ),
      );

      outerFocusNode.requestFocus();
      await tester.pump();

      // The Processing widget should automatically take focus.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);

      expect(upstreamKeyEvent, 1);
    });

    testWidgets('receives key events', (tester) async {
      final keysPressed = <LogicalKeyboardKey>[];
      final keysReleased = <LogicalKeyboardKey>[];
      final keysTyped = <LogicalKeyboardKey>[];

      await tester.pumpWidget(
        _buildApp(
          child: Processing(
            sketch: Sketch.simple(
              keyPressed: (s) {
                if (s.key == null) {
                  return;
                }

                keysPressed.add(s.key!);
              },
              keyReleased: (s) {
                if (s.key == null) {
                  return;
                }

                keysReleased.add(s.key!);
              },
              keyTyped: (s) {
                if (s.key == null) {
                  return;
                }

                keysTyped.add(s.key!);
              },
            ),
          ),
        ),
      );

      // The Processing widget should automatically take focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);

      expect(keysPressed.length, 1);
      expect(keysPressed.first, LogicalKeyboardKey.space);

      expect(keysReleased.length, 1);
      expect(keysReleased.first, LogicalKeyboardKey.space);

      expect(keysTyped.length, 1);
      expect(keysTyped.first, LogicalKeyboardKey.space);
    });
  });
}

Widget _buildApp({
  required Widget child,
}) {
  return MaterialApp(
    home: child,
    debugShowCheckedModeBanner: false,
  );
}
