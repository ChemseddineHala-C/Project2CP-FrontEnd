import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../consumer/interfaceconsumer.dart';
import '../../picheur/interfacepage.dart';
import '../../vitirinaire/interfacevit.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';


class RoleSelectionPage extends StatefulWidget {
  final String email;
  final String password;
  const RoleSelectionPage({super.key, required this.email, required this.password});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose your role"),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is RoleSelectedSuccess) {
            // ✅ Noms de rôles corrects
            if (state.role == "fisherman") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => Interfacepage()));
            } else if (state.role == "veterinarian") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => Interfacevitpage()));
            } else if (state.role == "customer") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => Interfaceconsumerpage()));
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Who are you ?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select your role to continue",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // ✅ Noms de rôles identiques au listener
                _buildRoleCard(
                  role: "fisherman",
                  title: "Fisherman",
                  description: "Manage your trips and catches",
                  icon: Icons.directions_boat,
                  color: const Color(0xFF013D73),
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  role: "veterinarian",
                  title: "Veterinarian",
                  description: "Inspect and validate fish batches",
                  icon: Icons.medical_services,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  role: "customer",
                  title: "Consumer",
                  description: "Buy fresh and certified fish",
                  icon: Icons.shopping_cart,
                  color: const Color(0xFF6A1B9A),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF013D73),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: (selectedRole == null || isLoading)
                        ? null
                        : () {
                      // ✅ Appel unique ici seulement
                      context.read<AuthCubit>().selectRole(
                        widget.email,
                        widget.password,
                        selectedRole!,
                      );
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Confirm",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}