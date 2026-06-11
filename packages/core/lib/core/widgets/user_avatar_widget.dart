import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Circular user avatar. Shows the network [imageUrl] (cached) when provided,
/// otherwise falls back to the user's initials on a green tint. An optional
/// [online] dot can be shown at the bottom-right.
class UserAvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final bool? online;

  const UserAvatarWidget({
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.online,
    super.key,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AgriColors.green100,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => _initialsLabel(),
              errorWidget: (_, _, _) => _initialsLabel(),
            )
          : _initialsLabel(),
    );

    if (online == null) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online! ? AgriColors.green400 : const Color(0xFFB4B2A9),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialsLabel() => Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          color: AgriColors.green800,
        ),
      );
}
