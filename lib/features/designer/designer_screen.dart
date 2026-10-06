import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'designer_order_page.dart';

class DesignerScreen extends StatefulWidget {
  const DesignerScreen({super.key});

  @override
  State<DesignerScreen> createState() => _DesignerScreenState();
}

class _DesignerScreenState extends State<DesignerScreen> {
  final supabase = Supabase.instance.client;

  String? userName;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        userName = profile['name'];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void createDesign(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DesignerOrderPage()),
    );
  }

  void myTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DesignerOrderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.18).clamp(70.0, 110.0);
    final titleFontSize = (screenWidth * 0.055).clamp(18.0, 26.0);
    final subtitleFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);
    final cardTitleSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final cardSubtitleSize = (screenWidth * 0.035).clamp(13.0, 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
          slivers: [
            // Top bar with logout
            SliverToBoxAdapter(
              child: Padding(
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
                      onPressed: () async {
                        await supabase.auth.signOut();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                            context, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Logo and branding
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/logoo.jpg',
                            width: logoSize,
                            height: logoSize * 0.9,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      'Designer Dashboard',
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
            ),

            // Welcome message
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06),
                child: Text(
                  "Welcome 👋 ${userName ?? 'Designer'}",
                  style: TextStyle(
                    fontSize: titleFontSize * 0.9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            // Spacing – wrapped in SliverToBoxAdapter
            SliverToBoxAdapter(
              child: SizedBox(height: screenWidth * 0.04),
            ),

            // Menu cards
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMenuCard(
                    title: "Create Design",
                    subtitle:
                    "Start a new design for approved orders",
                    icon: Icons.design_services,
                    color: const Color(0xFF3B82F6),
                    onTap: () => createDesign(context),
                    screenWidth: screenWidth,
                    titleSize: cardTitleSize,
                    subtitleSize: cardSubtitleSize,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildMenuCard(
                    title: "My Tasks",
                    subtitle:
                    "View and manage your assigned designs",
                    icon: Icons.task,
                    color: const Color(0xFF10B981),
                    onTap: () => myTasks(context),
                    screenWidth: screenWidth,
                    titleSize: cardTitleSize,
                    subtitleSize: cardSubtitleSize,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildMenuCard(
                    title: "Pending Jobs",
                    subtitle:
                    "Orders waiting to be designed",
                    icon: Icons.pending_actions,
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const DesignerOrderPage()),
                    ),
                    screenWidth: screenWidth,
                    titleSize: cardTitleSize,
                    subtitleSize: cardSubtitleSize,
                  ),
                ]),
              ),
            ),
            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: screenWidth * 0.08),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
    required double titleSize,
    required double subtitleSize,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.05,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
              Icon(icon, color: color, size: screenWidth * 0.07),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}