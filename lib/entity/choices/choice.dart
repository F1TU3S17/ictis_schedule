part 'choice.g.dart';

class Choice {
  final String name;
  final String id;
  final String group;

  Choice({required this.name, required this.id, required this.group});

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);
  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
}