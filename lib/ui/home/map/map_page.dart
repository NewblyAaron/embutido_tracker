import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/gps_service.dart';
import 'package:embutido_tracker/domain/services/permission_service.dart';
import 'package:embutido_tracker/ui/home/map/map_pin_marker.dart';
import 'package:embutido_tracker/ui/home/map/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create:
          (context) => MapViewModel(
            context.read<UserRepository>(),
            context.read<GPSService>(),
            context.read<PermissionService>(),
          ),
      builder: (context, child) => _MapPageBody(),
    );
  }
}

class _MapPageBody extends StatefulWidget {
  @override
  State<_MapPageBody> createState() => _MapPageBodyState();
}

class _MapPageBodyState extends State<_MapPageBody>
    with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;

  @override
  void initState() {
    super.initState();

    _mapController = AnimatedMapController(vsync: this);

    final viewModel = context.read<MapViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // error message handling
      viewModel.errorStream.listen((err) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      });

      // initialize
      await viewModel.initialize();

      // move and zoom camera to where user is on first load
      final position = await viewModel.currentLocationStream.first;
      _mapController.animateTo(
        dest: LatLng(position.latitude, position.longitude),
        curve: Curves.ease,
        duration: const Duration(seconds: 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController.mapController,
        options: MapOptions(
          initialCenter: LatLng(12.8797, 121.7740),
          initialZoom: 6,
          keepAlive: true,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'me.newbly.embutido',
          ),
          _buildCurrentUserMarker(context),
        ],
      ),
    );
  }

  StreamBuilder<Position> _buildCurrentUserMarker(BuildContext context) {
    return StreamBuilder<Position>(
      stream: context.watch<MapViewModel>().currentLocationStream,
      builder: (context, snapshot) {
        final position = snapshot.data;
        if (position == null) return const SizedBox();

        final latLngPos = LatLng(position.latitude, position.longitude);

        return MarkerLayer(
          markers: [
            Marker(
              width: 70,
              height: 80,
              point: latLngPos,
              alignment: Alignment.topCenter,
              child: PinMarker(
                user: context.watch<User>(),
                onTap:
                    () => _mapController.animateTo(
                      dest: latLngPos,
                      curve: Curves.ease,
                      zoom: 17,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}
