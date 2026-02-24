# scroll_3d_overlay

<p align="center">
  <img src="https://github.com/marcoazeem/scroll_3d_overlay/blob/main/assets/logo.png?raw=true" width="120" alt="Logo"/>
</p>

`scroll_3d_overlay` is a Flutter widget that pins an overlay (image/mockup/card)
and animates it with 3D transforms based on scroll position.

It is useful for GSAP-style storytelling layouts where content scrolls while a
hero visual rotates/translates/scales through keyframes.

## Demo

<p align="center">
  <img src="https://github.com/marcoazeem/scroll_3d_overlay/blob/main/assets/demo.gif?raw=true" alt="Demo"/>
</p>

## Features

- Scroll-driven 3D keyframe animation.
- Pinned overlay with configurable alignment, size, and padding.
- Interpolated transforms (rotate, translate, scale, opacity, perspective).
- Works with any scrollable child (`ListView`, `CustomScrollView`, etc).

## Installation

Add the dependency:

```yaml
dependencies:
  scroll_3d_overlay: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:scroll_3d_overlay/scroll_3d_overlay.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final controller = ScrollController();

  late final timeline = ScrollTimeline3D(
    keyframes: const [
      Keyframe3D(
        at: 0,
        rotateY: 0.0,
        translate: Offset(0, 0),
        scale: 0.92,
      ),
      Keyframe3D(
        at: 500,
        rotateY: 0.9,
        translate: Offset(120, 0),
        scale: 0.86,
      ),
      Keyframe3D(
        at: 1000,
        rotateY: -0.9,
        translate: Offset(-120, 0),
        scale: 0.86,
      ),
    ],
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Scroll3DOverlay(
        controller: controller,
        timeline: timeline,
        overlayAlignment: Alignment.center,
        overlayWidth: 180,
        overlayHeight: 520,
        scrollChild: ListView.builder(
          controller: controller,
          itemCount: 6,
          itemBuilder: (context, i) => SizedBox(
            height: 420,
            child: Center(
              child: Text(
                'Section ${i + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        overlayChild: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101114),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}
```

## Example App

A full runnable example exists in [example/lib/main.dart](example/lib/main.dart).

Run it with:

```bash
cd example
flutter run
```

## License

MIT. See [LICENSE](LICENSE).
