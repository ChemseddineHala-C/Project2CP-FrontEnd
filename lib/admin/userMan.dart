import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Updated Trial Data to match your specific image details
  final List<UserCardData> _allUsers = [
    // UserCardData(
    //   name: "Capt, Elias Khaldi",
    //   id: "#F-9281",
    //   role: "Fishermans",
    //   status: "ACTIVE",
    //   image: "images/fish1.png",
    // ),
    // UserCardData(
    //   name: "Capt, Elias Khaldi",
    //   id: "#F-9281",
    //   role: "Fishermans",
    //   status: "PENDING",
    //   image: "images/fish1.png",
    // ),
    // UserCardData(
    //   name: "Dr, Elias Khaldi",
    //   id: "#F-9281",
    //   role: "Veterinarian",
    //   status: "ACTIVE",
    //   image: "images/fish1.png",
    // ),
    // UserCardData(
    //   name: "Dr, Elias Khaldi",
    //   id: "#F-9281",
    //   role: "Veterinarian",
    //   status: "PENDING",
    //   image: "images/fish1.png",
    // ),
    // UserCardData(
    //   name: "Mr, Elias Khaldi",
    //   id: "#F-9281",
    //   role: "Buyers",
    //   status: "ACTIVE",
    //   image: "images/fish1.png",
    // ),
  ];

  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse("http://localhost:3000/api/users"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        //_users = jsonDecode(response.body);
        //print(jsonDecode(response.body));
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
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
    List<Map<String, dynamic>> users = await getUsers();
    setState(() {
      _users = users;
      print(_users);
      _isLoading = false;
    });
  }

  List<UserCardData> get _filteredUsers {
    return _allUsers.where((user) {
      // Search logic depends on card info (Name and ID)
      bool matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.id.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesRole = _selectedRole == "All" || user.role == _selectedRole;
      bool matchesStatus =
          _selectedStatus == "All" ||
          user.status == _selectedStatus.toUpperCase();

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: Color(0xFF0F172A),
        ),
        title: Text(
          "My Batches",
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
                onTap: () {},
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
                            "Fishermans",
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
                // User List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) =>
                        UserItemCard(user: _filteredUsers[index]),
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
            color: isSelected ? Colors.white : Color(0xFF475569),
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
  const UserItemCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    bool isActive = user.status == "ACTIVE";
    Color accentColor = user.role == "Fishermans"
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
              child: Image.asset(
                user.image,
                width: 100,
                height: 90,
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
                                      fontSize: 16,
                                    ),
                                  ),
                                  _statusBadge(user.status),
                                ],
                              ),
                              Text(
                                "${user.role.replaceAll('s', '')} ID: ${user.id}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
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
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isActive ? "Full Profile" : "View Details",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0C6780),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isActive) ...[
                          const SizedBox(width: 8),
                          // Approve Button
                          Expanded(
                            child: _actionButton(
                              "Approve",
                              const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Reject Button
                          Expanded(
                            child: _actionButton(
                              "Reject",
                              const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          // Trashbin IconButton
                          IconButton(
                            onPressed: () {},
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
                        ],
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

  Widget _actionButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statusBadge(String status) {
    bool active = status == "ACTIVE";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: active ? const Color(0xFF047857) : const Color(0xFFB45309),
          fontSize: 10,
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
