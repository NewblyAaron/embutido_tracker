import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/ui/home/map/map_group_create_dialog.dart';
import 'package:embutido_tracker/ui/home/map/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapGroupSelectModal extends StatelessWidget {
  final Future<List<Group>> futureGroups;

  const MapGroupSelectModal({super.key, required this.futureGroups});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MapViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Select a group"),
        actions: [
          IconButton.filled(
            onPressed: () async {
              final String? groupName = await showDialog(
                context: context,
                builder:
                    (context) => ChangeNotifierProvider.value(
                      value: viewModel,
                      builder: (_, _) => CreateGroupDialog(),
                    ),
              );

              if (groupName == null || groupName.isEmpty) return;

              await viewModel.createGroup(groupName);
            },
            tooltip: "Create a group",
            icon: const Icon(Icons.group_add, color: Colors.white),
          ),
          IconButton.filled(
            onPressed: () async {
              final String? joinCode = await showDialog(
                context: context,
                builder:
                    (context) => ChangeNotifierProvider.value(
                      value: viewModel,
                      builder: (_, _) => CreateGroupDialog(),
                    ),
              );

              if (joinCode == null || joinCode.isEmpty) return;

              await viewModel.joinGroup(joinCode);
            },
            tooltip: "Join a group",
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder(
        future: futureGroups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No groups found"));
          }

          final groups = snapshot.data!;

          return ListView.separated(
            itemBuilder:
                (context, index) => ListTile(
                  title: Text(groups[index].name),
                  trailing: Text(groups[index].joinCode!),
                  onTap: () {
                    viewModel.selectGroup(groups[index]);
                    Navigator.pop(context);
                  },
                ),
            separatorBuilder: (_, _) => Divider(),
            itemCount: groups.length,
          );
        },
      ),
    );
  }
}
