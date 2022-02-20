# Flutter Processing

A Flutter port of [Processing](https://processing.org/reference/).

This project is not affiliated with the Processing project, or related organizations.

The goal of flutter_processing is to provide the same easy learning environment as Processing, but with the additional utility of a production-ready UI toolkit, called Flutter. With traditional Processing, there is minimal professional value in the underlying language. With flutter_processing, the underlying tool, Flutter, is sufficient for employment as an app UI developer. flutter_processing offers an educational tool and an employment opportunity all in one.

Want to see how this project was implemented? Nearly every change was recorded and published to the [SuperDeclarative!](https://youtube.com/c/SuperDeclarative) channel on YouTube.

To see which Processing APIs have been ported to Flutter, see the [API Checklist](README_API_CHECKLIST.md).

---

Do you get value from this package? Please consider supporting SuperDeclarative!

<a href="https://donate.superdeclarative.com" target="_blank" alt="Donate"><img src="https://img.shields.io/badge/Donate-%24%24-green"></a>

---

# Getting Started
To play with some demos, clone this repository and run the example app!

To paint a canvas with a sketch in Flutter, the way you would in Processing, display a `Processing` widget and implement a `Sketch`.

```dart
void main() {
  runApp(
    MaterialApp(
      home: Processing(
        sketch: Sketch.simple(
          setup: (sketch) async {
            // TODO: do your typical Sketch setup
            //       stuff here. Call methods on
            //       the provided sketch object.
          },
          draw: (sketch) async {
            // TODO: do your typical Sketch drawing
            //       stuff here. Call methods on
            //       the provided sketch object.
          },
        ),
      ),
    ),
  );
}
``` 

To retain and access variables in your `Sketch`, or to implement a `Sketch` in a more traditional way, subclass `Sketch`:
```dart
void main() {
  runApp(
    MaterialApp(
      home: Processing(
        sketch: MySketch(),
      ),
    ),
  );
}

class MySketch extends Sketch {
  @override
  Future<void> setup() async {
    // TODO: do setup stuff here
  }

  @override
  Future<void> draw() async {
    // TODO: do drawing stuff here
  }
}
```

# Get Involved
If you create anything cool, be sure to post it to Twitter and tag [@SuprDeclarative](https://twitter.com/SuprDeclarative) and [@FlutterDev](https://twitter.com/FlutterDev)!

If you need something implemented, or you find a bug, please checkout the [Contributing Guide](CONTRIBUTING.md) and then file an issue in the GitHub project.