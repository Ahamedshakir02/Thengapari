import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../models/crop_listing.dart';

/// A crop listing row in the B2B inventory browser. The savings badge is shown
/// prominently — it is the primary conversion hook — alongside a Pre-book CTA.
class LiveInventoryTile extends StatelessWidget {
  final CropListing listing;
  final VoidCallback onPreBook;

  const LiveInventoryTile(
      {required this.listing, required this.onPreBook, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: listing.bgColor, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(listing.icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(listing.name,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(
                '${listing.harvestedLabel} · ${listing.location} · ${listing.quantity}',
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF888888))),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(listing.priceLabel,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF185FA5))),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AgriColors.green50,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(listing.savingLabel,
                style:
                    const TextStyle(fontSize: 9, color: Color(0xFF27500A))),
          ),
        ]),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onPreBook,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Pre-book',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    );
  }
}
