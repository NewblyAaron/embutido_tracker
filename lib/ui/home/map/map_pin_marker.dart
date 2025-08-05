import 'package:cached_network_image/cached_network_image.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:flutter/material.dart';

class PinMarker extends StatelessWidget {
  final User _user;
  final Function()? onTap;

  const PinMarker({super.key, required User user, this.onTap}) : _user = user;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _PinClipper(),
      child: Material(
        type: MaterialType.transparency,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          child: InkWell(
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: _buildUserAvatar(),
            ),
          ),
        ),
      ),
    );
  }

  Ink _buildUserAvatar() {
    return Ink(
      decoration:
          _user.avatarUrl != null
              ? BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(_user.avatarUrl!),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              )
              : null,
      child: _user.avatarUrl == null ? const Icon(Icons.person_pin) : null,
    );
  }
}

class _PinClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchHeight = 10.0;
    final rectHeight = size.height - notchHeight;

    final path =
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(0, 0, size.width, rectHeight),
              const Radius.circular(12),
            ),
          )
          ..moveTo(size.width / 2 - 10, rectHeight)
          ..lineTo(size.width / 2, rectHeight + notchHeight)
          ..lineTo(size.width / 2 + 10, rectHeight)
          ..close();

    return path;
  }

  @override
  bool shouldReclip(_PinClipper oldClipper) => false;
}
