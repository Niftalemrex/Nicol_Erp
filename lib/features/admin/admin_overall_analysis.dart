import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOverallAnalysisPage extends StatefulWidget {
  const AdminOverallAnalysisPage({super.key});

  @override
  State<AdminOverallAnalysisPage> createState() =>
      _AdminOverallAnalysisPageState();
}

class _AdminOverallAnalysisPageState
    extends State<AdminOverallAnalysisPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> designs = [];

  // 📊 STATS
  int totalOrders = 0;
  int completedOrders = 0;
  int pendingOrders = 0;
  int designingOrders = 0;
  int printingOrders = 0;
  int finishingOrders = 0;
  int rejectedOrders = 0;

  int totalCustomers = 0;

  double totalRevenue = 0;
  double completedRevenue = 0;

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  // 🚀 LOAD EVERYTHING
  Future<void> loadAnalytics() async {
    setState(() => loading = true);

    try {
      final ordersData = await supabase.from('orders').select();
      final designsData = await supabase.from('designs').select();

      orders = List<Map<String, dynamic>>.from(ordersData);
      designs = List<Map<String, dynamic>>.from(designsData);

      calculateStats();
      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // 📊 CALCULATE STATS
  void calculateStats() {
    totalOrders = orders.length;
    completedOrders = orders.where((o) => o['status'] == 'completed').length;
    pendingOrders = orders.where((o) => o['status'] == 'pending').length;
    designingOrders = orders.where((o) => o['status'] == 'designing').length;
    printingOrders = orders.where((o) => o['status'] == 'printing').length;
    finishingOrders = orders.where((o) => o['status'] == 'finishing').length;
    rejectedOrders = orders.where((o) => o['status'] == 'rejected').length;

    totalRevenue = 0;
    for (final order in orders) {
      totalRevenue += double.tryParse(order['price'].toString()) ?? 0;
    }

    completedRevenue = 0;
    for (final order in orders.where((o) => o['status'] == 'completed')) {
      completedRevenue += double.tryParse(order['price'].toString()) ?? 0;
    }

    final customerSet = <String>{};
    for (final order in orders) {
      customerSet.add((order['customer'] ?? '').toString());
    }
    totalCustomers = customerSet.length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 30.0);
    final subtitleFontSize = (screenWidth * 0.032).clamp(12.0, 15.0);
    final cardTitleSize = (screenWidth * 0.035).clamp(13.0, 15.0);
    final cardValueSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final cardIconSize = (screenWidth * 0.06).clamp(24.0, 30.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Top bar – back + refresh
            Padding(
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF1E293B)),
                    onPressed: loadAnalytics,
                  ),
                ],
              ),
            ),

            // Title (no logo)
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Analysis',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Revenue, orders, and performance overview',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.06),

            // Scrollable list of analytics cards
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06),
                children: [
                  _buildCard(
                    title: "Total Revenue",
                    value: "${totalRevenue.toStringAsFixed(2)} ETB",
                    icon: Icons.payments,
                    color: const Color(0xFF10B981),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Completed Revenue",
                    value: "${completedRevenue.toStringAsFixed(2)} ETB",
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF0D9488),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Total Orders",
                    value: "$totalOrders",
                    icon: Icons.shopping_cart,
                    color: const Color(0xFF3B82F6),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Completed Orders",
                    value: "$completedOrders",
                    icon: Icons.check_circle,
                    color: const Color(0xFF10B981),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Pending Orders",
                    value: "$pendingOrders",
                    icon: Icons.pending_actions,
                    color: const Color(0xFFF59E0B),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Designing Orders",
                    value: "$designingOrders",
                    icon: Icons.brush,
                    color: const Color(0xFF8B5CF6),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Printing Orders",
                    value: "$printingOrders",
                    icon: Icons.print,
                    color: const Color(0xFF6366F1),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Finishing Orders",
                    value: "$finishingOrders",
                    icon: Icons.content_cut,
                    color: const Color(0xFFEC4899),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Rejected Orders",
                    value: "$rejectedOrders",
                    icon: Icons.cancel,
                    color: const Color(0xFFEF4444),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Total Customers",
                    value: "$totalCustomers",
                    icon: Icons.people,
                    color: const Color(0xFF6366F1),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  _buildCard(
                    title: "Total Designs",
                    value: "${designs.length}",
                    icon: Icons.design_services,
                    color: const Color(0xFFEC4899),
                    cardTitleSize: cardTitleSize,
                    cardValueSize: cardValueSize,
                    cardIconSize: cardIconSize,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.08),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double cardTitleSize,
    required double cardValueSize,
    required double cardIconSize,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
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
            child: Icon(icon, color: color, size: cardIconSize),
          ),
          SizedBox(width: screenWidth * 0.05),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: cardTitleSize,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: cardValueSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}