import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uber_clone_driver_app/pages/home_page.dart';

import 'authentification/login_screen.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if(valueOfPermission){
      Permission.locationWhenInUse.request();
    }
  });
  await Permission.notification.isDenied.then((valueOfPermission) {
    if(valueOfPermission){
      Permission.notification.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: false,
          scaffoldBackgroundColor: Colors.black,
          buttonTheme: ButtonThemeData()),
      home:FirebaseAuth.instance.currentUser==null? LoginScreen():HomePage(),
    );
  }
}
