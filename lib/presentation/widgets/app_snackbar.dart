import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

class AppSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    bool isSuccess = true,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isSuccess
          ? Colors.green.withAlpha(90)
          : Colors.red.withAlpha(90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) {
    show(context: context, message: message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context: context, message: message, isSuccess: false);
  }
}
