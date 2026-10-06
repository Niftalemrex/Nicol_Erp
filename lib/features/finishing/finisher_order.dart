import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinisherOrderPage extends StatefulWidget {
  const FinisherOrderPage({super.key});

  @override
  State<FinisherOrderPage> createState() => _FinisherOrderPageState();
}

class _FinisherOrderPageState extends State<FinisherOrderPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> orders = [];
  bool loading = true;
  bool showCompleted = false;

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

  Future<void> fetchOrders() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('orders')
          .select('''
            id,
            customer,
            qty,
            status,
            created_at,
            designs (
              design_type,
              width,
              height,
              material,
              finishing,
              design_note
            )
          ''')
          .inFilter(
        'status',
        showCompleted ? ['completed'] : ['finishing'],
      )
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
      if (mounted) setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    final search = searchCtrl.text.toLowerCase();
    return orders.where((o) {
      final customer = (o['customer'] ?? '').toString().toLowerCase();
      return customer.contains(search);
    }).toList();
  }

  Map<String, dynamic>? getDesign(Map<String, dynamic> o) {
    final d = o['designs'];
    if (d is List && d.isNotEmpty) return d.first;
    if (d is Map<String, dynamic>) return d;
    return null;
  }

  Future<void> markDone(String id) async {
    await supabase.from('orders').update({
      'status': 'completed',
      'finished_at': DateTime.now().toIso8601String(),
    }).eq('id', id);

    fetchOrders();
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
    final toggleFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);

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
                    'Finisher Orders',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Complete finishing jobs',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // Toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(12)),
                        onTap: () {
                          setState(() => showCompleted = false);
                          fetchOrders();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !showCompleted
                                ? const Color(0xFFEC4899)
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(12)),
                          ),
                          child: Center(
                            child: Text(
                              'Active ✂️',
                              style: TextStyle(
                                fontSize: toggleFontSize,
                                fontWeight: FontWeight.w600,
                                color: !showCompleted
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(12)),
                        onTap: () {
                          setState(() => showCompleted = true);
                          fetchOrders();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: showCompleted
                                ? const Color(0xFF10B981)
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(12)),
                          ),
                          child: Center(
                            child: Text(
                              'Finished 🟢',
                              style: TextStyle(
                                fontSize: toggleFontSize,
                                fontWeight: FontWeight.w600,
                                color: showCompleted
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // Search
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
                    hintText: 'Search customer',
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
                  showCompleted
                      ? "No finished jobs 🟢"
                      : "No active finishing jobs ✂️",
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
                  final d = getDesign(o);
                  final customer = o['customer'] ?? '-';

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
                                  color: const Color(0xFFEC4899)
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.content_cut,
                                    color: Color(0xFFEC4899),
                                    size: 28),
                              ),
                              SizedBox(
                                  width: screenWidth * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer,
                                      style: TextStyle(
                                        fontSize: cardTitleSize,
                                        fontWeight:
                                        FontWeight.w600,
                                        color: const Color(
                                            0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                        screenWidth * 0.005),
                                    Text(
                                      "Qty: ${o['qty'] ?? 0}  ·  ${o['status'] ?? '-'}",
                                      style: TextStyle(
                                        fontSize:
                                        cardSubtitleSize *
                                            0.9,
                                        color: const Color(
                                            0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: screenWidth * 0.03),
                          // Design details
                          if (d != null) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(
                                  screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  if (d['design_type'] != null)
                                    Text(
                                      "🎨 ${d['design_type']}",
                                      style: TextStyle(
                                        fontSize:
                                        cardSubtitleSize,
                                        fontWeight:
                                        FontWeight.w500,
                                        color: const Color(
                                            0xFF1E293B),
                                      ),
                                    ),
                                  SizedBox(height: 4),
                                  if (d['width'] != null &&
                                      d['height'] != null)
                                    Text(
                                      "📏 ${d['width']} x ${d['height']}",
                                      style: TextStyle(
                                        fontSize:
                                        cardSubtitleSize,
                                        color: const Color(
                                            0xFF64748B),
                                      ),
                                    ),
                                  SizedBox(height: 2),
                                  if (d['material'] != null)
                                    Text(
                                      "🧵 ${d['material']}",
                                      style: TextStyle(
                                        fontSize:
                                        cardSubtitleSize,
                                        color: const Color(
                                            0xFF64748B),
                                      ),
                                    ),
                                  SizedBox(height: 2),
                                  if (d['finishing'] != null)
                                    Text(
                                      "✂️ ${d['finishing']}",
                                      style: TextStyle(
                                        fontSize:
                                        cardSubtitleSize,
                                        color: const Color(
                                            0xFF64748B),
                                      ),
                                    ),
                                  if (d['design_note'] != null &&
                                      d['design_note']
                                          .toString()
                                          .isNotEmpty)
                                    Padding(
                                      padding:
                                      EdgeInsets.only(top: 4),
                                      child: Text(
                                        "📝 ${d['design_note']}",
                                        style: TextStyle(
                                          fontSize:
                                          cardSubtitleSize *
                                              0.95,
                                          color: const Color(
                                              0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: screenWidth * 0.03),
                          ],
                          // Mark done button (only for active)
                          if (!showCompleted)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () =>
                                    markDone(o['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                    screenWidth * 0.05,
                                    vertical:
                                    screenWidth * 0.03,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'MARK DONE',
                                  style: TextStyle(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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