import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'approve_users_page.dart';
import 'admin_user_management.dart';
import 'admin_overall_analysis.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final supabase = Supabase.instance.client;

  // User stats
  int pendingUsers = 0;
  int totalUsers = 0;

  // Order stats
  int totalOrders = 0;
  double totalRevenue = 0;
  int pendingOrders = 0;
  int completedOrders = 0;
  int totalCustomers = 0;
  int totalDesigns = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() => loading = true);

    try {
      // Fetch users
      final allUsers = await supabase.from('profiles').select();
      final pending = await supabase
          .from('profiles')
          .select()
          .eq('status', 'pending');

      // Fetch orders and designs for stats
      final ordersData = await supabase.from('orders').select();
      final designsData = await supabase.from('designs').select();

      final orders = List<Map<String, dynamic>>.from(ordersData);
      final designs = List<Map<String, dynamic>>.from(designsData);

      // Calculate stats
      double revenue = 0;
      int pendingCount = 0;
      int completedCount = 0;
      final customerSet = <String>{};

      for (final order in orders) {
        revenue += double.tryParse(order['price']?.toString() ?? '0') ?? 0;
        final status = order['status']?.toString() ?? '';
        if (status == 'pending') pendingCount++;
        if (status == 'completed') completedCount++;
        final customer = order['customer']?.toString() ?? '';
        if (customer.isNotEmpty) customerSet.add(customer);
      }

      setState(() {
        totalUsers = allUsers.length;
        pendingUsers = pending.length;

        totalOrders = orders.length;
        totalRevenue = revenue;
        pendingOrders = pendingCount;
        completedOrders = completedCount;
        totalCustomers = customerSet.length;
        totalDesigns = designs.length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  void openUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminUserManagement()),
    ).then((_) => loadDashboard());
  }

  void openApprovalPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ApproveUsersPage()),
    ).then((_) => loadDashboard());
  }

  void openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminOverallAnalysisPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.22).clamp(80.0, 140.0);
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 30.0);
    final subtitleFontSize = (screenWidth * 0.032).clamp(12.0, 15.0);
    final statNumberSize = (screenWidth * 0.07).clamp(26.0, 36.0);
    final statLabelSize = (screenWidth * 0.035).clamp(12.0, 16.0);
    final sectionTitleSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final cardTitleSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final cardSubtitleSize = (screenWidth * 0.032).clamp(12.0, 14.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenWidth * 0.06,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top action bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF1E293B)),
                    onPressed: goToLogin,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF1E293B)),
                    onPressed: loadDashboard,
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.02),

              // Logo and title
              Center(
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
                          'assets/logoo.jpg', // your logo file
                          width: logoSize,
                          height: logoSize * 0.9,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      'NiCol ERP Management',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenWidth * 0.08),

              // 👤 USER STATS (existing)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Total Users",
                      value: totalUsers.toString(),
                      icon: Icons.people,
                      color: const Color(0xFF3B82F6),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      title: "Pending",
                      value: pendingUsers.toString(),
                      icon: Icons.pending_actions,
                      color: const Color(0xFFF59E0B),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.06),

              // 📊 BUSINESS OVERVIEW
              Text(
                "Business Overview",
                style: TextStyle(
                  fontSize: sectionTitleSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: screenWidth * 0.04),

              // First row of business stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Total Orders",
                      value: totalOrders.toString(),
                      icon: Icons.shopping_cart,
                      color: const Color(0xFF3B82F6),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      title: "Revenue",
                      value: "${totalRevenue.toStringAsFixed(0)} ETB",
                      icon: Icons.attach_money,
                      color: const Color(0xFF10B981),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              // Second row of business stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Pending Orders",
                      value: pendingOrders.toString(),
                      icon: Icons.hourglass_empty,
                      color: const Color(0xFFF59E0B),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      title: "Completed",
                      value: completedOrders.toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF10B981),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              // Third row (customers & designs)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Customers",
                      value: totalCustomers.toString(),
                      icon: Icons.people_outline,
                      color: const Color(0xFF6366F1),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: _buildStatCard(
                      title: "Designs",
                      value: totalDesigns.toString(),
                      icon: Icons.design_services,
                      color: const Color(0xFFEC4899),
                      numberSize: statNumberSize,
                      labelSize: statLabelSize,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.08),

              // ⚙️ ADMINISTRATION
              Text(
                "Administration",
                style: TextStyle(
                  fontSize: sectionTitleSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: screenWidth * 0.04),

              _buildMenuCard(
                title: "User Management",
                subtitle: "Manage all ERP users and roles",
                icon: Icons.admin_panel_settings,
                color: const Color(0xFF3B82F6),
                onTap: openUserManagement,
                screenWidth: screenWidth,
                titleSize: cardTitleSize,
                subtitleSize: cardSubtitleSize,
              ),
              SizedBox(height: screenWidth * 0.04),

              _buildMenuCard(
                title: "Approve Users",
                subtitle: "Approve or reject new accounts",
                icon: Icons.verified_user,
                color: const Color(0xFF10B981),
                onTap: openApprovalPage,
                screenWidth: screenWidth,
                titleSize: cardTitleSize,
                subtitleSize: cardSubtitleSize,
              ),
              SizedBox(height: screenWidth * 0.04),

              _buildMenuCard(
                title: "Overall Analysis",
                subtitle: "Revenue, orders, and performance",
                icon: Icons.analytics,
                color: const Color(0xFF6366F1),
                onTap: openAnalytics,
                screenWidth: screenWidth,
                titleSize: cardTitleSize,
                subtitleSize: cardSubtitleSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double numberSize,
    required double labelSize,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth() * 0.05),
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
      child: Column(
        children: [
          Icon(icon, size: screenWidth() * 0.1, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: numberSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: labelSize,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
              child: Icon(icon, color: color, size: screenWidth * 0.07),
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

  double screenWidth() => MediaQuery.of(context).size.width;
}