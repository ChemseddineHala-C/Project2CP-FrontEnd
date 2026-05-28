import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './Admin_Pecheur.dart';
import './admin_vit.dart';
import './homepageadmin.dart';
import './addvet.dart';
import '../HOST.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedRole = "All";
  String _selectedStatus = "All";

  UserCardData _mapApiUser(Map<String, dynamic> user) {
    final rawRole = user['role']?.toString() ?? '';
    final role = _displayRole(rawRole);
    final rawStatus = user['account_status']?.toString() ?? '';

    return UserCardData(
      name: user['email']?.toString() ?? 'Unknown',
      id: user['id']?.toString() ?? '',
      role: role,
      status: rawStatus,
      image: _profileImageUrl(user['profile_photo']?.toString()),
    );
  }

  String _displayRole(String rawRole) {
    switch (rawRole.toLowerCase()) {
      case 'fisherman':
        return 'Fisherman';
      case 'veterinarian':
        return 'Veterinarian';
      case 'customer':
        return 'Buyers';
      case 'buyer':
        return 'Buyers';
      case 'admin':
        return 'Admin';
      case 'super_admin':
      case 'super-admin':
      case 'super admin':
        return 'Super Admin';
      default:
        return rawRole.isEmpty
            ? 'Unknown'
            : rawRole[0].toUpperCase() + rawRole.substring(1);
    }
  }

  bool _isPending(String accountStatus) {
    return accountStatus.toLowerCase() == 'pending';
  }

  bool _isApprovedOrRejected(String accountStatus) {
    final status = accountStatus.toLowerCase();
    return status == 'approved' || status == 'rejected';
  }

  String _getApiEndpoint(String role, String userId, String action) {
    final roleKey = role == 'Fisherman' ? 'fishermen' : 'veterinarians';
    return 'http://$HOST:3000/api/$roleKey/$userId/$action';
  }

  Future<void> _approveUser(UserCardData user) async {
    print(
      'Approve clicked for user: ${user.name} (${user.id}) with role: ${user.role}',
    );
    if (!_isPending(user.status)) {
      print('User status is not pending: ${user.status}');
      return;
    }

    final token = await _getToken();
    if (token == null) {
      print('No token available');
      return;
    }

    try {
      final endpoint = _getApiEndpoint(user.role, user.id, 'approve');
      print('Approve endpoint: $endpoint');
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      print('Approve response status: ${response.statusCode}');
      print('Approve response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchUsers();
      } else {
        print('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Approve error: $e');
    }
  }

  Future<void> _rejectUser(UserCardData user) async {
    print(
      'Reject clicked for user: ${user.name} (${user.id}) with role: ${user.role}',
    );
    if (!_isPending(user.status)) {
      print('User status is not pending: ${user.status}');
      return;
    }

    final token = await _getToken();
    if (token == null) {
      print('No token available');
      return;
    }

    try {
      final endpoint = _getApiEndpoint(user.role, user.id, 'reject');
      print('Reject endpoint: $endpoint');
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      print('Reject response status: ${response.statusCode}');
      print('Reject response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchUsers();
      } else {
        print('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Reject error: $e');
    }
  }

  String _profileImageUrl(String? profilePhoto) {
    if (profilePhoto == null || profilePhoto.isEmpty) {
      return 'images/fish1.png';
    }

    if (profilePhoto.startsWith('http')) {
      return profilePhoto;
    }

    if (profilePhoto.startsWith('src/') || profilePhoto.contains('/uploads/')) {
      return 'http://$HOST:3000/$profilePhoto';
    }

    return 'images/fish1.png';
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse("http://$HOST:3000/api/users"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);
      print(decoded);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    final users = await getUsers();
    if (!mounted) return;

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  List<UserCardData> get _filteredUsers {
    return _users.map(_mapApiUser).where((user) {
      // Exclude admin and super admin users
      if (user.role == "Admin" || user.role == "Super Admin") {
        return false;
      }

      bool matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.id.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesRole = _selectedRole == "All" || user.role == _selectedRole;

      bool matchesStatus = _selectedStatus == "All";
      if (!matchesStatus) {
        if (_selectedStatus == "Active") {
          matchesStatus = _isApprovedOrRejected(user.status);
        } else if (_selectedStatus == "Pending") {
          matchesStatus = _isPending(user.status);
        }
      }

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "User Management",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.6,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 3,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Material(
              color: const Color(0x1A0F68E6),
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Addvet()),
                  );
                },
                borderRadius: BorderRadius.circular(50),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: Color(0xFF023E77)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: "Search users...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Role Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            "All",
                            "Fisherman",
                            "Veterinarian",
                            "Buyers",
                          ].map((role) => _buildFilterChip(role)).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Total count and Status filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total (${_filteredUsers.length} user)",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                        ),
                      ),
                      _buildStatusDropdown(),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // User List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) => UserItemCard(
                      user: _filteredUsers[index],
                      onApprove: () => _approveUser(_filteredUsers[index]),
                      onReject: () => _rejectUser(_filteredUsers[index]),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int activeIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              if (activeIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomepageadminPage(),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.home,
              color: activeIndex == 0
                  ? (isDark ? const Color(0xFF023E77) : const Color(0xFF013D73))
                  : (isDark ? Colors.white54 : Colors.grey),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {
              _fetchUsers();
            },
            icon: Icon(
              Icons.people,
              color: activeIndex == 1
                  ? (isDark ? const Color(0xFF023E77) : const Color(0xFF013D73))
                  : (isDark ? Colors.white54 : Colors.grey),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedRole == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D6880) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          items: ["All", "Active", "Pending"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                "Filter by $value",
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedStatus = val!),
        ),
      ),
    );
  }
}

