import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/domain/api_client/client_api.dart';
import 'package:ictis_schedule/entity/choices/choice.dart';
import 'package:ictis_schedule/entity/choices/choices.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';

import '../../entity/schedule_response.dart';

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
      final ScheduleTable? table = SettingsDatabase.getTable();
      if (table != null && name == table.groupName) {
        ScheduleResponse response = ScheduleResponse(
          table: table,
          weeks: [table.currentWeek],
        );
        Navigator.of(context).pushNamed(
          '/schedule_detail',
          arguments: {'name': name, 'modal': response},
        );
      } else {
        Navigator.of(context).pushNamed('/error');
      }
    }
  }