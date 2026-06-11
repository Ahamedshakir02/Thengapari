import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme.dart';

/// Skeleton placeholder shown while a job card's Firestore data loads. Mirrors
/// the [JobStatusCard] silhouette so the layout doesn't jump when real data
/// arrives.
class ShimmerJobCard extends StatelessWidget {
  const ShimmerJobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.border, width: 0.5),
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFEDEDE7),
        highlightColor: const Color(0xFFF7F7F2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                _Bar(width: 120, height: 12),
                Spacer(),
                _Bar(width: 56, height: 16, radius: 999),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _Bar(width: 90, height: 9),
                Spacer(),
                _Bar(width: 60, height: 9),
              ],
            ),
            SizedBox(height: 10),
            _Bar(width: double.infinity, height: 3, radius: 999),
          ],
        ),
      ),
    );
  }
}

/// A single shimmering block. Standalone so it can also stand in for one line
/// of text (e.g. a header) while loading.
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({this.width = 140, this.height = 12, super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEDEDE7),
      highlightColor: const Color(0xFFF7F7F2),
      child: _Bar(width: width, height: height),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Bar({required this.width, required this.height, this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
