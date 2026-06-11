import 'package:flutter/material.dart';

/// Live decrementing countdown shown on the Worker ping screen. The number
/// color shifts from white → amber → red as time runs out, conveying urgency.
/// Designed to sit on the dark teal ping background.
class CountdownTimerWidget extends StatelessWidget {
  final int seconds;

  const CountdownTimerWidget({required this.seconds, super.key});

  Color get _urgencyColor {
    if (seconds > 20) return Colors.white;
    if (seconds > 10) return const Color(0xFFFAC775);
    return const Color(0xFFF09595);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Respond within',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9FE1CB))),
              const SizedBox(height: 2),
              Text('${seconds}s',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: _urgencyColor,
                  )),
            ],
          ),
          const Spacer(),
          // Three dot pulse indicator
          Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5DCAA5).withValues(alpha: 1.0 - i * 0.35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
