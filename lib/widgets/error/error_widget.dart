import 'package:flutter/material.dart';

class ErrorPageWidget extends StatelessWidget {
  const ErrorPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ошибка"),
        ),
        body: Center(
          child: Text(
              "Произошла ошибка, проврьте подключение к интернету, либо же проблема на стороне сервера"),
        ));
  }
}
