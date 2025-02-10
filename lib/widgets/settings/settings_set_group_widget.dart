import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/domain/api_client/client_api.dart';
import 'package:ictis_schedule/entity/choices/choice.dart';
import 'package:ictis_schedule/entity/choices/choices.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal_provider.dart';

class SettingsSetGroupWidget extends StatefulWidget {
  const SettingsSetGroupWidget({super.key});

  @override
  State<SettingsSetGroupWidget> createState() => _SettingsSetGroupWidgetState();
}

class _SettingsSetGroupWidgetState extends State<SettingsSetGroupWidget> {
  List<String> names = [];

  Future<String> fetchNameData(String query) async {
    String name;
    try {
        final response = await ClientApi.getByQuery(query);
        name = response.table.groupName;
    }
    catch (e) {
        name = '';
    }

    return name;
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
    return Scaffold(
        appBar: AppBar(),
        body: Column(
      children: [
        TextField(
          onChanged: (text) async{
            if (text.isNotEmpty){
              await fetchNamesData(text);
            }
            else{
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
        Expanded(
          child: ListView.builder(
              itemCount: names.length,
              itemBuilder: (BuildContext context, int index) {
                final name = names[index];
                return ListTile(
                  title: Text(name), 
                  onTap: () async{
                    dynamic response = await ClientApi.getByQuery(name);
                    if (response is Choices) {
                      for (Choice choice in response.choices) {
                        if (choice.name == name) {
                          response = await ClientApi.getByGroupId(choice.group);
                          break;
                        }
                      }
                    }
                    SettingsModalProvider.of(context)!.modal!.addGroupInfoWithNotification(name);
                    SettingsModalProvider.of(context)!.modal!.setGroupInfo(response.table);
                    Navigator.of(context).pop();
                  }
                );
              }),
        ),
      ],
    ));
  }
}
