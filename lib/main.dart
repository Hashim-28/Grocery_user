import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'utils/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const DieselApp());
}

class DieselApp extends StatefulWidget {
  const DieselApp({super.key});

  @override
  State<DieselApp> createState() => _DieselAppState();
}

class _DieselAppState extends State<DieselApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        AppTheme.isDarkMode = _appState.isDarkMode;
        
        return MaterialApp(
          title: 'Diesel Cash & Carry',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: SplashScreen(appState: _appState),
        );
      },
    );
  }
}
