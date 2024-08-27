import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if the user's email and password are stored in local storage
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? storedEmail = prefs.getString('email');
  final String? storedPassword = prefs.getString('password');

  runApp(MyApp(storedEmail: storedEmail, storedPassword: storedPassword));
}

class MyApp extends StatelessWidget {
  final String? storedEmail;
  final String? storedPassword;

  const MyApp({super.key, this.storedEmail, this.storedPassword});

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;

    final isLoggedIn = storedEmail != null && storedPassword != null;

    if (isLoggedIn) {
      // Check if the stored credentials are valid
      initialScreen = FutureBuilder(
        future: FirebaseAuth.instance.signInWithEmailAndPassword(
          email: storedEmail!,
          password: storedPassword!,
        ),
        builder: (BuildContext context, AsyncSnapshot<UserCredential> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              // Stored credentials are invalid
              return const WelcomeScreen();
            } else {
              // Stored credentials are valid
              return const MainPage();
            }
          }
        },
      );
    } else {
      final seenOnboarding = SharedPreferences.getInstance()
          .then((prefs) => prefs.getBool('seenOnboarding') ?? false);

      initialScreen = FutureBuilder<bool>(
        future: seenOnboarding,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == false) {
              return const OnboardingScreen();
            } else {
              return const WelcomeScreen();
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    }

    return MaterialApp(
      title: 'EcoMobilize',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}
