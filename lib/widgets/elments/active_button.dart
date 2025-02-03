import 'package:flutter/material.dart';

class ActiveButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback func;
  final String title;
  const ActiveButton(
      {super.key,
      required this.title,
      required this.func,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: func,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(isActive
            ? theme.colorScheme.secondary
            : theme.colorScheme.tertiary),
      ),
      child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
