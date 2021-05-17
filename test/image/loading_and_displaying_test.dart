import 'dart:ui';

import 'package:flutter/widgets.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

// TODO: figure out how to get this test to run without doing special
//       work before the test.
//       - The image data is loaded and cached at the beginning of the test
//       - The implementation of s.loadImage() is replicated at the beginning of the test, too
void main() async {
  group('Image', () {
    group('Loading and Displaying', () {
      testGoldens('loads and displays image asset', (tester) async {
        late FrameInfo frame;

        await tester.runAsync(() async {
          // The following lines are the same as implementation of
          // s.loadImage(). It's done here because it has to be run
          // within runAsync() to avoid hanging forever.
          final imageData = await TestAssetBundle().load('space_100x.png');

          final codec = await (await ImageDescriptor.encoded(
            await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
          ))
              .instantiateCodec();

          frame = await codec.getNextFrame();
        });
        //----- end image prep ------

        configureWindowForSpecTest(tester);

        Image loadedImage = frame.image;

        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: Processing(
              sketch: Sketch.simple(
                setup: (s) async {
                  s.noLoop();

                  // TODO: load the image here when we figure out how
                  // loadedImage = await s.loadImage('space_100x.png');
                },
                draw: (s) async {
                  s.image(
                    image: loadedImage,
                  );
                },
              ),
            ),
          ),
        );

        await screenMatchesGolden(tester, 'image_loading-and-display_example-1');
      });
    });
  });
}
