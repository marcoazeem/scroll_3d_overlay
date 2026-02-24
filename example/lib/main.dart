import 'package:flutter/material.dart';
import 'package:scroll_3d_overlay/scroll_3d_overlay.dart';

void main() => runApp(const DemoApp());

enum ImageDock { left, center, right }

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  final _controller = ScrollController();

  // 👇 Make this user-changeable later (you can expose a toggle UI)
  // Section layout: 1 center, 2 right, 3 left, 4 center.
  final List<ImageDock> docks = const [
    ImageDock.center,
    ImageDock.right,
    ImageDock.left,
    ImageDock.center,
  ];

  // Section sizing (keep consistent so offsets are predictable in Option A)
  static const double sectionHeight = 560;
  static const double sectionGap = 40;

  // Overlay sizing
  static const double imageW = 170;
  static const double imageH = 520;

  // How far the image moves left/right from center (tune this)
  static const double dockDx = 140;

  // Extra spacing to keep content from touching the image
  static const double safeGap = 28;

  late final ScrollTimeline3D _timeline = ScrollTimeline3D(
    keyframes: _buildKeyframes(docks),
  );

  List<Keyframe3D> _buildKeyframes(List<ImageDock> docks) {
    // Compute scroll offsets for each section start.
    // offsetStart(i) = i * (sectionHeight + sectionGap)
    double start(int i) => i * (sectionHeight + sectionGap);

    // Helper: translate dx for dock
    double dxFor(ImageDock dock) {
      switch (dock) {
        case ImageDock.left:
          return -dockDx;
        case ImageDock.center:
          return 0;
        case ImageDock.right:
          return dockDx;
      }
    }

    // Helper: rotateY based on dock (gives the “turning” feeling)
    double rotFor(ImageDock dock) {
      switch (dock) {
        case ImageDock.left:
          return -1.05; // turned to the left
        case ImageDock.center:
          return 0.0; // facing front
        case ImageDock.right:
          return 1.05; // turned to the right
      }
    }

    // Keyframe strategy:
    // - At each section start, set a “pose”
    // - Add a tiny lead-in frame just before it to make transitions smoother
    final frames = <Keyframe3D>[];

    for (int i = 0; i < docks.length; i++) {
      final o = start(i);
      final dock = docks[i];

      // Lead-in (a bit before section start)
      frames.add(
        Keyframe3D(
          at: (o - 120).clamp(0, double.infinity),
          rotateY: rotFor(dock) * 0.75,
          rotateX: 0.05,
          translate: Offset(dxFor(dock) * 0.75, 0),
          scale: 0.88,
          perspective: 0.0016,
        ),
      );

      // Exact pose at section start
      frames.add(
        Keyframe3D(
          at: o,
          rotateY: rotFor(dock),
          rotateX: dock == ImageDock.center ? 0.03 : -0.02,
          translate: Offset(dxFor(dock), 0),
          scale: 0.86,
          perspective: 0.0016,
        ),
      );
    }

    // End frame (keeps the last pose stable near the bottom)
    final endOffset = start(docks.length) + 200;
    frames.add(
      Keyframe3D(
        at: endOffset,
        rotateY: rotFor(docks.last),
        rotateX: 0.03,
        translate: Offset(dxFor(docks.last), 0),
        scale: 0.86,
        perspective: 0.0016,
      ),
    );

    // Remove duplicates by offset (optional safety)
    frames.sort((a, b) => a.at.compareTo(b.at));
    final deduped = <Keyframe3D>[];
    for (final k in frames) {
      if (deduped.isEmpty || (deduped.last.at - k.at).abs() > 0.001) {
        deduped.add(k);
      }
    }
    return deduped;
  }

  EdgeInsets _contentPaddingForDock(ImageDock dock) {
    final reserved = imageW + safeGap;

    switch (dock) {
      case ImageDock.right:
        // Image on right -> reserve space on right -> content left
        return const EdgeInsets.symmetric(
          horizontal: 24,
        ).copyWith(right: 24 + reserved);
      case ImageDock.left:
        // Image on left -> reserve space on left -> content right
        return const EdgeInsets.symmetric(
          horizontal: 24,
        ).copyWith(left: 24 + reserved);
      case ImageDock.center:
        // Image center -> reserve both sides (or just keep it symmetric)
        return const EdgeInsets.symmetric(
          horizontal: 24,
        ).copyWith(left: 24 + reserved * 0.45, right: 24 + reserved * 0.45);
    }
  }

  Alignment _textAlignForDock(ImageDock dock) {
    switch (dock) {
      case ImageDock.right:
        return Alignment.centerLeft;
      case ImageDock.left:
        return Alignment.centerRight;
      case ImageDock.center:
        return Alignment.center;
    }
  }

  TextAlign _textAlignEnum(ImageDock dock) {
    switch (dock) {
      case ImageDock.right:
        return TextAlign.left;
      case ImageDock.left:
        return TextAlign.right;
      case ImageDock.center:
        return TextAlign.center;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Scroll3DOverlay(
          controller: _controller,
          timeline: _timeline,

          // Keep the overlay centered; keyframes move it left/right.
          overlayAlignment: Alignment.center,

          overlayWidth: imageW,
          overlayHeight: imageH,
          overlayPadding: const EdgeInsets.all(12),

          scrollChild: ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.only(top: 60, bottom: 120),
            itemCount: docks.length,
            itemBuilder: (context, i) {
              final dock = docks[i];
              final pad = _contentPaddingForDock(dock);
              final align = _textAlignForDock(dock);
              final ta = _textAlignEnum(dock);

              return Container(
                height: sectionHeight,
                margin: EdgeInsets.only(
                  bottom: i == docks.length - 1 ? 0 : sectionGap,
                ),
                alignment: align,
                padding: pad,
                child: _SectionCard(
                  textAlign: ta,
                ),
              );
            },
          ),

          overlayChild: const _ImageMock(),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.textAlign,
  });

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.start
          : textAlign == TextAlign.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        _placeholderBar(width: 220, height: 22),
        const SizedBox(height: 14),
        _placeholderBar(width: 300, height: 48),
        const SizedBox(height: 12),
        _placeholderBar(width: 280, height: 18),
        const SizedBox(height: 10),
        _placeholderBar(width: 250, height: 18),
        const SizedBox(height: 10),
        _placeholderBar(width: 230, height: 18),
      ],
    );
  }

  Widget _placeholderBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
    );
  }
}

class _ImageMock extends StatelessWidget {
  const _ImageMock();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
        boxShadow: const [
          BoxShadow(blurRadius: 28, offset: Offset(0, 14), spreadRadius: 0),
        ],
      ),
      child: const Center(
        child: Text(
          "IMAGE",
          style: TextStyle(
            color: Colors.white70,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
