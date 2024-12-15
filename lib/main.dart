import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File yang dihasilkan oleh flutterfire configure
import 'screens/welcome_page.dart';
import 'screens/landing_page.dart';
import 'screens/register_page.dart';
import 'screens/login_page.dart';
import 'screens/homepage.dart'; // Impor HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chasierly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: WelcomePage(), // Tetap mulai dari WelcomePage
      routes: {
        '/landing': (context) => LandingPage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(
              userId: ModalRoute.of(context)!.settings.arguments as String,
            ),
      },
    );
  }
}
