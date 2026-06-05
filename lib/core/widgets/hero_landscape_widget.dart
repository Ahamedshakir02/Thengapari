import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'painters/kerala_landscape_painter.dart';

/// Homeowner home-screen hero: the [KeralaLandscapePainter] illustration with
/// a greeting chip and subtitle overlaid in the top-left.
class HeroLandscapeWidget extends StatelessWidget {
  final String greeting;
  final String subtitle;

  const HeroLandscapeWidget({
    required this.greeting,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CustomPaint(
          painter: KeralaLandscapePainter(),
          child: SizedBox(width: double.infinity, height: 140),
        ),
        Positioned(
          left: 16,
          top: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AgriColors.green100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(greeting,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF27500A),
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF173404),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
