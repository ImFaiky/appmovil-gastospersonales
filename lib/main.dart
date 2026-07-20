import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const GastoSmartApp());
}

class GastoSmartApp extends StatelessWidget {
  const GastoSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GastoSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
