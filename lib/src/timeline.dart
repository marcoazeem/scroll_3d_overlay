import 'package:flutter/foundation.dart';
import 'keyframe.dart';

/// Converts a scroll offset into an interpolated [Keyframe3D].
///
/// Rules:
/// - Keyframes are sorted by [Keyframe3D.at].
/// - If offset is before first keyframe: return first.
/// - If offset is after last keyframe: return last.
/// - Otherwise, find surrounding keyframes and lerp between them.
@immutable
class ScrollTimeline3D {
  ScrollTimeline3D({required List<Keyframe3D> keyframes})
    : keyframes = List<Keyframe3D>.unmodifiable(
        (List<Keyframe3D>.from(keyframes)
          ..sort((a, b) => a.at.compareTo(b.at))),
      ) {
    assert(
      this.keyframes.isNotEmpty,
      'ScrollTimeline3D requires at least one keyframe.',
    );
  }

  final List<Keyframe3D> keyframes;

  Keyframe3D sample(double offset) {
    if (keyframes.length == 1) return keyframes.first;

    // Clamp before/after
    final first = keyframes.first;
    final last = keyframes.last;
    if (offset <= first.at) return first;
    if (offset >= last.at) return last;

    // Find segment (simple linear scan; fine for small lists)
    for (int i = 0; i < keyframes.length - 1; i++) {
      final a = keyframes[i];
      final b = keyframes[i + 1];

      if (offset >= a.at && offset <= b.at) {
        final span = (b.at - a.at);
        final t = span == 0 ? 0.0 : ((offset - a.at) / span);
        return Keyframe3D.lerp(a, b, t);
      }
    }

    // Fallback (should never hit)
    return last;
  }
}
