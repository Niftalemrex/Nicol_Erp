import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CashierOrderPage extends StatefulWidget {
  const CashierOrderPage({super.key});

  @override
  State<CashierOrderPage> createState() => _CashierOrderPageState();
}

class _CashierOrderPageState extends State<CashierOrderPage> {
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

  // 📦 FETCH ONLY APPROVED ORDERS
  Future<void> fetchOrders() async {
    setState(() => loading = true);

    final data = await supabase
        .from('orders')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    setState(() {
      orders = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  // 🔍 FILTER
  List<Map<String, dynamic>> get filteredOrders {
    final search = searchCtrl.text.toLowerCase();
    return orders.where((o) {
      final customer = (o['customer'] ?? '').toString().toLowerCase();
      return customer.contains(search);
    }).toList();
  }

  // 💰 MARK AS PAID → SEND TO DESIGNER
  Future<void> markAsPaid(String id) async {
    try {
      await supabase.from('orders').update({
        'status': 'designing',
        'paid_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      fetchOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order sent to Designer 🎨"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
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
    final buttonFontSize = (screenWidth * 0.032).clamp(12.0, 14.0);

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
              padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cashier Orders',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Approve approved orders and send to designer',
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
              padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
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
                    hintText: 'Search by customer name',
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
                  "No approved orders",
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
                  final qty = o['qty'] ?? 0;
                  final price = o['price'] ?? 0;
                  final status = o['status'] ?? 'approved';

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
                      child: Row(
                        children: [
                          // Receipt icon
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6)
                                  .withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF3B82F6),
                              size: 28,
                            ),
                          ),
                          SizedBox(
                              width: screenWidth * 0.04),
                          // Order info
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer,
                                  style: TextStyle(
                                    fontSize: cardTitleSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(
                                        0xFF1E293B),
                                  ),
                                ),
                                SizedBox(
                                    height:
                                    screenWidth * 0.01),
                                Text(
                                  "Qty: $qty  |  Price: $price ETB",
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize:
                                    cardSubtitleSize,
                                    color: const Color(
                                        0xFF64748B),
                                  ),
                                ),
                                SizedBox(
                                    height:
                                    screenWidth * 0.005),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                    screenWidth * 0.02,
                                    vertical:
                                    screenWidth * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFF10B981)
                                        .withOpacity(0.15),
                                    borderRadius:
                                    BorderRadius.circular(
                                        6),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize:
                                      cardSubtitleSize *
                                          0.85,
                                      fontWeight:
                                      FontWeight.w600,
                                      color: const Color(
                                          0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Paid button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                screenWidth * 0.04,
                                vertical:
                                screenWidth * 0.03,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.payment,
                                size: buttonFontSize * 1.1),
                            label: Text(
                              'PAID',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () =>
                                markAsPaid(o['id']),
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