import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:embutido_tracker/ui/home/profile/profile_header.dart';
import 'package:embutido_tracker/ui/home/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create:
          (context) => ProfileViewModel(
            context.read<UserRepository>(),
            context.read<AuthService>(),
          ),
      builder: (context, child) => _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  @override
  State<_ProfileBody> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfileBody> {
  void _onLogoutPressed() async {
    final confirm = await _showConfirmDialog();

    if (!mounted || confirm != true) return;
    await context.read<ProfileViewModel>().signOut();
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Log Out"),
            content: Text("Are you sure you want to sign out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Yes"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ProfileHeader(),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ElevatedButton.icon(
              onPressed: _onLogoutPressed,
              icon: Icon(Icons.logout),
              label: Text("Log out"),
            ),
          ),
        ],
      ),
    );
  }
}
