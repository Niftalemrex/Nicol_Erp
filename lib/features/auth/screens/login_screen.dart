import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unused_import
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final supabase = Supabase.instance.client;

  bool loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;

    final emailText = email.text.trim();
    final passText = password.text.trim();

    // ✅ validation
    if (emailText.isEmpty || passText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 🔐 LOGIN
      final res = await supabase.auth.signInWithPassword(
        email: emailText,
        password: passText,
      );

      final user = res.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // 🧠 FETCH PROFILE
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        throw Exception("Profile not found");
      }

      // 🚫 CHECK APPROVAL
      if (profile['status'] != 'approved') {
        await supabase.auth.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account not approved yet")),
        );
        return;
      }

      final role = profile['role'] ?? '';

      if (!mounted) return;

      // 🎯 ROLE ROUTING (FIXED + COMPLETE)
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
          Navigator.pushReplacementNamed(context, '/manager');
          break;

        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin');
          break;

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown role")),
          );
          Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive logo size: scales with screen width, min 80, max 140
    final logoSize = (screenWidth * 0.22).clamp(80.0, 140.0);
    // Responsive spacing and font sizes
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 30.0);
    final subtitleFontSize = (screenWidth * 0.032).clamp(12.0, 15.0);
    final welcomeFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final signInFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final buttonFontSize = (screenWidth * 0.038).clamp(15.0, 18.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenWidth * 0.08,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo – rectangular shape with rounded corners and shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/logoo.jpg',
                      width: logoSize,
                      height: logoSize * 0.9, // rectangular aspect ratio
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Text(
                  'NiCol ERP',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  'Enterprise Resource Planning',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: screenWidth * 0.08),

                // Login Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: welcomeFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: signInFontSize,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.05),

                      // Email field
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: signInFontSize),
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.04,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Password field
                      TextField(
                        controller: password,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: signInFontSize),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: const Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.04,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.06),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF93C5FD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: loading
                              ? SizedBox(
                            height: screenWidth * 0.06,
                            width: screenWidth * 0.06,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenWidth * 0.05),

                // Additional links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                      ),
                      child: Text(
                        'Create account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: signInFontSize,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: Text(
                        'Admin login',
                        style: TextStyle(fontSize: signInFontSize),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}