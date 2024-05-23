import 'package:flutter/material.dart';

class Loading {
  late Widget alert;

  load(BuildContext context, String message) async {
    alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
          Container(
              margin: const EdgeInsets.only(left: 16), child: Text(message)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  cancel(BuildContext context) async {
    Navigator.pop(context);
  }
}
