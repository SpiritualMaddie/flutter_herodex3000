import 'package:flutter/material.dart';
// TODO fix to work if time
class CustomSnackbar extends StatelessWidget {
  final String text;
  final bool isSuccess;
  const CustomSnackbar({super.key, required this.text, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
            content: Center(
              child: Text(
                text,
                style: TextStyle(fontWeight: .bold, letterSpacing: 1.5),
              ),
            ),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          );
  }
}