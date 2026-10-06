import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  bool loading = true;

  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // 📦 FETCH USERS
  Future<void> fetchUsers() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      users = List<Map<String, dynamic>>.from(data);

      filteredUsers = users;

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

  // 🔍 SEARCH
  void filterUsers(String value) {
    final search = value.toLowerCase();

    setState(() {
      filteredUsers = users.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final role = (u['role'] ?? '').toString().toLowerCase();
        return name.contains(search) || role.contains(search);
      }).toList();
    });
  }

  // ❌ DELETE USER
  Future<void> deleteUser(String id) async {
    try {
      await supabase.from('profiles').delete().eq('id', id);
      fetchUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User deleted"),
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
    final searchFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final userTitleSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final userSubtitleSize = (screenWidth * 0.032).clamp(12.0, 14.0);

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
            // Title without logo
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Manage all ERP users and roles',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.06),
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ),
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
                  onChanged: filterUsers,
                  style: TextStyle(fontSize: searchFontSize),
                  decoration: InputDecoration(
                    hintText: 'Search by name or role',
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
            // Users list
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                child: Text(
                  "No users found",
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
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final name = user['name'] ?? 'Unknown';
                  final role = user['role'] ?? '-';
                  final status = user['status'] ?? '-';
                  final initials = name
                      .toString()
                      .substring(0, 1)
                      .toUpperCase();

                  // Status color mapping
                  Color statusColor;
                  switch (status.toLowerCase()) {
                    case 'approved':
                      statusColor = const Color(0xFF10B981);
                      break;
                    case 'pending':
                      statusColor = const Color(0xFFF59E0B);
                      break;
                    case 'rejected':
                      statusColor = const Color(0xFFEF4444);
                      break;
                    default:
                      statusColor = const Color(0xFF94A3B8);
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: screenWidth * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                            screenWidth * 0.04),
                        child: Row(
                          children: [
                            // Avatar
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
                                    fontSize: userTitleSize,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: screenWidth * 0.04),
                            // User info
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: userTitleSize,
                                      fontWeight: FontWeight.w600,
                                      color:
                                      const Color(0xFF1E293B),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                      screenWidth * 0.01),
                                  Text(
                                    "Role: $role",
                                    style: TextStyle(
                                      fontSize: userSubtitleSize,
                                      color:
                                      const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                      screenWidth * 0.005),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                      screenWidth * 0.025,
                                      vertical:
                                      screenWidth * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor
                                          .withOpacity(0.15),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Status: $status",
                                      style: TextStyle(
                                        fontSize:
                                        userSubtitleSize *
                                            0.9,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFEF4444)),
                              onPressed: () =>
                                  deleteUser(user['id']),
                            ),
                          ],
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