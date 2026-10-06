import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'create_design.dart';

class DesignerOrderPage extends StatefulWidget {
  const DesignerOrderPage({super.key});

  @override
  State<DesignerOrderPage> createState() => _DesignerOrderPageState();
}

class _DesignerOrderPageState extends State<DesignerOrderPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> orders = [];
  bool loading = true;

  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // 📦 FETCH DESIGNING ORDERS
  Future<void> fetchOrders() async {
    try {
      setState(() => loading = true);

      final data = await supabase
          .from('orders')
          .select()
          .eq('status', 'designing')
          .order('created_at', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // 🔍 SEARCH FILTER
  List<Map<String, dynamic>> get filteredOrders {
    final search = searchCtrl.text.toLowerCase();
    return orders.where((o) {
      final customer = (o['customer'] ?? '').toString().toLowerCase();
      final type = (o['type'] ?? '').toString().toLowerCase();
      return customer.contains(search) || type.contains(search);
    }).toList();
  }

  // 🎨 OPEN DESIGN PAGE
  Future<void> openCreateDesign(Map<String, dynamic> order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDesignPage(order: order),
      ),
    );
    if (result == true) {
      fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 30.0);
    final subtitleFontSize = (screenWidth * 0.032).clamp(12.0, 15.0);
    final searchFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final cardTitleSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final cardSubtitleSize = (screenWidth * 0.032).clamp(12.0, 14.0);
    final buttonFontSize = (screenWidth * 0.034).clamp(13.0, 15.0);

    final list = filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
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
                    onPressed: fetchOrders,
                  ),
                ],
              ),
            ),

            // Title (no logo)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Designer Orders',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Design tasks waiting for you',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(fontSize: searchFontSize),
                  decoration: InputDecoration(
                    hintText: 'Search customer or type',
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF94A3B8), size: 22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.04,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // Loading or list
            loading
                ? const Expanded(
                child: Center(child: CircularProgressIndicator()))
                : Expanded(
              child: list.isEmpty
                  ? Center(
                child: Text(
                  "No design tasks available 🎨",
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: const Color(0xFF64748B),
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final o = list[i];
                  final customer = o['customer'] ?? 'Unknown';
                  final type = o['type'] ?? '-';
                  final qty = o['qty'] ?? '-';
                  final deadline = o['deadline'] ?? '-';
                  final notes = o['notes'] ?? '-';

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: screenWidth * 0.03),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(
                          screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Customer header
                          Row(
                            children: [
                              Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6)
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF8B5CF6),
                                    size: 28),
                              ),
                              SizedBox(
                                  width: screenWidth * 0.04),
                              Expanded(
                                child: Text(
                                  customer,
                                  style: TextStyle(
                                    fontSize: cardTitleSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(
                                        0xFF1E293B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: screenWidth * 0.03),
                          // Details
                          Text(
                            "🧾 Type: $type",
                            style: TextStyle(
                              fontSize: cardSubtitleSize,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(
                              height: screenWidth * 0.01),
                          Text(
                            "📦 Qty: $qty",
                            style: TextStyle(
                              fontSize: cardSubtitleSize,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(
                              height: screenWidth * 0.01),
                          Text(
                            "📅 Deadline: $deadline",
                            style: TextStyle(
                              fontSize: cardSubtitleSize,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          if (notes.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenWidth * 0.01),
                              child: Text(
                                "📝 $notes",
                                maxLines: 2,
                                overflow:
                                TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: cardSubtitleSize,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          SizedBox(
                              height: screenWidth * 0.04),
                          // Create Design button
                          SizedBox(
                            width: double.infinity,
                            height: screenWidth * 0.11,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      10),
                                ),
                              ),
                              icon: Icon(Icons.design_services,
                                  size: buttonFontSize * 1.1),
                              label: Text(
                                'CREATE DESIGN',
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () =>
                                  openCreateDesign(o),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}