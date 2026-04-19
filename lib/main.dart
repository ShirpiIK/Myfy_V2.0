importimport 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

import 'utils/theme.dart';

void main() {

  runApp(const MyfyApp());

}

class MyfyApp extends StatelessWidget {

  const MyfyApp({super.key});

  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Myfy',

      debugShowCheckedModeBanner: false,

      theme: MyfyTheme.darkTheme(),

      home: const SplashScreen(),

    );

  }

}