import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gme/core/theme/app_theme.dart';
import 'package:gme/features/auth/presentation/screens/login_screen.dart';
import 'package:gme/features/home/home_screen.dart';
import 'package:gme/core/services/storage_service.dart';
import 'package:gme/core/services/injection_container.dart' as di;

import 'package:gme/core/widgets/responsive_wrapper.dart';

import 'package:gme/core/utils/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final token = await di.sl<StorageService>().getToken();
  final initialScreen = (token != null && token.isNotEmpty)
      ? const HomeScreen()
      : const LoginScreen();

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'GME Interchange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.bgColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.btnColor),
        textTheme: GoogleFonts.ralewayTextTheme(),
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      builder: (context, child) {
        return ResponsiveWrapper(child: child!);
      },
      home: initialScreen,
    );
  }
}
