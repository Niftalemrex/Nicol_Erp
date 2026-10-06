import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerOrderPage extends StatefulWidget {
  const ManagerOrderPage({super.key});

  @override
  State<ManagerOrderPage> createState() => _ManagerOrderPageState();
}

class _ManagerOrderPageState extends State<ManagerOrderPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> orders = [];
  bool loading = true;

  final searchCtrl = TextEditingController();

  // 🧾 FORM CONTROLLERS
  final customerCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final deadlineCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    customerCtrl.dispose();
    phoneCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
    typeCtrl.dispose();
    deadlineCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  // 📦 FETCH ORDERS
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

  // 🔍 SEARCH
  List<Map<String, dynamic>> get filteredOrders {
    final search = searchCtrl.text.toLowerCase();
    return orders.where((o) {
      final customer = (o['customer'] ?? '').toString().toLowerCase();
      final phone = (o['phone'] ?? '').toString().toLowerCase();
      final status = (o['status'] ?? '').toString().toLowerCase();
      return customer.contains(search) ||
          phone.contains(search) ||
          status.contains(search);
    }).toList();
  }

  // 🔒 SAFE APPROVE
  Future<void> approveOrder(String id, String status) async {
    if (status != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Only pending orders can be approved")),
      );
      return;
    }
    await supabase.from('orders').update({'status': 'approved'}).eq('id', id);
    fetchOrders();
  }

  Future<void> rejectOrder(String id, String status) async {
    if (status != 'pending') return;
    await supabase.from('orders').update({'status': 'rejected'}).eq('id', id);
    fetchOrders();
  }

  Future<void> deleteOrder(String id) async {
    await supabase.from('orders').delete().eq('id', id);
    fetchOrders();
  }

  // 📅 DATE PICKER
  Future<void> pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      deadlineCtrl.text = picked.toIso8601String().split('T')[0];
    }
  }

  // ➕ ADD ORDER
  Future<void> addOrder() async {
    if (customerCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;

    await supabase.from('orders').insert({
      'customer': customerCtrl.text,
      'phone': phoneCtrl.text,
      'qty': int.tryParse(qtyCtrl.text) ?? 0,
      'price': double.tryParse(priceCtrl.text) ?? 0,
      'type': typeCtrl.text,
      'deadline': deadlineCtrl.text,
      'notes': notesCtrl.text,
      'status': 'pending',
    });

    Navigator.pop(context);
    fetchOrders();
  }

  void showAddDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("➕ Add Order"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: customerCtrl, decoration: const InputDecoration(labelText: "Customer")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
              TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Qty")),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: "Type")),
              TextField(
                controller: deadlineCtrl,
                readOnly: true,
                onTap: pickDeadline,
                decoration: const InputDecoration(labelText: "Deadline"),
              ),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: "Notes")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: addOrder, child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 30.0);
    final subtitleFontSize = (screenWidth * 0.032).clamp(12.0, 15.0);
    final searchFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final cardTitleSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final cardSubtitleSize = (screenWidth * 0.032).clamp(12.0, 14.0);
    final badgeFontSize = (screenWidth * 0.028).clamp(10.0, 12.0);

    final list = filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and actions
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenWidth * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF1E293B)),
                        onPressed: showAddDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
                        onPressed: fetchOrders,
                      ),
                    ],
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
                    'Order Management',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'View, approve and manage all orders',
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
                    hintText: 'Search by customer, phone or status',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
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
                ? const Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
              child: list.isEmpty
                  ? Center(
                child: Text(
                  "No orders found",
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: const Color(0xFF64748B),
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final o = list[i];
                  final status = o['status'] ?? 'pending';
                  final customer = o['customer'] ?? 'No Customer';
                  final phone = o['phone'] ?? '-';
                  final qty = o['qty'] ?? 0;
                  final type = o['type'] ?? '-';
                  final price = o['price'] ?? 0;

                  Color statusColor;
                  switch (status) {
                    case 'pending': statusColor = const Color(0xFFF59E0B); break;
                    case 'approved': statusColor = const Color(0xFF3B82F6); break;
                    case 'designing': statusColor = const Color(0xFF8B5CF6); break;
                    case 'printing': statusColor = const Color(0xFF6366F1); break;
                    case 'finishing': statusColor = const Color(0xFFEC4899); break;
                    case 'completed': statusColor = const Color(0xFF10B981); break;
                    case 'rejected': statusColor = const Color(0xFFEF4444); break;
                    default: statusColor = const Color(0xFF94A3B8);
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: screenWidth * 0.03),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {}, // can be used for details later
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status badge circle
                              Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    status.substring(0, 2).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: badgeFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              // Main info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer,
                                      style: TextStyle(
                                        fontSize: cardTitleSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: screenWidth * 0.01),
                                    Text(
                                      "📞 $phone  |  Qty: $qty  |  $type",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: cardSubtitleSize,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: screenWidth * 0.01),
                                    Text(
                                      "💰 $price ETB",
                                      style: TextStyle(
                                        fontSize: cardSubtitleSize,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Popup menu
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'approve') approveOrder(o['id'], status);
                                  if (value == 'reject') rejectOrder(o['id'], status);
                                  if (value == 'delete') deleteOrder(o['id']);
                                },
                                itemBuilder: (_) => [
                                  if (status == 'pending')
                                    const PopupMenuItem(
                                      value: 'approve',
                                      child: Text('Approve', style: TextStyle(color: Color(0xFF10B981))),
                                    ),
                                  if (status == 'pending')
                                    const PopupMenuItem(
                                      value: 'reject',
                                      child: Text('Reject', style: TextStyle(color: Color(0xFFF59E0B))),
                                    ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                                  ),
                                ],
                                icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
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