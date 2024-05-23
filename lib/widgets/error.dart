import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Error extends StatelessWidget {
  const Error({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        translate('error'),
        style: const TextStyle(fontSize: 18.0),
      ),
    );
  }
}
