import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/splash/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/admin_login_screen.dart';

import 'features/admin/admin_dashboard.dart';
import 'features/manager/manager_dashboard.dart';

// 👇 ROLE SCREENS (ERP MODULES)
import 'features/designer/designer_screen.dart';
import 'features/printer/printer_screen.dart';
import 'features/cashier/cashier_screen.dart';
import 'features/finishing/finishing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bdnnnhajedxjyriwdxuw.supabase.co',
    anonKey: 'sb_publishable_yPg-TXfdpJk8hTZoioi0fw_gc1oHABZ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        // 🔥 CORE AUTH FLOW
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),

        // 🔥 ADMIN
        '/admin': (context) => const AdminDashboard(),
        '/manager': (context) => const ManagerDashboard(),

        // 🔥 ERP ROLE MODULES

        '/designer': (context) => const DesignerScreen(),
        '/printer': (context) => const PrinterScreen(),
        '/cashier': (context) => const CashierScreen(),
        '/finishing': (context) => const FinishingScreen(),


        // fallback home
        '/home': (context) => const Scaffold(
          body: Center(child: Text("HOME")),
        ),
      },
    );
  }
}