import 'package:flutter_test/flutter_test.dart';

// TODO: figure out how to get this test to run without doing special
//       work before the test.
//       - The image data is loaded and cached at the beginning of the test
//       - The implementation of s.loadImage() is replicated at the beginning of the test, too
void main() async {
  group('Image', () {
    group('Loading and Displaying', () {
      // TODO: uncomment this test when we figure out how to run an async
      //       operation in a test
      // processingLegacySpecTest('loads and displays image asset',
      //     (tester) async {
      //   late FrameInfo frame;
      //   late ByteData pixels;
      //
      //   await tester.runAsync(() async {
      //     // The following lines are the same as implementation of
      //     // s.loadImage(). It's done here because it has to be run
      //     // within runAsync() to avoid hanging forever.
      //     final imageData = await TestAssetBundle().load('space_100x.png');
      //
      //     final codec = await (await ImageDescriptor.encoded(
      //       await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
      //     ))
      //         .instantiateCodec();
      //
      //     frame = await codec.getNextFrame();
      //     pixels = (await frame.image.toByteData())!;
      //   });
      //   //----- end image prep ------
      //
      //   PImage loadedImage = PImage.fromPixels(
      //       frame.image.width, frame.image.height, pixels, ImageFileFormat.png);
      //
      //   await tester.pumpWidget(
      //     DefaultAssetBundle(
      //       bundle: TestAssetBundle(),
      //       child: Processing(
      //         sketch: Sketch.simple(
      //           setup: (s) {
      //             s.noLoop();
      //
      //             // TODO: load the image here when we figure out how
      //             // loadedImage = await s.loadImage('space_100x.png');
      //           },
      //           draw: (s) async {
      //             await s.image(
      //               image: loadedImage,
      //             );
      //           },
      //         ),
      //       ),
      //     ),
      //   );
      //
      //   await screenMatchesGolden(
      //       tester, 'image_loading-and-display_example-1');
      // });
    });
  });
}
