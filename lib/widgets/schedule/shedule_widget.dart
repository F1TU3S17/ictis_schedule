import 'package:flutter/material.dart';
import 'package:ictis_schedule/domain/api_client/client_api.dart';
import 'package:ictis_schedule/entity/choices/choice.dart';
import 'package:ictis_schedule/entity/choices/choices.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal_provider.dart';

class SheduleWidget extends StatefulWidget {
  const SheduleWidget({super.key});

  @override
  State<SheduleWidget> createState() => _SheduleWidgetState();
}

class _SheduleWidgetState extends State<SheduleWidget> {
  List<String> names = [];

  Future<String> fetchNameData(String query) async {
    String name;
    try {
      final response = await ClientApi.getByQuery(query);
      name = response.table.groupName;
    } catch (e) {
      name = '';
    }

    return name;
  }

  Future<void> handleTileTap(BuildContext context, String name) async {
    try {
      dynamic response = await ClientApi.getByQuery(name);

      if (response is Choices) {
        for (Choice choice in response.choices) {
          if (choice.name == name) {
            response = await ClientApi.getByGroupId(choice.group);
            break;
          }
        }
      }

      Navigator.of(context).pushNamed(
        '/schedule_detail',
        arguments: {'name': name, 'modal': response},
      );
    } catch (e) {
      print('Ошибка при обработке запроса: $e');
    }
  }

  Future<void> fetchNamesData(String query) async {
    final response;
    try {
      response = await ClientApi.getByQuery(query);
    } catch (e) {
      return;
    }
    try {
      names = await response.getChoicesNames();
    } catch (e) {
      String name = await fetchNameData(query);
      names = [];
      names.add(name);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String? userGroupName = SettingsModalProvider.of(context)!.modal?.groupName;
    return SafeArea(
        child: Column(
      children: [
        TextField(
          onChanged: (text) async {
            if (text.isNotEmpty) {
              await fetchNamesData(text);
            } else {
              names = [];
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Поиск',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            filled: true,
            fillColor: Colors.white.withAlpha(20),
            contentPadding: EdgeInsets.all(8),
          ),
        ),
        userGroupName != null
            ? ListTile(
                title: Text(userGroupName),
                leading: Icon(Icons.star),
                onTap: () async => handleTileTap(context, userGroupName))
            : SizedBox(
                height: 4.0,
              ),
        Expanded(
          child: ListView.builder(
              itemCount: names.length,
              itemBuilder: (BuildContext context, int index) {
                final name = names[index];
                return ListTile(
                    title: Text(name),
                    onTap: () async => handleTileTap(context, name));
              }),
        ),
      ],
    ));
  }
}
