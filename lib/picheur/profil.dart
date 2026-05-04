import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import '../signin/cubit/themecubit.dart';
import 'Weather&Safety.dart';
import 'addBatchPage.dart';
import 'editprofile.dart';
import 'myBatches.dart';
import 'password.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    // Correction : Ajout du token requis par le Cubit
    context.read<AuthCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final user = state.user;

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<AuthCubit>().fetchProfile();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(user, isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader("ACCOUNT INFO"),
                    const SizedBox(height: 8),
                    _buildAccountInfoCard(user, isDark),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader("DOCUMENTS"),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text("Upload New"),
                        )
                      ],
                    ),
                    _buildDocumentsCard(user, isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader("SETTINGS"),
                    const SizedBox(height: 8),
                    _buildSettingsCard(isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().fetchProfile(),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          return const Center(child: Text("No Profile Data Available"));
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 13),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> user, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFE3F2FD),
            backgroundImage: user["profile_photo"] != null ? NetworkImage(user["profilePicture"]) : null,
            child: user["profilePicture"] == null ? Icon(Icons.person, size: 60, color: isDark ? Colors.white : const Color(0xFF013D73)) : null,
          ),
          const SizedBox(height: 12),
          Text(user["full_name"] ?? "Unknown", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("ID: ${user["national_id"] ?? "N/A"} | LICENSE: ${user["fishing_license_number"] ?? "N/A"}",
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                },
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF013D73),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    // Correction : Utilisation correcte de Share
                    Share.share(
                      "🐟 Découvre Let's Fishing !\n"
                          "L'app du marché de poisson en Algérie.\n\n"
                          "📱 Télécharge ici :\n"
                          "https://play.google.com/store/apps/details?id=com.example.projetsndcp",
                      subject: "Let's Fishing App",
                    );
                  },
                  icon: const Icon(Icons.share, color: Color(0xFF475569)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(Map<String, dynamic> user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _infoTile(Icons.directions_boat, "Boat Name", user["boat_name"] ?? "N/A", isDark, trailing: _statusBadge()),
          const Divider(),
          Row(
            children: [
              Expanded(child: _infoTile(null, "Registration", user["registration_number"] ?? "N/A", isDark)),
              Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.grey.shade300),
              const SizedBox(width: 8),
              Expanded(child: _infoTile(null, "Home Port", user["home_port"] ?? "N/A", isDark)),
            ],
          ),
          const Divider(),
          _infoTile(Icons.email_outlined, "Email Address", user["email"] ?? "N/A", isDark),
          const Divider(),
          _infoTile(Icons.calendar_today_outlined, "License Expiry", user["fishing_license_number"] ?? "N/A", isDark),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(Map<String, dynamic> user, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _docTile(Icons.description, "Fishing License", "Valid until ${user["license_expiry_date"] ?? "N/A"}", isDark),
          const Divider(height: 1),
          _docTile(Icons.directions_boat, "Boat Registration", "Verified on ${user["created_at"] ?? "N/A"}", isDark),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _settingsTile(
            Icons.lock_outline,
            "Change Password",
            isDark,
            trailing: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangepasswordPage()));
              },
              icon: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ),
          const Divider(height: 1),
          _settingsTile(
            Icons.notifications_none,
            "Notifications",
            isDark,
            trailing: Switch(
              value: _notifications,
              activeThumbColor: const Color(0xFF01A896),
              onChanged: (v) => setState(() => _notifications = v),
            ),
          ),
          const Divider(height: 1),
          _settingsTile(
            Icons.dark_mode_outlined,
            "Dark Mode",
            isDark,
            trailing: Switch(
              value: isDark,
              activeThumbColor: const Color(0xFF01A896),
              onChanged: (v) {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData? icon, String label, String value, bool isDark, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon != null ? Icon(icon, color: isDark ? const Color(0xFF01A896) : const Color(0xFF013D73)) : null,
      title: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w400)),
      subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
      trailing: trailing,
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(5)),
      child: const Text("ACTIVE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _docTile(IconData icon, String title, String sub, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDark ? Colors.white12 : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: isDark ? const Color(0xFF01A896) : const Color(0xFF013D73)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  Widget _settingsTile(IconData icon, String title, bool isDark, {required Widget trailing}) {
    return ListTile(
      leading: Icon(icon, color: isDark ? const Color(0xFF01A896) : const Color(0xFF013D73)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
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
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () {

          }, icon: const Icon(Icons.home_outlined, color: Colors.grey)),
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherSafetypage()));
          }, icon: const Icon(Icons.anchor, color: Colors.grey)),
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyBatchesPage()));
          }, icon: const Icon(Icons.shopping_basket_outlined, color: Colors.grey)),
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Addbatchpage()));
          }, icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey)),
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
          }, icon: Icon(Icons.person, color: isDark ? const Color(0xFF01A896) : const Color(0xFF013D73), size: 30)),
        ],
      ),
    );
  }
}
