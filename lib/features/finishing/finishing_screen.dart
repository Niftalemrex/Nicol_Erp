import 'package:flutter/material.dart';
import 'finisher_order.dart';

class FinishingScreen extends StatelessWidget {
  const FinishingScreen({super.key});

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
      MaterialPageRoute(builder: (_) => const FinisherOrderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.18).clamp(70.0, 110.0);
    final titleFontSize = (screenWidth * 0.055).clamp(18.0, 26.0);
    final subtitleFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);
    final buttonFontSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final statFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with logout
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

            // Logo and title
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
                        'assets/logo.png',
                        width: logoSize,
                        height: logoSize * 0.9,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                    'Finishing Dashboard',
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

            // Quick status cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      emoji: "🟠",
                      label: "Pending",
                      color: const Color(0xFFF59E0B),
                      screenWidth: screenWidth,
                      fontSize: statFontSize,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      emoji: "✂️",
                      label: "Active",
                      color: const Color(0xFFEC4899),
                      screenWidth: screenWidth,
                      fontSize: statFontSize,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      emoji: "🟢",
                      label: "Done",
                      color: const Color(0xFF10B981),
                      screenWidth: screenWidth,
                      fontSize: statFontSize,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.08),

            // Main action button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
              child: SizedBox(
                width: double.infinity,
                height: screenWidth * 0.14,
                child: ElevatedButton.icon(
                  onPressed: () => openOrders(context),
                  icon: const Icon(Icons.content_cut, size: 28),
                  label: Text(
                    'View Finishing Jobs',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
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

  Widget _buildStatCard({
    required String emoji,
    required String label,
    required Color color,
    required double screenWidth,
    required double fontSize,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: screenWidth * 0.08)),
          SizedBox(height: screenWidth * 0.02),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}