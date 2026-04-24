import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'utils/app_state.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize Push Notifications
  await PushNotificationService().initialize();

  await GoogleSignIn.instance.initialize(
    serverClientId: '892085908483-cvea138pr28v81162eorqa7127s6f33c.apps.googleusercontent.com',
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
    return ChangeNotifierProvider.value(
      value: _appState,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Selector<AppState, bool>(
            selector: (context, state) => state.isDarkMode,
            builder: (context, isDarkMode, child) {
              AppTheme.isDarkMode = isDarkMode;
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
        },
      ),
    );
  }
}
