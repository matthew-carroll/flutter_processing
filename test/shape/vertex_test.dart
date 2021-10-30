import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Shape', () {
    group('Vertex', () {
      processingSpecTest('beginShape(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape()
                  ..vertex(120, 80)
                  ..vertex(340, 80)
                  ..vertex(340, 300)
                  ..vertex(120, 300)
                  ..endShape(close: true);
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_1');
      });

      processingSpecTest('beginShape(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape(ShapeMode.points)
                  ..vertex(120, 80)
                  ..vertex(340, 80)
                  ..vertex(340, 300)
                  ..vertex(120, 300)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_2');
      });

      processingSpecTest('beginShape(): example 3', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape()
                  ..vertex(120, 80)
                  ..vertex(230, 80)
                  ..vertex(230, 190)
                  ..vertex(340, 190)
                  ..vertex(340, 300)
                  ..vertex(120, 300)
                  ..endShape(close: true);
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_3');
      });

      processingSpecTest('beginShape(): example 4', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape(ShapeMode.lines)
                  ..vertex(120, 80)
                  ..vertex(340, 80)
                  ..vertex(340, 300)
                  ..vertex(120, 300)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_4');
      });

      processingSpecTest('beginShape(): example 5', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..noFill()
                  ..beginShape()
                  ..vertex(120, 80)
                  ..vertex(340, 80)
                  ..vertex(340, 300)
                  ..vertex(120, 300)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_5');
      });

      processingSpecTest('beginShape(): example 6', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..noFill()
                  ..beginShape()
                  ..vertex(120, 80)
                  ..vertex(340, 80)
                  ..vertex(340, 300)
                  ..vertex(120, 300)
                  ..endShape(close: true);
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_6');
      });

      processingSpecTest('beginShape(): example 7', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape(ShapeMode.triangles)
                  ..vertex(120, 300)
                  ..vertex(160, 120)
                  ..vertex(200, 300)
                  ..vertex(270, 80)
                  ..vertex(280, 300)
                  ..vertex(320, 80)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_7');
      });

      processingSpecTest('beginShape(): example 8', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape(ShapeMode.triangleStrip)
                  ..vertex(120, 300)
                  ..vertex(160, 80)
                  ..vertex(200, 300)
                  ..vertex(240, 80)
                  ..vertex(280, 300)
                  ..vertex(320, 80)
                  ..vertex(360, 300)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_8');
      });

      processingSpecTest('beginShape(): example 9', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape(ShapeMode.triangleFan)
                  ..vertex(230, 200)
                  ..vertex(230, 60)
                  ..vertex(368, 200)
                  ..vertex(230, 340)
                  ..vertex(88, 200)
                  ..vertex(230, 60)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_9');
      });

      processingSpecTest('beginShape(): example 10', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape(ShapeMode.quads)
                  ..vertex(120, 80)
                  ..vertex(120, 300)
                  ..vertex(200, 300)
                  ..vertex(200, 80)
                  ..vertex(260, 80)
                  ..vertex(260, 300)
                  ..vertex(340, 300)
                  ..vertex(340, 80)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_10');
      });

      processingSpecTest('beginShape(): example 11', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape(ShapeMode.quadStrip)
                  ..vertex(120, 80)
                  ..vertex(120, 300)
                  ..vertex(200, 80)
                  ..vertex(200, 300)
                  ..vertex(260, 80)
                  ..vertex(260, 300)
                  ..vertex(340, 80)
                  ..vertex(340, 300)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_begin-shape_11');
      });

      processingSpecTest('endShape(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..noFill()
                  ..beginShape()
                  ..vertex(80, 80)
                  ..vertex(180, 80)
                  ..vertex(180, 320)
                  ..endShape(close: true)
                  ..beginShape()
                  ..vertex(200, 80)
                  ..vertex(300, 80)
                  ..vertex(300, 320)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_end-shape_1');
      });

      processingSpecTest('bezierVertex(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..noFill()
                  ..beginShape()
                  ..vertex(120, 80)
                  ..bezierVertex(320, 0, 320, 300, 120, 300)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_bezier-vertex_1');
      });

      processingSpecTest('bezierVertex(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..beginShape()
                  ..vertex(120, 80)
                  ..bezierVertex(320, 0, 320, 300, 90, 300)
                  ..bezierVertex(200, 320, 240, 100, 120, 80)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_bezier-vertex_2');
      });

      processingSpecTest('quadraticVertex(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..noFill()
                  ..strokeWeight(16)
                  ..beginShape()
                  ..vertex(80, 80)
                  ..quadraticVertex(320, 80, 200, 200)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_quadratic-vertex_1');
      });

      processingSpecTest('quadraticVertex(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s
                  ..size(width: 400, height: 400)
                  ..noLoop()
                  ..noFill()
                  ..strokeWeight(16)
                  ..beginShape()
                  ..vertex(80, 80)
                  ..quadraticVertex(320, 80, 200, 200)
                  ..quadraticVertex(80, 320, 320, 320)
                  ..vertex(320, 240)
                  ..endShape();
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_vertex_quadratic-vertex_2');
      });
    });
  });
}
