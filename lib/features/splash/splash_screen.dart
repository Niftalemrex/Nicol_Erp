import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;

  String message = "Loading...";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final session = supabase.auth.currentSession;

      if (!mounted) return;

      if (session == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final user = supabase.auth.currentUser;

      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('id, role, status')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile == null) {
        await supabase.auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final status = profile['status'];
      final role = profile['role'];

      // 🔥 HANDLE STATUS INSIDE SPLASH
      if (status == 'pending') {
        setState(() {
          message = "⏳ Waiting for admin approval...";
        });

        await Future.delayed(const Duration(seconds: 2));

        await supabase.auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (status == 'rejected') {
        setState(() {
          message = "❌ Your account was rejected";
        });

        await Future.delayed(const Duration(seconds: 2));

        await supabase.auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (status != 'approved') {
        await supabase.auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // 🔥 ROLE-BASED ROUTING
      switch (role) {
        case 'designer':
          Navigator.pushReplacementNamed(context, '/designer');
          break;
        case 'printer':
          Navigator.pushReplacementNamed(context, '/printer');
          break;
        case 'cashier':
          Navigator.pushReplacementNamed(context, '/cashier');
          break;
        case 'finishing':
          Navigator.pushReplacementNamed(context, '/finishing');
          break;
        case 'manager':
          Navigator.pushReplacementNamed(context, '/admin'); // ✅ FIX
          break;
        default:
          Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = "Something went wrong...";
      });

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo
              Image.asset(
                'assets/logoo.jpg',
                width: 140,
                height: 140,
              ),
              const SizedBox(height: 32),
              // Status message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  letterSpacing: 0.3,
                ),
              ),
              // Show a loading indicator only while the default message is active
              if (message == "Loading...") ...[
                const SizedBox(height: 24),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF333333)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}