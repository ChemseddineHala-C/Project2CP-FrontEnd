import 'package:fishapp/vitirinaire/updatpassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import 'editprofilvit.dart';

class ProfilevitPage extends StatefulWidget {

  const ProfilevitPage({super.key});

  @override
  State<ProfilevitPage> createState() => _ProfilevitPageState();
}

class _ProfilevitPageState extends State<ProfilevitPage> {
  final bool _notifications = true;
  final bool _darkMode = false;
  final Color primaryTeal = const Color(0xFF00A896);

  @override
  void initState() {
    super.initState();
    // Utilisation de la fonction fetchvitProfile que nous avons rendue dynamique
    context.read<AuthCubit>().fetchvitProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                // Utilisation de la même fonction pour le rafraîchissement
                await context.read<AuthCubit>().fetchvitProfile();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(user),
                    const SizedBox(height: 24),
                    _buildSectionHeader("CREDENTIELS"),
                    const SizedBox(height: 8),
                    _buildCredentialsCard(user),
                    const SizedBox(height: 24),
                    _buildSectionHeader("COMMUNICATION"),
                    const SizedBox(height: 8),
                    _buildCommunicationCard(user),
                    const SizedBox(height: 24),
                    _buildSectionHeader("SETTINGS"),
                    const SizedBox(height: 8),
                    _buildSettingsCard(),
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
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message),
                  TextButton(
                    onPressed: () => context.read<AuthCubit>().fetchvitProfile(),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          return const Center(child: Text("No Profile Data Available"));
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 13),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFE3F2FD),
            backgroundImage: user["profilePicture_vit"] != null ? NetworkImage(user["profilePicture_vit"]) : null,
            child: user["profilePicture_vit"] == null ? Icon(Icons.person, size: 60, color: primaryTeal) : null,
          ),
          const SizedBox(height: 12),
          Text(user["name_vit"] ?? "Dr. Mohamed", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("ID: ${user["id_vit"] ?? "/"} | LICENSE: ${user["license_vit"] ?? "/"}",
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilevitPage()));
                },
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await SharePlus.instance.share(
                      ShareParams(
                        text: "🐟 Découvre Let's Fishing !\n"
                            "L'app du marché de poisson en Algérie.\n\n"
                            "📱 Télécharge ici :\n"
                            "https://play.google.com/store/apps/details?id=com.example.projetsndcp\n\n"
                            "Rejoins-moi sur l'app !",
                        subject: "Let's Fishing App",
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, color: Color(0xFF475569)),
                  label: const Text(
                    "",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCredentialsCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _infoTile(Icons.anchor_outlined, "ASSIGNED PORT", user["homePort_vit"] ?? "Oran Port", trailing: _statusBadge()),
          const Divider(height: 32),
          _infoTile(Icons.medical_services_outlined, "SPECIALIZATION", user["specialization_vit"] ?? "Aquatic Pathology"),
          const Divider(height: 32),
          _infoTile(Icons.history_edu_outlined, "EXPERIENCE", user["experience_vit"] ?? "12 Years Professional"),
          const Divider(height: 32),
          _infoTile(Icons.verified_user_outlined, "LICENSE EXPIRY", user["licenseExpiry_vit"] ?? "Dec 31, 2024"),
        ],
      ),
    );
  }

  Widget _buildCommunicationCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _infoTile(Icons.email_outlined, "Email Address", user["email_vit"] ?? "mohamed@mail.com"),
          const Divider(height: 32),
          _infoTile(Icons.phone_outlined, "Phone Number", user["phone_vit_number"] ?? "+213 550515255"),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _settingsTile(Icons.lock_outline, "Change Password", trailing: IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChangepasswordVitPage()));
          }, icon: const Icon(Icons.chevron_right, color: Colors.grey))),
          const Divider(height: 1),
          _settingsTile(Icons.language, "Language", trailing: const Text("English >", style: TextStyle(color: Colors.grey))),
          const Divider(height: 1),
          _settingsTile(Icons.notifications_none, "Notifications",
              trailing: Switch(value: _notifications, activeColor: primaryTeal, onChanged: (v) {})),
          const Divider(height: 1),
          _settingsTile(Icons.dark_mode_outlined, "Dark Mode",
              trailing: Switch(value: _darkMode, activeColor: primaryTeal, onChanged: (v) {})),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryTeal, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(5)),
      child: const Text("ACTIVE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _settingsTile(IconData icon, String title, {required Widget trailing}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
      trailing: trailing,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilevitPage()));
          }, icon: const Icon(Icons.home_outlined, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.access_time, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: Icon(Icons.person, color: primaryTeal, size: 30)),
        ],
      ),
    );
  }
}
