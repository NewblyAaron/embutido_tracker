import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/ui/home/map/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (context) => MapViewModel(context.read<UserRepository>()),
      builder: (context, child) => _MapPageBody(),
    );
  }
}

class _MapPageBody extends StatefulWidget {
  @override
  State<_MapPageBody> createState() => _MapPageBodyState();
}

class _MapPageBodyState extends State<_MapPageBody> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final viewModel = context.read<MapViewModel>();

    return Center(child: Text("Map Screen"));
  }
}
