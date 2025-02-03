import 'package:hive/hive.dart';

@HiveType(typeId: 0) 
class ScheduleTable extends HiveObject { 
  @HiveField(0)
  final String type;
  
  @HiveField(1)
  final String groupLink;
  
  @HiveField(2)
  final int currentWeek;
  
  @HiveField(3)
  final String groupName;
  
  @HiveField(4)
  final List<List<String>> table;

  ScheduleTable({
    required this.type,
    required this.groupName,
    required this.currentWeek,
    required this.groupLink,
    required this.table,
  });

  // Остальные методы остаются без изменений
  factory ScheduleTable.fromJson(Map<String, dynamic> json) => _$ScheduleTableFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleTableToJson(this);

  int getCountSubjects() {
    final count = table[0].length - 1;
    return count;
  }

  List<String> getSubjectsTime() {
    List<String> subjectsTime = [];
    for (int i = 1; i < table[1].length; i++) {
      subjectsTime.add(table[1][i]);
    }
    return subjectsTime;
  }

  // 1 - константа, так как с 2го индекса table начинается расписание дней недели
  List<String> getCurrentDay(int dayIndex) {
    if (1 + dayIndex >= table.length) {
      final List<String> emptyList = [];
      return emptyList;
    }
    List<String> day = table[1 + dayIndex];
    return day.sublist(1);
  }

  String getCurrentDayByDayIndex(int dayIndex){
    String str = table[1 + dayIndex][0].split(',')[1].replaceAll("  ", " ");
    if (str[0] == '0'){
      return str.substring(1);
    }
    return str;
  }

}


ScheduleTable _$ScheduleTableFromJson(Map<String, dynamic> json) =>
    ScheduleTable(
      type: json['type'] as String,
      groupName: json['link'] as String,
      currentWeek: (json['week'] as num).toInt(),
      groupLink: json['group'] as String,
      table: (json['table'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
    );

Map<String, dynamic> _$ScheduleTableToJson(ScheduleTable instance) =>
    <String, dynamic>{
      'type': instance.type,
      'group': instance.groupLink,
      'week': instance.currentWeek,
      'link': instance.groupName,
      'table': instance.table,
    };



class ScheduleTableAdapter extends TypeAdapter<ScheduleTable> {
  @override
  final int typeId = 0;

  @override
  ScheduleTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleTable(
      type: fields[0] as String,
      groupName: fields[3] as String,
      currentWeek: fields[2] as int,
      groupLink: fields[1] as String,
      table: (fields[4] as List)
          .map((dynamic e) => (e as List).cast<String>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleTable obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.groupLink)
      ..writeByte(2)
      ..write(obj.currentWeek)
      ..writeByte(3)
      ..write(obj.groupName)
      ..writeByte(4)
      ..write(obj.table);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
