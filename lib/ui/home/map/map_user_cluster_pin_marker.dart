import 'package:cached_network_image/cached_network_image.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class UserClusterPinMarker extends StatelessWidget {
  final List<Marker> _markers;
  final Function()? onTap;

  UserClusterPinMarker({super.key, required List<Marker> markers, this.onTap})
    : _markers = markers;

  late final List<User> _users =
      _markers.map((e) => (e.key as ValueKey<User>).value).toList();

  final double avatarRadius = 20.0;

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
              child: _buildUserAvatars(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatars() {
    return InkWell(
      onTap: onTap,
      child: Stack(children: [_buildPositionedAvatars()]),
    );
  }

  Widget _buildPositionedAvatars() {
    final usersToShow = _users.take(4).toList();
    final remainingCount = _users.length - 4;

    return LayoutBuilder(
      builder:
          (context, constraints) => Stack(
            children: [
              ...usersToShow.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;

                if (_users.length >= 5 && index == 3) {
                  final position = _getAvatarPosition(
                    index,
                    usersToShow.length,
                    constraints,
                  );
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.grey.shade600,
                      child: Text(
                        '+${remainingCount + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                return _buildSinglePositionedAvatar(
                  user,
                  index,
                  usersToShow.length,
                  constraints,
                );
              }),
            ],
          ),
    );
  }

  Widget _buildSinglePositionedAvatar(
    User user,
    int index,
    int totalShown,
    BoxConstraints constraints,
  ) {
    final position = _getAvatarPosition(index, totalShown, constraints);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: CircleAvatar(
        radius: avatarRadius,
        backgroundImage:
            user.avatarUrl != null
                ? CachedNetworkImageProvider(user.avatarUrl!)
                : null,
        child:
            user.avatarUrl == null
                ? Text(user.name?.substring(0, 1) ?? "?")
                : null,
      ),
    );
  }

  Offset _getAvatarPosition(int index, int total, BoxConstraints constraints) {
    final double width = constraints.maxWidth;
    final double height = constraints.maxHeight;
    const double padding = 4.0;

    switch (total) {
      case 2:
        // Horizontal line: left and right
        return index == 0
            ? Offset(padding, height / 2 - avatarRadius)
            : Offset(
              width - avatarRadius * 2 - padding,
              height / 2 - avatarRadius,
            );

      case 3:
        // Triangle formation
        if (index == 0) {
          // Top center
          return Offset(width / 2 - avatarRadius, padding);
        } else if (index == 1) {
          // Bottom left
          return Offset(padding, height - avatarRadius * 2 - padding);
        } else {
          // Bottom right
          return Offset(
            width - avatarRadius * 2 - padding,
            height - avatarRadius * 2 - padding,
          );
        }

      default: // 4 or more
        // Four corners
        switch (index) {
          case 0:
            // Top left
            return Offset(padding, padding);
          case 1:
            // Top right
            return Offset(width - avatarRadius * 2 - padding, padding);
          case 2:
            // Bottom left
            return Offset(padding, height - avatarRadius * 2 - padding);
          case 3:
            // Bottom right
            return Offset(
              width - avatarRadius * 2 - padding,
              height - avatarRadius * 2 - padding,
            );
          default:
            return Offset(0, 0);
        }
    }
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
