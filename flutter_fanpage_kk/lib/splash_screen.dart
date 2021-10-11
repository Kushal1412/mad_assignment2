import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_fanpage_kk/user_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateHome();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 600,
              width: 600,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/MyImage.jpeg"))),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: const Text("Kushal Khatri's Fanpage App"),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateHome() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.hasData) {
                  return User_Login();
                } else {
                  return User_Login();
                }
              }),
        ));
  }
}
