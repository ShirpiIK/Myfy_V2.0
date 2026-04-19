import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class MyfyTheme {

  static const Color primaryOrange = Color(0xFFFF6B00);

  static const Color darkBackground = Color(0xFF0A0A0A);

  static const Color surfaceColor = Color(0xFF1C1C1E);

  static const Color textSecondary = Color(0xFF8E8E93);

  static const Color borderColor = Color(0xFF2C2C2E);

  static ThemeData darkTheme() {

    return ThemeData.dark().copyWith(

      scaffoldBackgroundColor: darkBackground,

      primaryColor: primaryOrange,

      colorScheme: const ColorScheme.dark(

        primary: primaryOrange,

        secondary: primaryOrange,

        surface: surfaceColor,

      ),

      textTheme: GoogleFonts.interTextTheme().copyWith(

        titleLarge: const TextStyle(

          fontSize: 28,

          fontWeight: FontWeight.w800,

          color: Colors.white,

          letterSpacing: -0.5,

        ),

        titleMedium: const TextStyle(

          fontSize: 18,

          fontWeight: FontWeight.w600,

          color: Colors.white,

        ),

        bodyLarge: const TextStyle(

          fontSize: 16,

          color: Colors.white,

        ),

        bodyMedium: const TextStyle(

          fontSize: 14,

          color: textSecondary,

        ),

      ),

      appBarTheme: const AppBarTheme(

        backgroundColor: darkBackground,

        elevation: 0,

        centerTitle: false,

        iconTheme: IconThemeData(color: Colors.white),

      ),

      inputDecorationTheme: InputDecorationTheme(

        filled: true,

        fillColor: surfaceColor,

        hintStyle: const TextStyle(color: textSecondary, fontSize: 16),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,

        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,

        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: const BorderSide(color: primaryOrange, width: 1.5),

        ),

        prefixIconColor: primaryOrange,

        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      ),

    );

  }

}