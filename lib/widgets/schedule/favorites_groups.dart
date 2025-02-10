import 'package:flutter/material.dart';
import 'package:ictis_schedule/widgets/schedule/handle_tile_tap.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal_provider.dart';


class FavoritesGroups extends StatelessWidget {
  const FavoritesGroups({super.key});
  @override
  Widget build(BuildContext context) {
    List<String?> favoritesGroupsList = SettingsModalProvider.of(context)!.modal!.favoritesGroupsList;
    if (favoritesGroupsList.isEmpty) {
      return SizedBox(height: 0,);
    }
    return SizedBox(
      height: ((favoritesGroupsList.length < 3 ? favoritesGroupsList.length : 3) * 50),
      child: ListView.builder(
        itemCount: favoritesGroupsList.length,
        itemBuilder: (context, index) {
          final String name = favoritesGroupsList[index]!;
          return ListTile(
                title: Text(name),
                leading: Icon(Icons.star),
                onTap: () async => handleTileTap(context, name));
        },
      ),
    );
  }
}