import 'package:ictis_schedule/entity/schedule_table.dart';


class ScheduleResponse{
  final ScheduleTable table;
  final List<int> weeks;

  ScheduleResponse({
    required this.table,
    required this.weeks,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) => _$ScheduleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleResponseToJson(this);
}

ScheduleResponse _$ScheduleResponseFromJson(Map<String, dynamic> json) =>
    ScheduleResponse(
      table: ScheduleTable.fromJson(json['table'] as Map<String, dynamic>),
      weeks: (json['weeks'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ScheduleResponseToJson(ScheduleResponse instance) =>
    <String, dynamic>{
      'table': instance.table,
      'weeks': instance.weeks,
    };
