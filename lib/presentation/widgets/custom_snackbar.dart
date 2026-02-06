import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
// TODO fix to work if time to work as all snackbars
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