import 'package:flutter/material.dart';
import 'printer_order.dart';

class PrinterScreen extends StatelessWidget {
  const PrinterScreen({super.key});

  void goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  void openOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrinterOrderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.18).clamp(70.0, 110.0);
    final titleFontSize = (screenWidth * 0.055).clamp(18.0, 26.0);
    final subtitleFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);
    final buttonFontSize = (screenWidth * 0.04).clamp(15.0, 18.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with logout button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenWidth * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout,
                        color: Color(0xFF1E293B)),
                    onPressed: () => goToLogin(context),
                  ),
                ],
              ),
            ),

            // Logo and branding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                children: [
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
                        height: logoSize * 0.9,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                    'Printer Dashboard',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'NiCol ERP',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.08),
                ],
              ),
            ),

            // Main action button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
              child: SizedBox(
                width: double.infinity,
                height: screenWidth * 0.14,
                child: ElevatedButton.icon(
                  onPressed: () => openOrders(context),
                  icon: const Icon(Icons.print, size: 28),
                  label: Text(
                    'View Print Jobs',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}