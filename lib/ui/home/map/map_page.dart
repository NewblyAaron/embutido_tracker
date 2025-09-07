import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/group_repository.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/gps_service.dart';
import 'package:embutido_tracker/domain/services/permission_service.dart';
import 'package:embutido_tracker/domain/services/user_location_service.dart';
import 'package:embutido_tracker/ui/home/map/map_group_select_modal.dart';
import 'package:embutido_tracker/ui/home/map/map_pin_marker.dart';
import 'package:embutido_tracker/ui/home/map/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
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
            context.read<GroupRepository>(),
            context.read<GPSService>(),
            context.read<PermissionService>(),
            context.read<UserLocationService>(),
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
  late final MapViewModel _viewModel;
  late final AnimatedMapController _mapController;

  @override
  void initState() {
    super.initState();

    _mapController = AnimatedMapController(vsync: this);

    _viewModel = context.read<MapViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // error message handling
      _viewModel.errorStream.listen((err) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      });

      // initialize
      await _viewModel.initialize();

      // move and zoom camera to where user is on first load
      final position = await _viewModel.currentLocationStream.first;
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
          MapCompass(
            icon: Material(
              elevation: 2,
              clipBehavior: Clip.hardEdge,
              shape: CircleBorder(),
              child: InkWell(
                onTap:
                    () => _mapController.animatedRotateReset(
                      curve: Curves.fastOutSlowIn,
                    ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.north),
                ),
              ),
            ),
          ),

          _buildCurrentUserMarker(),
          _buildGroupSelectButton(),
          _buildGroupMembersListButton(),

          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(bottom: 8, right: 8),
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildGroupMembersListButton() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 8),
      child: StreamBuilder(
        stream: _viewModel.usersPositionStream,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data!.isEmpty == true) {
            return Container(); // nothing
          }

          final users = snapshot.data!.values.map((e) => e.user).toList();

          return Material(
            borderRadius: BorderRadius.circular(20),
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...[
                      for (final user in users)
                        CircleAvatar(
                          backgroundImage:
                              user.avatarUrl != null
                                  ? CachedNetworkImageProvider(user.avatarUrl!)
                                  : null,
                          child:
                              user.avatarUrl == null
                                  ? Text(user.name?.substring(0, 1) ?? "?")
                                  : null,
                        ),
                    ].sublist(0, min(3, users.length)),
                    if (users.length > 3)
                      CircleAvatar(child: Text("+${users.length - 3}")),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Container _buildGroupSelectButton() {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 14.0),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap:
              () => showModalBottomSheet(
                context: context,
                builder:
                    (context) => ChangeNotifierProvider.value(
                      value: _viewModel,
                      child: MapGroupSelectModal(
                        futureGroups: _viewModel.getGroups(),
                      ),
                    ),
              ),
          child: Container(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 200),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Row(
              children: [
                const Icon(Icons.group),
                SizedBox(width: 8),
                Expanded(
                  child: Consumer<MapViewModel>(
                    builder:
                        (context, vm, _) => Text(
                          vm.currentGroup == null
                              ? "Select a group..."
                              : vm.currentGroup!.name,
                          textAlign: TextAlign.center,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StreamBuilder<Position> _buildCurrentUserMarker() {
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
              rotate: true,
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
