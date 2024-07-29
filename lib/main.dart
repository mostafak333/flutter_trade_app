import 'package:alfarsha/dailyReport.dart';
import 'package:alfarsha/home.dart';
import 'package:alfarsha/inventory.dart';
import 'package:alfarsha/listedDailyReport.dart';
import 'package:alfarsha/login.dart';
import 'package:alfarsha/monthlyReport.dart';
import 'package:alfarsha/products.dart';
import 'package:alfarsha/register.dart';
import 'package:alfarsha/security.dart';
import 'package:alfarsha/settings.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Determine the initial route based on the login status
  final String initialRoute = await _getInitialRoute();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
      path: 'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: true,
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

Future<String> _getInitialRoute() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Optionally check if credentials are still valid
  if (isLoggedIn) {
    String? savedPassword = prefs.getString('password');
    if (savedPassword != null) {
      // Validate the saved password or token here if needed
      return '/';
    }
  }

  return '/login';
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'My App',
      initialRoute: initialRoute, // Set the initial route based on login status
      routes: {
        '/login': (context) => const LoginPage(), // Set LoginPage as the initial route
        '/': (context) => const Home(),
        '/products': (context) => Products(),
        '/report': (context) => const ListedDailyReport(),
        '/daily-report': (context) => const DailyReport(),
        '/monthly-report': (context) => const MonthlyReport(),
        '/inventory': (context) => const Inventory(),
        '/create-project': (context) => const RegisterPage(), // Add the register route
        '/settings': (context) => const SettingsPage(), // Add the settings route
        '/security': (context) => const SecuritySettingsPage(), // Add the register route
      },
    );
  }
}
