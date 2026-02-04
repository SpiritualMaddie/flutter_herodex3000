import 'dart:async';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    Timer(const Duration(seconds: 20), () {
      if (mounted) {
        //context.go("/login");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/splash_screen/splash_screen.png',
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Column(
            mainAxisAlignment: .end,
            children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(55, 10, 55, 10),
                  child: LinearProgressIndicator(color: Theme.of(context).colorScheme.primary,),
                ),
                Text("Loading..."),
                SizedBox(height: 50,)
            ],
          ),
        ],
      ),
    );
  }
}
