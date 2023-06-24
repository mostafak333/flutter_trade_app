import 'package:alfarsha/dailyReport.dart';
import 'package:alfarsha/home.dart';
import 'package:alfarsha/listedDailyReport.dart';
import 'package:alfarsha/monthlyReport.dart';
import 'package:alfarsha/products.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        saveLocale: true,
        child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'My App',
      routes: {
        '/': (context) => const Home(),
        '/products': (context) => Products(),
        '/report': (context) => const ListedDailyReport(),
        '/daily-report': (context) => const DailyReport(),
        '/monthly-report': (context) => const MonthlyReport(),
      },
    );
  }
}
