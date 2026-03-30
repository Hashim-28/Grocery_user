import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const DesilApp());
}

class DesilApp extends StatelessWidget {
  const DesilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desil Cash & Carry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryGreen,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
