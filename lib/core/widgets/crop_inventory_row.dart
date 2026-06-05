import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../models/crop_summary.dart';

/// Horizontal scrollable row of crop chips shown in the homeowner hero area.
/// Each chip shows the crop glyph, name and quantity.
class CropInventoryRow extends StatelessWidget {
  final List<CropSummary> crops;

  const CropInventoryRow({required this.crops, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: crops.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AgriColors.green100, width: 0.5),
          ),
          child: Row(
            children: [
              Text(crops[i].icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(crops[i].name,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3B6D11),
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Text(crops[i].quantity,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF639922))),
            ],
          ),
        ),
      ),
    );
  }
}
