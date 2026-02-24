import 'package:flutter/widgets.dart';

import 'timeline.dart';

/// A pinned overlay widget that applies a scroll-driven 3D transform
/// (the “turning phone while scrolling” effect).
///
/// Typical usage:
/// - Put your scrolling content as [scrollChild]
/// - Put the phone/mockup as [overlayChild]
/// - Provide a [ScrollController] used by the scrollChild
/// - Provide a [ScrollTimeline3D] with keyframes
class Scroll3DOverlay extends StatefulWidget {
  const Scroll3DOverlay({
    super.key,
    required this.controller,
    required this.timeline,
    required this.scrollChild,
    required this.overlayChild,
    this.overlayAlignment = Alignment.centerRight,
    this.overlayPadding = const EdgeInsets.all(24),
    this.overlayWidth,
    this.overlayHeight,
    this.enableHitTestingOnOverlay = false,
    this.transformAlignment = Alignment.center,
    this.clampOpacity = true,
  });

  /// The controller used by the scrollable content.
  final ScrollController controller;

  /// Keyframe timeline that maps scroll offset -> transform pose.
  final ScrollTimeline3D timeline;

  /// The scrollable content (ListView/CustomScrollView/etc).
  final Widget scrollChild;

  /// The pinned overlay (phone image, mock, etc).
  final Widget overlayChild;

  /// Where the overlay sits on screen.
  final Alignment overlayAlignment;

  /// Padding around the overlay.
  final EdgeInsets overlayPadding;

  /// Optional explicit overlay sizing.
  final double? overlayWidth;
  final double? overlayHeight;

  /// By default, we ignore pointer events so scrolling works naturally.
  final bool enableHitTestingOnOverlay;

  /// Alignment for 3D transform pivot.
  final Alignment transformAlignment;

  /// Ensure opacity is clamped 0..1.
  final bool clampOpacity;

  @override
  State<Scroll3DOverlay> createState() => _Scroll3DOverlayState();
}

class _Scroll3DOverlayState extends State<Scroll3DOverlay> {
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    _offset = widget.controller.hasClients ? widget.controller.offset : 0.0;
  }

  @override
  void didUpdateWidget(covariant Scroll3DOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
      _offset = widget.controller.hasClients ? widget.controller.offset : 0.0;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Avoid rebuilding too aggressively in debug hot reload situations.
    final newOffset = widget.controller.offset;
    if (newOffset == _offset) return;
    setState(() => _offset = newOffset);
  }

  @override
  Widget build(BuildContext context) {
    final pose = widget.timeline.sample(_offset);

    final opacity = widget.clampOpacity
        ? pose.opacity.clamp(0.0, 1.0).toDouble()
        : pose.opacity;

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, pose.perspective)
      ..translateByDouble(pose.translate.dx, pose.translate.dy, 0.0, 1.0)
      ..scaleByDouble(pose.scale, pose.scale, pose.scale, 1.0)
      ..rotateX(pose.rotateX)
      ..rotateY(pose.rotateY)
      ..rotateZ(pose.rotateZ);

    final overlay = Padding(
      padding: widget.overlayPadding,
      child: SizedBox(
        width: widget.overlayWidth,
        height: widget.overlayHeight,
        child: Opacity(
          opacity: opacity,
          child: Transform(
            alignment: widget.transformAlignment,
            transform: matrix,
            child: widget.overlayChild,
          ),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ Phone behind
        widget.enableHitTestingOnOverlay
            ? Align(alignment: widget.overlayAlignment, child: overlay)
            : IgnorePointer(
                ignoring: true,
                child:
                    Align(alignment: widget.overlayAlignment, child: overlay),
              ),

        // ✅ Content in front
        widget.scrollChild,
      ],
    );
  }
}
