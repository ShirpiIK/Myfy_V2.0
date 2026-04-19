import 'package:flutter/material.dart';

import 'home_screen.dart';

import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override

  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _fadeAnimation;

  late Animation<double> _scaleAnimation;

  @override

  void initState() {

    super.initState();

    _controller = AnimationController(

      vsync: this,

      duration: const Duration(milliseconds: 2000),

    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(

      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),

    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(

      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),

    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(builder: (_) => const HomeScreen()),

      );

    });

  }

  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: MyfyTheme.darkBackground,

      body: Center(

        child: FadeTransition(

          opacity: _fadeAnimation,

          child: ScaleTransition(

            scale: _scaleAnimation,

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Container(

                  width: 100,

                  height: 100,

                  decoration: BoxDecoration(

                    gradient: const LinearGradient(

                      colors: [MyfyTheme.primaryOrange, Color(0xFFFF8C33)],

                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,

                    ),

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [

                      BoxShadow(

                        color: MyfyTheme.primaryOrange.withOpacity(0.4),

                        blurRadius: 30,

                        spreadRadius: 5,

                      ),

                    ],

                  ),

                  child: const Icon(

                    Icons.headphones_rounded,

                    size: 60,

                    color: Colors.white,

                  ),

                ),

                const SizedBox(height: 24),

                Text(

                  'Myfy',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                        fontSize: 48,

                        foreground: Paint()

                          ..shader = const LinearGradient(

                            colors: [Colors.white, MyfyTheme.primaryOrange],

                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),

                      ),

                ),

                const SizedBox(height: 8),

                const Text(

                  'YOUR MUSIC · YOUR WAY',

                  style: TextStyle(

                    color: MyfyTheme.textSecondary,

                    letterSpacing: 3,

                    fontSize: 12,

                  ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}