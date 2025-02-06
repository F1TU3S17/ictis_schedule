import 'package:flutter/material.dart';
import 'package:ictis_schedule/widgets/subject_list/current_day_subjects_list_widget.dart';

class SubjectBodyWidget extends StatelessWidget {
  const SubjectBodyWidget({
    super.key,
    required this.subjectTime,
    required this.subject,
    required this.viewProgress,
  });

  final String subjectTime;
  final String subject;
  final bool viewProgress;

  @override
  Widget build(BuildContext context) {
    String _subject = subject;
    if (subject == "") {
      _subject = "Окно";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subjectTime, style: Theme.of(context).textTheme.bodyLarge),
        Text(_subject),
        const SizedBox(height: 4),
        viewProgress ? (SubjectTimeProgressWidget(subjectTime: subjectTime)) : (SizedBox()),
      ],
    );
  }
}
