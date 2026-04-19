import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'utils/app_state.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

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
  void initState() {
    super.initState();
    _appState.loadCart();
    _appState.fetchDeliveryConfig();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        AppTheme.isDarkMode = _appState.isDarkMode;
        
        return ChangeNotifierProvider(
          create: (_) => DataProvider(),
          child: MaterialApp(
            title: 'Diesel Cash & Carry',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData,
            home: SplashScreen(appState: _appState),
          ),
        );
      },
    );
  }
}
