import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApproveUsersPage extends StatefulWidget {
  const ApproveUsersPage({super.key});

  @override
  State<ApproveUsersPage> createState() => _ApproveUsersPageState();
}

class _ApproveUsersPageState extends State<ApproveUsersPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // 📦 FETCH PENDING USERS
  Future<void> fetchUsers() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        users = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // ✅ APPROVE USER
  Future<void> approveUser(String id) async {
    try {
      await supabase.from('profiles').update({
        'status': 'approved',
      }).eq('id', id);

      fetchUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User approved ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ❌ REJECT USER
  Future<void> rejectUser(String id) async {
    try {
      await supabase.from('profiles').update({
        'status': 'rejected',
      }).eq('id', id);

      fetchUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User rejected ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 30.0);
    final subtitleFontSize = (screenWidth * 0.032).clamp(12.0, 15.0);
    final cardTitleSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final cardSubtitleSize = (screenWidth * 0.032).clamp(12.0, 14.0);
    final buttonFontSize = (screenWidth * 0.032).clamp(12.0, 14.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Top action bar
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
                    onPressed: fetchUsers,
                  ),
                ],
              ),
            ),
            // Title (without logo)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Approve Users',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Review and manage pending accounts',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.06),
            // User list
            Expanded(
              child: users.isEmpty
                  ? Center(
                child: Text(
                  "No pending users",
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: const Color(0xFF64748B),
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final name = user['name'] ?? 'No Name';
                  final role = user['role'] ?? '-';
                  final status = user['status'] ?? '-';
                  final initials = name
                      .toString()
                      .substring(0, 1)
                      .toUpperCase();

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: screenWidth * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(
                          screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Name and avatar
                          Row(
                            children: [
                              Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6)
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: cardTitleSize,
                                      fontWeight: FontWeight.w700,
                                      color:
                                      const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: screenWidth * 0.04),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: cardTitleSize,
                                    fontWeight: FontWeight.w600,
                                    color:
                                    const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: screenWidth * 0.03),
                          // Role and status
                          Text(
                            "Role: $role",
                            style: TextStyle(
                              fontSize: cardSubtitleSize,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(
                              height: screenWidth * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              screenWidth * 0.025,
                              vertical:
                              screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withOpacity(0.15),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Status: $status",
                              style: TextStyle(
                                fontSize: cardSubtitleSize * 0.9,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: screenWidth * 0.04),
                          // Action buttons
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            children: [
                              _buildActionButton(
                                label: "Approve",
                                icon: Icons.check,
                                backgroundColor:
                                const Color(0xFF10B981),
                                onTap: () =>
                                    approveUser(user['id']),
                                screenWidth: screenWidth,
                                fontSize: buttonFontSize,
                              ),
                              SizedBox(
                                  width: screenWidth * 0.03),
                              _buildActionButton(
                                label: "Reject",
                                icon: Icons.close,
                                backgroundColor:
                                const Color(0xFFEF4444),
                                onTap: () =>
                                    rejectUser(user['id']),
                                screenWidth: screenWidth,
                                fontSize: buttonFontSize,
                              ),
                            ],
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
    required double screenWidth,
    required double fontSize,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.03,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, size: fontSize * 1.2),
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onTap,
    );
  }
}