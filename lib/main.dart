import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:thatsnot/pages/start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /*if (Firebase.app().name == '[DEFAULT]') {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }*/
  runApp(const ThatsNot());
}

class ThatsNot extends StatelessWidget {
  const ThatsNot({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return const MaterialApp(
      home: StartPage(),
    );
  }
}
