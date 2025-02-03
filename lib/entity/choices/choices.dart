import 'package:ictis_schedule/entity/choices/choice.dart';
import 'package:json_annotation/json_annotation.dart';
part 'choices.g.dart';


@JsonSerializable()
class Choices {
  @JsonKey(name: 'choices')
  final List<Choice> choices;

  Choices({required this.choices});

  factory Choices.fromJson(Map<String, dynamic> json) =>
      _$ChoicesFromJson(json);

  List<String> getChoicesNames() {
    List<String> names = [];
    for (Choice choice in choices) {
      names.add(choice.name);
    }
    return names;
  }

  Map<String, dynamic> toJson() => _$ChoicesToJson(this);
}