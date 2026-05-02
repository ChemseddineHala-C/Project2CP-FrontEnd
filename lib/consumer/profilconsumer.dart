import 'package:fishapp/consumer/passwordchange.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import '../signin/cubit/themecubit.dart';
import 'batchDetails.dart';
import 'editeconsumer.dart';
class ProfileConsumerPage extends StatefulWidget {

  const ProfileConsumerPage({super.key});

  @override
  State<ProfileConsumerPage> createState() => _ProfileConsumerPageState();
}

class _ProfileConsumerPageState extends State<ProfileConsumerPage> {
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchConsumerProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor est géré par le thème dans main.dart
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
                await context.read<AuthCubit>().fetchConsumerProfile();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(user, isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader("COMMUNICATION"),
                    const SizedBox(height: 8),
                    _buildAccountInfoCard(user, isDark),
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
                  ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().fetchConsumerProfile(),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFE3F2FD),
            backgroundImage: user["profilePictureConsumer"] != null ? NetworkImage(user["profilePicture"]) : null,
            child: user["profilePicture"] == null ? Icon(Icons.person, size: 60, color: isDark ? Colors.white : const Color(0xFFD5A439)) : null,
          ),
          const SizedBox(height: 12),
          Text(user["Consumername"] ?? "Unknown", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("ID: ${user["id"] ?? "N/A"} |  ${user["consumerport"] ?? "N/A"}",
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          Text("SINCE: ${user["consumerdate"] ?? "N/A"}" ,style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditConsumerProfilePage()));
                },
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD5A439),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
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

  Widget _buildAccountInfoCard(Map<String, dynamic> user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _infoTile(Icons.email_outlined, "Email Address", user["consumeremail"] ?? "N/A", isDark),
          const Divider(),
          _infoTile(Icons.phone_outlined, "Phone Number", user["consumerphone"] ?? "N/A", isDark),
        ],
      ),
    );
  }
  Widget _buildSettingsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _settingsTile(Icons.lock_outline, "Change Password", isDark, trailing:MaterialButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChangepasswordConsPage()));
          },child:const Icon(Icons.chevron_right, color: Colors.grey) ,) ),
          const Divider(height: 1),
          _settingsTile(Icons.notifications_none, "Notifications", isDark,
              trailing: Switch(
                value: _notifications,
                activeColor: const Color(0xFF01A896),
                onChanged: (v) => setState(() => _notifications = v),
              )),
          const Divider(height: 1),
          // --- LE BOUTON DARK MODE ---
          _settingsTile(Icons.dark_mode_outlined, "Dark Mode", isDark,
              trailing: Switch(
                value: isDark,
                activeColor: const Color(0xFFD5A439),
                onChanged: (v) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              )),
        ],
      ),
    );
  }

  Widget _infoTile(IconData? icon, String label, String value, bool isDark, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon != null ? Icon(icon, color: isDark ? const Color(0xFF01A896) : const Color(0xFFD5A439)) : null,
      title: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w400)),
      subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFFD5A439))),
      trailing: trailing,
    );
  }

  Widget _settingsTile(IconData icon, String title, bool isDark, {required Widget trailing}) {
    return ListTile(
      leading: Icon(icon, color: isDark ? const Color(0xFF01A896) : const Color(0xFFD5A439)),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeConsumerPage(token: widget.token)));
          }, icon: Icon(Icons.home_outlined, color: isDark ? Colors.white54 : Colors.grey)),
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BatchDetails()));
          }, icon: Icon(Icons.list_alt_outlined, color: isDark ? Colors.white54 : Colors.grey)),
          IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart, color: isDark ? Colors.white54 : Colors.grey)),
          IconButton(onPressed: () {}, icon: Icon(Icons.person, color: isDark ? const Color(0xFF01A896) : const Color(0xFFD5A439), size: 30)),
        ],
      ),
    );
  }
}