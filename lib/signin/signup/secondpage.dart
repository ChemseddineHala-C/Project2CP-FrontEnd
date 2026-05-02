import 'package:fishapp/signin/signup/sixpage.dart';
import 'package:fishapp/signin/signup/therdpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import 'fivepage.dart';
class Secondpage extends StatefulWidget {
  const Secondpage({super.key});

  @override
  State<Secondpage> createState() => _SecondpageState();
}

class _SecondpageState extends State<Secondpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new account"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_return),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is GooglePasswordRequired) {
            // Navigation vers Fivepage après Google
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Fivepage(email: state.email)),
            );
          } else if (state is AuthAuthenticated) {
            //  Navigation vers Homepage après Facebook ou Login direct
            Navigator.pushReplacement(
              context,
              // MaterialPageRoute(builder: (_) => RoleSelectionPage()),
              MaterialPageRoute(builder: (_) => Sixpage( email: state.user['email'] ?? '')),

            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("Begin with Let's Fishing new free account.", textAlign: TextAlign.center),
                const Text("This helps you keep your Fishing way easier.", textAlign: TextAlign.center),
                const SizedBox(height: 30),

                // EMAIL BUTTON
                _buildButton(
                  text: "Continue with email",
                  color: const Color(0xFF013D73),
                  textColor: Colors.white,
                  onPressed: isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Therdpage())),
                ),

                const SizedBox(height: 20),

                // GOOGLE BUTTON
                _buildButton(
                  text: "Continue with Google",
                  color: Colors.white,
                  textColor: Colors.black87,
                  image: "images/google.png",
                  showLoader: isLoading,
                  onPressed: isLoading ? null : () => context.read<AuthCubit>().signInWithGoogle(),
                  borderSide: const BorderSide(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // FACEBOOK BUTTON
                _buildButton(
                  text: "Continue with Facebook",
                  color: const Color(0xFF1877F2),
                  textColor: Colors.white,
                  image: "images/facebook.png",
                  onPressed: isLoading ? null : () => context.read<AuthCubit>().signInWithFacebook(),
                ),

                const Spacer(),
                const Text(
                  "By using Let's fishing, you agree to the",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const Text(
                  "Terms and Privacy Policy",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget réutilisable pour les boutons
  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
    String? image,
    bool showLoader = false,
    BorderSide borderSide = BorderSide.none,
  }) {
    return SizedBox(
      width: 280,
      height: 50,
      child: MaterialButton(
        elevation: 0,
        color: color,
        disabledColor: color.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: borderSide),
        onPressed: onPressed,
        child: showLoader
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null) ...[
              Image.asset(image, height: 24),
              const SizedBox(width: 12),
            ],
            Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:projetsndcp/signin/signup/therdpage.dart';
// import '../cubit/authcubit.dart';
// import '../cubit/authstate.dart';
// import 'fivepage.dart';
//
// class Secondpage extends StatefulWidget {
//   const Secondpage({super.key});
//
//   @override
//   State<Secondpage> createState() => _SecondpageState();
// }
//
// class _SecondpageState extends State<Secondpage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create new account"),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: const Icon(Icons.keyboard_return),
//         ),
//       ),
//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) {
//           if (state is GooglePasswordRequired) {
//             // ✅ Navigate vers Fivepage avec l'email Google
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => Fivepage(email: state.email),
//               ),
//             );
//           } else if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message),
//                 backgroundColor: Colors.red,),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is AuthLoading) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             width: double.infinity,
//             height: double.infinity,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Begin with Let's Fishing new free account.",
//                 ),
//                 const Text(
//                   "This helps you keep your Fishing way easier.",
//                 ),
//                 const SizedBox(height: 25),
//
//                 // EMAIL BUTTON
//                 SizedBox(
//                   width: 250,
//                   height: 50,
//                   child: MaterialButton(
//                     color: const Color(0xFF013D73),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(builder: (context) => Therdpage()),
//                       );
//                     },
//                     child: const Text(
//                       "Continue with email",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // GOOGLE BUTTON
//                 SizedBox(
//                   width: 250,
//                   height: 50,
//                   child: MaterialButton(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       side: const BorderSide(color: Colors.grey),
//                     ),
//                     onPressed: () {
//                       context.read<AuthCubit>().signInWithGoogle();
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           "images/google.png",
//                           height: 24,
//                         ),
//                         const SizedBox(width: 10),
//                         const Text("Continue with Google"),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // FACEBOOK BUTTON
//                 SizedBox(
//                   width: 250,
//                   height: 50,
//                   child: MaterialButton(
//                     color: const Color(0xFF1877F2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     onPressed: () {
//                       context.read<AuthCubit>().signInWithFacebook();
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           "images/facebook.png", // logo FB
//                           height: 24,
//                         ),
//                         const SizedBox(width: 10),
//                         const Text(
//                           "Continue with Facebook",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Spacer(), // Pousse le contenu suivant vers le bas
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Text(
//                     "By using Let's fishing, you agree to the",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: Text(
//                     "Terms and Privacy Policy",
//                     style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
