import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [Text("Error: $message")]),
    );
  }
}
