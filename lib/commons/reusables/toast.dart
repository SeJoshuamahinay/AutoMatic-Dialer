import 'package:flutter/material.dart';

enum ShowToast { error, warning, success, notification }

void toast(BuildContext context, String message, ShowToast type) {
  Color bgColor;
  IconData icon;

  switch (type) {
    case ShowToast.error:
      bgColor = Colors.redAccent;
      icon = Icons.error;
      break;
    case ShowToast.warning:
      bgColor = Colors.orangeAccent;
      icon = Icons.warning;
      break;
    case ShowToast.success:
      bgColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case ShowToast.notification:
      bgColor = const Color.fromARGB(255, 136, 163, 210);
      icon = Icons.info;
      break;
  }

  final toast = SnackBar(
    content: Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(message, style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(toast);
}
