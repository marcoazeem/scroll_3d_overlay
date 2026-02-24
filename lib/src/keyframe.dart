import 'package:flutter/widgets.dart';

/// A single keyframe in scroll-space.
///
/// [at] is the scroll offset (in pixels) where this keyframe is defined.
/// Between keyframes, values are interpolated (lerped).
@immutable
class Keyframe3D {
  const Keyframe3D({
    required this.at,
    this.rotateX = 0.0,
    this.rotateY = 0.0,
    this.rotateZ = 0.0,
    this.translate = Offset.zero,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.perspective = 0.0015,
  });

  /// Scroll offset in pixels where this keyframe applies.
  final double at;

  /// Rotation in radians.
  final double rotateX;
  final double rotateY;
  final double rotateZ;

  /// 2D translation in logical pixels (screen space).
  final Offset translate;

  /// Uniform scale factor.
  final double scale;

  /// Opacity 0..1 (useful for fade transitions).
  final double opacity;

  /// Perspective entry for Matrix4 (setEntry(3, 2, perspective)).
  /// Typical values: 0.0008 - 0.0025.
  final double perspective;

  Keyframe3D copyWith({
    double? at,
    double? rotateX,
    double? rotateY,
    double? rotateZ,
    Offset? translate,
    double? scale,
    double? opacity,
    double? perspective,
  }) {
    return Keyframe3D(
      at: at ?? this.at,
      rotateX: rotateX ?? this.rotateX,
      rotateY: rotateY ?? this.rotateY,
      rotateZ: rotateZ ?? this.rotateZ,
      translate: translate ?? this.translate,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      perspective: perspective ?? this.perspective,
    );
  }

  /// Linearly interpolate between two keyframes.
  static Keyframe3D lerp(Keyframe3D a, Keyframe3D b, double t) {
    final tt = t.clamp(0.0, 1.0);
    return Keyframe3D(
      at: lerpDouble(a.at, b.at, tt),
      rotateX: lerpDouble(a.rotateX, b.rotateX, tt),
      rotateY: lerpDouble(a.rotateY, b.rotateY, tt),
      rotateZ: lerpDouble(a.rotateZ, b.rotateZ, tt),
      translate: Offset(
        lerpDouble(a.translate.dx, b.translate.dx, tt),
        lerpDouble(a.translate.dy, b.translate.dy, tt),
      ),
      scale: lerpDouble(a.scale, b.scale, tt),
      opacity: lerpDouble(a.opacity, b.opacity, tt),
      perspective: lerpDouble(a.perspective, b.perspective, tt),
    );
  }
}

/// Small helper (avoids importing dart:ui explicitly everywhere).
double lerpDouble(double a, double b, double t) => a + (b - a) * t;
