import 'package:flutter/material.dart';
import './addvet.dart';
// Reuse your existing navigation targets if available, or placeholders
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedRole = "All";
  String _selectedStatus = "All";

  // Trial Data for testing
  final List<UserItem> _allUsers = [
    UserItem(
      name: "Capt, Elias Khaldi",
      id: "#F-9281",
      role: "Fisherman",
      status: "ACTIVE",
      image: "images/fish1.png", // Replace with your assets
    ),
    UserItem(
      name: "Capt, Elias Khaldi",
      id: "#F-9281",
      role: "Fisherman",
      status: "PENDING",
      image: "images/fish1.png",
    ),
    UserItem(
      name: "Dr, Elias Khaldi",
      id: "#F-9281",
      role: "Veterinarian",
      status: "ACTIVE",
      image: "images/fish1.png",
    ),
    UserItem(
      name: "Dr, Elias Khaldi",
      id: "#F-9281",
      role: "Veterinarian",
      status: "PENDING",
      image: "images/fish1.png",
    ),
    UserItem(
      name: "Mr, Elias Khaldi",
      id: "#F-9281",
      role: "Buyer",
      status: "ACTIVE",
      image: "images/fish1.png",
    ),
  ];

  List<UserItem> get _filteredUsers {
    return _allUsers.where((user) {
      bool matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesRole = _selectedRole == "All" || user.role == _selectedRole.replaceAll("s", ""); // Handle "Fishermans" vs "Fisherman"
      bool matchesStatus = _selectedStatus == "All" || user.status == _selectedStatus.toUpperCase();
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Addvet(),
                    ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextFormField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Role Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  "All",
                  "Fishermans",
                  "Veterinarian",
                  "Buyers",
                ].map((role) => _buildRoleChip(role)).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Total and Status Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total (${_filteredUsers.length} user)",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      items: ["All", "Active", "Pending"]
                          .map((s) => DropdownMenuItem(value: s, child: Text("Filter by $s", style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // User List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) => UserCard(user: _filteredUsers[index]),
            ),

            // Skeleton Placeholder (as seen in your image)
            const UserSkeleton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildRoleChip(String role) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D6880) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          role,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.home_outlined, color: Colors.grey),
          const Icon(Icons.grid_view, color: Colors.grey),
          const Icon(Icons.person_outline, color: Colors.grey),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group, color: Color(0xFF136B7C), size: 30),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF136B7C), shape: BoxShape.circle))
            ],
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserItem user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Determine colors based on role
    Color sideColor;
    if (user.role == "Fisherman") {
      sideColor = const Color(0xFF4A789C);
    } else if (user.role == "Veterinarian") {
      sideColor = const Color(0xFF3EB489);
    } else {
      sideColor = const Color(0xFFD5A439);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Accent Bar
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: sideColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Image.asset(user.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 40, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              _statusChip(user.status),
                            ],
                          ),
                          Text("${user.role} ID: ${user.id}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 12),
                          // Action Buttons based on status
                          user.status == "ACTIVE" 
                            ? _buildActiveActions() 
                            : _buildPendingActions(),
                        ],
                      ),
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

  Widget _buildActiveActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF136B7C),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Full Profile", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
        )
      ],
    );
  }

  Widget _buildPendingActions() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _smallButton("View Details", const Color(0xFFF1F5F9), Colors.black54),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: _smallButton("Approve", const Color(0xFF10B981), Colors.white),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: _smallButton("Reject", const Color(0xFFEF4444), Colors.white),
        ),
      ],
    );
  }

  Widget _smallButton(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusChip(String status) {
    bool isActive = status == "ACTIVE";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? const Color(0xFF166534) : const Color(0xFF92400E),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class UserSkeleton extends StatelessWidget {
  const UserSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 15, color: Colors.grey[200]),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 12, color: Colors.grey[100]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserItem {
  final String name, id, role, status, image;
  UserItem({required this.name, required this.id, required this.role, required this.status, required this.image});
}