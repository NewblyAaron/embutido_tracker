import 'package:embutido_tracker/domain/repositories/auth_repository.dart';
import 'package:embutido_tracker/ui/map/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (context) => MapViewModel(auth: context.read<AuthService>()),
      builder: (context, child) => _MapScreenBody(),
    );
  }
}

class _MapScreenBody extends StatefulWidget {
  @override
  State<_MapScreenBody> createState() => _MapScreenBodyState();
}

class _MapScreenBodyState extends State<_MapScreenBody> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MapViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Embutido"),
        actions: [
          IconButton(
            onPressed: () => viewModel.signOut(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text("Hello world!")),
    );
  }
}
