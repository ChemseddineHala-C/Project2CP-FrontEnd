import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';

class Adminpecheurinfo extends StatefulWidget {
  const Adminpecheurinfo({super.key});

  @override
  State<Adminpecheurinfo> createState() => _AdminpecheurinfoState();
}

class _AdminpecheurinfoState extends State<Adminpecheurinfo> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchAdminpecheur();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("User Details",
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF011A33))),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF01A896)));
          }

          if (state is AdminLoaded) {
            final user = state.user;
            return RefreshIndicator(
              onRefresh: () async => context.read<AuthCubit>().fetchAdminpecheur(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(user, isDark),
                    const SizedBox(height: 24),
                    _buildSection(
                      isDark: isDark,
                      number: "1",
                      title: "Personal Information",
                      children: [
                        _label("Full Name", isDark),
                        _readOnlyField(user["fullName"] ?? "Amine", isDark),
                        const SizedBox(height: 16),
                        _label("National ID / Passport", isDark),
                        _readOnlyField(user["nationalid"] ?? "10002651", isDark),
                        const SizedBox(height: 16),
                        _label("Phone Number", isDark),
                        _readOnlyField(user["phone"] ?? "+213 674854088", isDark),
                        const SizedBox(height: 16),
                        _label("Email Address", isDark),
                        _readOnlyField(user["email"] ?? "Projet@esi-sba.dz", isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      number: "2",
                      title: "Boat Details",
                      children: [
                        _label("Boat Name", isDark),
                        _readOnlyField(user["Boat_name"] ?? "king", isDark),
                        const SizedBox(height: 16),
                        _label("Registration Number", isDark),
                        _readOnlyField(user["registration_number"] ?? "LIC-00-1122", isDark),
                        const SizedBox(height: 16),
                        _label("Home Port", isDark),
                        _readOnlyField(user["home_port"] ?? "oran", isDark),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    _buildSection(
                      isDark: isDark,
                      number: "3",
                      title: "Licenses & Documents",
                      children: [
                        _label("Primary License #", isDark),
                        _readOnlyField(user["license"] ?? "LIC-00-1122", isDark),
                        const SizedBox(height: 16),
                        _label("Expiry Date", isDark),
                        _readOnlyField(user["expiry_date"] ?? "Sep/17 /2026", isDark),
                        const SizedBox(height: 24),
                        Text("Required Uploads (PDF or JPG)",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                        const SizedBox(height: 16),
                        _buildDownloadTile(Icons.description, "License", "License.pdf", isDark),
                        const SizedBox(height: 12),
                        _buildDownloadTile(Icons.directions_boat, "Boat Registration", "Boat.pdf", isDark),
                        const SizedBox(height: 12),
                        _buildDownloadTile(Icons.badge_outlined, "ID Card", "ID.pdf", isDark),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          return Center(child: Text("No Data", style: TextStyle(color: isDark ? Colors.white : Colors.black)));
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 65, height: 65,
              color: Colors.grey[200],
              child: user["photo_profilevit"] != null
                  ? Image.network(user["photo_profilevit"], fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 35, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user["fullName"] ?? "Dr, Elias Khaled",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Fisherman ID: ${user["fisher_id"] ?? "#F-9281"}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(user["fisher_state"],
                style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required bool isDark, required String number, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFF01A896),
                child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569))),
  );

  Widget _readOnlyField(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Text(text, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildDownloadTile(IconData icon, String title, String filename, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF01A896).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF01A896), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(filename, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2F1),
              foregroundColor: const Color(0xFF01A896),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Download", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const Adminvitinfo()));
            },
            icon: const Icon(Icons.block, color: Colors.white, size: 20),
            label: const Text("Reject", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const Adminvetinfo()));
            },
            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            label: const Text("Approve", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
