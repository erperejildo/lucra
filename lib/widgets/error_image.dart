import 'package:flutter/material.dart';

errorImage(BuildContext context) async {
  return Center(
    child: LayoutBuilder(
      builder: (context, constraint) {
        return Icon(
          Icons.broken_image,
          size: constraint.biggest.height - 60.0,
          color: Theme.of(context).primaryColorDark,
        );
      },
    ),
  );
}
