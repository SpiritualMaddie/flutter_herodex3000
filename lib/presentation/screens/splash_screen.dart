import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    Timer(const Duration(seconds: 15), () {
      if (mounted) {
        return;
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
