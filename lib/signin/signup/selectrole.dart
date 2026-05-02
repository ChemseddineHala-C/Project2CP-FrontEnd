import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../consumer/interfaceconsumer.dart';
import '../../picheur/interfacepage.dart';
import '../../vitirinaire/interfacevit.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

// class RoleSelectionPage extends StatefulWidget {
//   final String email;
//   const RoleSelectionPage( {super.key, required String this.email});
//
//   @override
//   State<RoleSelectionPage> createState() => _RoleSelectionPageState();
// }
//
// class _RoleSelectionPageState extends State<RoleSelectionPage> {
//   String? selectedRole;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Choisissez votre rôle"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             const SizedBox(height: 30),
//             const Text(
//               "Qui êtes-vous ?",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 40),
//
//             // 🔹 PÊCHEUR
//             _buildRoleCard(
//               role: "fishmen",
//               title: "Pêcheur",
//               icon: Icons.directions_boat,
//               color: const Color(0xFF013D73),
//             ),
//
//             const SizedBox(height: 16),
//
//             // 🔹 VÉTÉRINAIRE
//             _buildRoleCard(
//               role: "vet",
//               title: "Vétérinaire",
//               icon: Icons.medical_services,
//               color: Colors.green,
//             ),
//
//             const SizedBox(height: 16),
//
//             // 🔹 CONSUMER
//             _buildRoleCard(
//               role: "consumer",
//               title: "Consommateur",
//               icon: Icons.shopping_cart,
//               color: Colors.purple,
//             ),
//
//             const Spacer(),
//
//             // 🔥 BOUTON CONFIRMER
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: selectedRole == null
//                     ? null
//                     : () {
//                   // 🔥 Navigation directe (sans backend)
//                   if (selectedRole == "fishmen") {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => const Interfacepage()),
//                     );
//                   } else if (selectedRole == "vet") {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => const Interfacevitpage()),
//                     );
//                   } else if (selectedRole == "consumer") {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) =>
//                           const Interfaceconsumerpage()),
//                     );
//                   }
//                 },
//                 child: const Text("Confirmer"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Widget carte rôle
//   Widget _buildRoleCard({
//     required String role,
//     required String title,
//     required IconData icon,
//     required Color color,
//   }) {
//     final isSelected = selectedRole == role;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedRole = role;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.2) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? color : Colors.grey,
//             width: 2,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 30),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: isSelected ? color : Colors.black,
//               ),
//             ),
//             const Spacer(),
//             if (isSelected) Icon(Icons.check_circle, color: color),
//           ],
//         ),
//       ),
//     );
//   }
// }










class RoleSelectionPage extends StatefulWidget {
  final String email;
  const RoleSelectionPage({super.key, required String this.email});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {

  // Le rôle sélectionné par l'utilisateur
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisissez votre rôle"),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(

        listener: (context, state) {
          if (state is RoleSelectedSuccess) {
            // Redirige vers la bonne page selon le rôle
            if (state.role == "fishmen") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => Interfacepage()));

            } else if (state.role == "vet") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => Interfacevitpage()));

            } else if (state.role == "consumer") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => Interfaceconsumerpage()));
            }

          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
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
                  "Qui êtes-vous ?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sélectionnez votre rôle pour continuer",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // CARTE PÊCHEUR
                _buildRoleCard(
                  role: "fishmen",
                  title: "Pêcheur",
                  description: "Gérez vos sorties et vos prises",
                  icon: Icons.directions_boat,
                  color: const Color(0xFF013D73),
                ),
                const SizedBox(height: 16),

                // CARTE VÉTÉRINAIRE
                _buildRoleCard(
                  role: "vet",
                  title: "Vétérinaire",
                  description: "Inspectez et validez les lots de poisson",
                  icon: Icons.medical_services,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(height: 16),

                // CARTE CONSUMER
                _buildRoleCard(
                  role: "consumer",
                  title: "Consommateur",
                  description: "Achetez du poisson frais et certifié",
                  icon: Icons.shopping_cart,
                  color: const Color(0xFF6A1B9A),
                ),

                const Spacer(),

                // BOUTON CONFIRMER
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF013D73),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    // Désactivé si pas de rôle choisi ou si chargement
                    onPressed: (selectedRole == null || isLoading)
                        ? null
                        : () {
                      // Envoie le rôle au backend via le Cubit
                      context.read<AuthCubit>().selectRole( widget.email,selectedRole!);
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Confirmer",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
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

  // Widget réutilisable pour chaque carte de rôle
  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    // Est-ce que cette carte est sélectionnée ?
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        // Met à jour le rôle sélectionné
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Bordure colorée si sélectionné, grise sinon
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icône du rôle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            // Titre + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Coche si sélectionné
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}