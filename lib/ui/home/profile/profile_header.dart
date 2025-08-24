import 'package:cached_network_image/cached_network_image.dart';
import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/core/services/image_service.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/ui/home/profile/profile_viewmodel.dart';
import 'package:embutido_tracker/ui/widgets/dialogs/edit_username_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  void _onEditUserNamePressed(
    BuildContext context,
    String currentUsername,
  ) async {
    final newUsername = await showEditUsernameDialog(
      context: context,
      currentUsername: currentUsername,
    );

    if (newUsername == null || newUsername.isEmpty || !context.mounted) return;
    context.read<ProfileViewModel>().updateUsername(newUsername);
  }

  void _onEditAvatarPressed(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    LoggerAccess.logger.debug("Picked image path: ${image.path}");
    final imageBytes = await image.readAsBytes();

    if (!context.mounted) return;
    final converted = context.read<ImageService>().normalizeToPng(imageBytes);
    context.read<ProfileViewModel>().updateAvatar(converted);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();
    final isLoading = context.select<ProfileViewModel, bool>(
      (vm) => vm.isUploading,
    );

    return SizedBox(
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/embutido.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage:
                      user.avatarUrl != null && !isLoading
                          ? CachedNetworkImageProvider(user.avatarUrl!)
                          : null,
                  child: Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          () =>
                              !isLoading ? _onEditAvatarPressed(context) : null,
                      child:
                          !isLoading
                              ? SizedBox.expand(
                                child:
                                    user.avatarUrl != null
                                        ? null
                                        : Icon(Icons.add_a_photo, size: 36),
                              )
                              : CircularProgressIndicator(),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user.name ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed:
                      () => _onEditUserNamePressed(context, user.name ?? ''),
                  icon: Icon(Icons.edit),
                  tooltip: "Edit username",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
