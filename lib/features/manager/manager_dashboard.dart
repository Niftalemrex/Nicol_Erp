import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'manager_order.dart';
import 'manager_overall_analysis.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading orders: $e")),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  void goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  String statusIcon(String status) {
    switch (status) {
      case 'pending': return "🟡";
      case 'approved': return "🔵";
      case 'designing': return "🎨";
      case 'printing': return "🖨";
      case 'finishing': return "✂️";
      case 'completed': return "🟢";
      case 'rejected': return "🔴";
      default: return "⚪";
    }
  }

  double get totalRevenue {
    return orders.fold(0, (sum, o) {
      final price = o['price'];
      return sum + (price is num ? price : 0);
    });
  }

  int countStatus(String status) {
    return orders.where((o) => o['status'] == status).length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'approved': return const Color(0xFF3B82F6);
      case 'designing': return const Color(0xFF8B5CF6);
      case 'printing': return const Color(0xFF6366F1);
      case 'finishing': return const Color(0xFFEC4899);
      case 'completed': return const Color(0xFF10B981);
      case 'rejected': return const Color(0xFFEF4444);
      default: return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.18).clamp(70.0, 110.0);
    final titleFontSize = (screenWidth * 0.055).clamp(18.0, 26.0);
    final subtitleFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);
    final statValueSize = (screenWidth * 0.05).clamp(16.0, 22.0);
    final statLabelSize = (screenWidth * 0.03).clamp(11.0, 14.0);
    final navTitleSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final navSubtitleSize = (screenWidth * 0.032).clamp(12.0, 14.0);
    final orderTitleSize = (screenWidth * 0.038).clamp(14.0, 17.0);
    final orderSubtitleSize = (screenWidth * 0.03).clamp(11.0, 14.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
          slivers: [
            // Top bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenWidth * 0.04,
                ),
                child: Row(
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
                      onPressed: fetchOrders,
                    ),
                  ],
                ),
              ),
            ),
            // Logo and branding
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
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
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      'Manager Dashboard',
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
            // Stats grid – **childAspectRatio changed to 1.5** to remove overflow
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: 1.5, // ← FIX: was 1.6, now taller cells
                ),
                delegate: SliverChildListDelegate([
                  _statCard("Total Orders", orders.length.toString(),
                      Icons.shopping_cart, const Color(0xFF3B82F6),
                      statValueSize, statLabelSize, screenWidth),
                  _statCard("Revenue", "${totalRevenue.toStringAsFixed(2)} ETB",
                      Icons.attach_money, const Color(0xFF10B981),
                      statValueSize, statLabelSize, screenWidth),
                  _statCard("Pending", countStatus('pending').toString(),
                      Icons.hourglass_empty, const Color(0xFFF59E0B),
                      statValueSize, statLabelSize, screenWidth),
                  _statCard("Printing", countStatus('printing').toString(),
                      Icons.print, const Color(0xFF8B5CF6),
                      statValueSize, statLabelSize, screenWidth),
                  _statCard("Finishing", countStatus('finishing').toString(),
                      Icons.content_cut, const Color(0xFFEC4899),
                      statValueSize, statLabelSize, screenWidth),
                  _statCard("Completed", countStatus('completed').toString(),
                      Icons.check_circle, const Color(0xFF10B981),
                      statValueSize, statLabelSize, screenWidth),
                ]),
              ),
            ),
            // Navigation cards
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenWidth * 0.06),
                    _navCard(
                      icon: Icons.list_alt,
                      title: "Manage Orders",
                      subtitle: "View, create, and update orders",
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerOrderPage(),
                          ),
                        );
                      },
                      screenWidth: screenWidth,
                      titleSize: navTitleSize,
                      subtitleSize: navSubtitleSize,
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    _navCard(
                      icon: Icons.analytics,
                      title: "Overall Analysis",
                      subtitle: "Charts, revenue, and status breakdown",
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerOverallAnalysisPage(),
                          ),
                        );
                      },
                      screenWidth: screenWidth,
                      titleSize: navTitleSize,
                      subtitleSize: navSubtitleSize,
                    ),
                    SizedBox(height: screenWidth * 0.06),
                  ],
                ),
              ),
            ),
            // Divider and "Recent Orders"
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      "Recent Orders",
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                  ],
                ),
              ),
            ),
            // Recent orders list
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final order = orders[index];
                    final status = order['status'] ?? '';
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: screenWidth * 0.03),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Row(
                          children: [
                            Text(
                              statusIcon(status),
                              style: TextStyle(
                                  fontSize: screenWidth * 0.06),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order['type'] ?? 'No Type',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: orderTitleSize,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    "👤 ${order['customer'] ?? '-'} · Qty: ${order['qty'] ?? 0}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: orderSubtitleSize,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.005),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "💰 ${order['price'] ?? 0} ETB",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: orderSubtitleSize,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.04),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02,
                                          vertical: screenWidth * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status)
                                              .withOpacity(0.15),
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontSize:
                                            orderSubtitleSize * 0.85,
                                            fontWeight: FontWeight.w600,
                                            color: _statusColor(status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: const Color(0xFF94A3B8),
                              size: screenWidth * 0.05,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: orders.length,
                ),
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

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      Color color,
      double valueFontSize,
      double labelFontSize,
      double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.06),
          SizedBox(height: screenWidth * 0.02),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: labelFontSize,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navCard({
    required IconData icon,
    required String title,
    required String subtitle,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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