class UserItemCard extends StatelessWidget {
  final UserCardData user;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const UserItemCard({
    super.key,
    required this.user,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    bool isPending = user.status.toLowerCase() == 'pending';
    bool isApprovedOrRejected =
        user.status.toLowerCase() == 'approved' ||
        user.status.toLowerCase() == 'rejected';
    bool showApprovalButtons =
        isPending && (user.role == "Fisherman" || user.role == "Veterinarian");

    Color accentColor = user.role == "Fisherman"
        ? Colors.blue
        : (user.role == "Veterinarian" ? Colors.teal : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: user.image.startsWith('http')
                  ? Image.network(
                      user.image,
                      width: 70,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'images/fish1.png',
                        width: 70,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      user.image,
                      width: 70,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                  _statusBadge(user.status),
                                ],
                              ),
                              Text(
                                "${user.role.compareTo("Fishermans") == 0 ? "Fisherman" : user.role.replaceAll('s', '')} ID: ${user.id}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // View Details or Full Profile Button
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (user.role == 'Fisherman') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Adminpecheurinfo(id: user.id),
                                  ),
                                );
                              } else if (user.role == 'Veterinarian') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Adminvitinfo(id: user.id),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Not found",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isApprovedOrRejected
                                  ? "Full Profile"
                                  : "View Details",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF0C6780),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (showApprovalButtons) ...[
                          const SizedBox(width: 8),
                          // Approve Button
                          Expanded(
                            child: _actionButton(
                              "Approve",
                              const Color(0xFF10B981),
                              onApprove,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Reject Button
                          Expanded(
                            child: _actionButton(
                              "Reject",
                              const Color(0xFFEF4444),
                              onReject,
                            ),
                          ),
                        ],
                        //if (isApprovedOrRejected) ...[
                        const SizedBox(width: 8),
                        // Trashbin IconButton
                        IconButton(
                          onPressed: () {
                            deleteUser(user.id, context);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFBA1A1A),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x33FFDAD6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        //],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final statusLower = status.toLowerCase();
    final displayStatus = status.isEmpty
        ? 'Unknown'
        : status[0].toUpperCase() + status.substring(1).toLowerCase();

    Color bgColor;
    Color textColor;

    if (statusLower == 'approved') {
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF047857);
    } else if (statusLower == 'rejected') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFBA1A1A);
    } else {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class UserCardData {
  final String name, id, role, status, image;
  UserCardData({
    required this.name,
    required this.id,
    required this.role,
    required this.status,
    required this.image,
  });
}

void deleteUser(String id, BuildContext context) async {
  try {
    String? token = await _getToken();
    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No token found, please login again"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final response = await http.delete(
      Uri.parse("http://$HOST:3000/api/users/$id/delete"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  } catch (e) {
    print("Error in deleteAccount: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
