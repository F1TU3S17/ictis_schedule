import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ictis_schedule/entity/choices/choices.dart';
import 'package:ictis_schedule/entity/schedule_response.dart';

class ClientApi {
  static final baseUrl = "https://shedule.rdcenter.ru/schedule-api";

  static Future<dynamic> getByQuery(String query) async {
    final url = Uri.parse("$baseUrl/?query=$query");
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    if (json.containsKey('result') && json['result'] == 'no_entries') {
      return null;
    }
    if (json.containsKey('choices')) {
      final Choices choices = Choices.fromJson(json);
      return choices;
    } 
    if (json.containsKey('table')) {
      ScheduleResponse scheduleResponse = ScheduleResponse.fromJson(json);
      return scheduleResponse;
    }
  }

  static Future<ScheduleResponse> getByGroupId(String gropuid) async {
    final url =
        Uri.parse("$baseUrl/?group=$gropuid");
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    ScheduleResponse scheduleResponse = ScheduleResponse.fromJson(json);
    return scheduleResponse;
  }

  static Future<ScheduleResponse> getByGroupIdAndWeek(
      String gropuid, int week) async {
    final url = Uri.parse(
        "$baseUrl/?group=$gropuid&week=$week");
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    ScheduleResponse scheduleResponse = ScheduleResponse.fromJson(json);
    return scheduleResponse;
  }
}

