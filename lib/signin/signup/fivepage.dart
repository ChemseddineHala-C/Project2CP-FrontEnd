import 'package:fishapp/signin/signup/sixpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

import 'package:fishapp/signin/signup/sixpage.dart';
import 'package:flutter/material.dart';

class Fivepage extends StatefulWidget {
  final String email;
  const Fivepage({super.key, required this.email});

  @override
  State<Fivepage> createState() => _FivepageState();
}

class _FivepageState extends State<Fivepage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool _hasNumber(String password) => password.contains(RegExp(r'[0-9]'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create your password 3 / 3"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Enter a strong password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildhelppassword(_passwordController.text),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF013D73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final password = _passwordController.text;
                    bool isLengthValid = password.length >= 6 && password.length <= 20;
                    bool hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                    bool hasDigit = _hasNumber(password);

                    if (isLengthValid && hasSymbol && hasDigit) {
                      // ✅ Navigation directe sans appel backend
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Sixpage(
                            email: widget.email,
                            password: password, // ← juste passer le password
                          ),
                        ),
                      );
                    } else {
                      String errorMsg = "";
                      if (!isLengthValid) errorMsg = "Password must be 6-20 characters";
                      else if (!hasSymbol) errorMsg = "Password must have at least one symbol";
                      else if (!hasDigit) errorMsg = "Password must have at least one number";

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _buildhelppassword(String text) {

  // Les 3 conditions
  bool isLengthValid = text.length >= 6 && text.length <= 20;
  bool hasNumber     = text.contains(RegExp(r'[0-9]'));
  bool hasSymbol     = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildIndicatorRow("minimum 6 and maximum 20 characters", isLengthValid),
      const SizedBox(height: 8),
      _buildIndicatorRow("must have at least one number", hasNumber),
      const SizedBox(height: 8),
      _buildIndicatorRow("must have at least one symbol (@, #, &, ...)", hasSymbol),
    ],
  );
}

// ✅ Widget réutilisable pour chaque indicateur
Widget _buildIndicatorRow(String text, bool isValid) {
  return Row(
    children: [
      // ─── Cercle avec icône ────────────────────────────
      AnimatedContainer(
        duration: const Duration(milliseconds: 300), // ← animation douce
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isValid ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(50),
        ),
        child: isValid
        // ✅ Valide → icône coche blanche
            ? const Icon(Icons.check, color: Colors.white, size: 14)
        // ❌ Invalide → icône croix grise
            : const Icon(Icons.close, color: Colors.transparent, size: 14),
      ),

      const SizedBox(width: 10),

      // ─── Texte ────────────────────────────────────────
      Text(
        text,
        style: TextStyle(
          color: isValid ? Colors.black : Colors.grey,
          fontSize: 13,
          // ✅ Gras si valide
          fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    ],
  );
}














// class Fivepage extends StatefulWidget {
//   final String email;
//   const Fivepage({super.key, required this.email});
//
//   @override
//   State<Fivepage> createState() => _FivepageState();
// }
//
// class _FivepageState extends State<Fivepage> {
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;
//
//   bool _hasNumber(String password) {
//     return password.contains(RegExp(r'[0-9]'));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create your password 3 / 3"),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) {
//           // if (state is PasswordSentSuccess) {
//           //   ScaffoldMessenger.of(context).showSnackBar(
//           //     const SnackBar(
//           //       content: Text("Account created successfully!"),
//           //       backgroundColor: Colors.green, // Vert pour succès
//           //     ),
//           //   );
//           //   Navigator.push(context, MaterialPageRoute(builder: (context) => Sixpage(email: widget.email,)));
//           // }
//           if (state is AuthAuthenticated) {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => Sixpage(email: widget.email, password: _passwordController.text)));
//           }
//           else if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red, // Rouge pour erreur
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           return Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: !_isPasswordVisible,
//                     onChanged: (value) => setState(() {}),
//                     decoration: InputDecoration(
//                       hintText: "Enter a strong password",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                           color: Colors.grey,
//                         ),
//                         onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   _buildhelppassword(_passwordController.text),
//                   const SizedBox(height: 30),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF013D73),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: state is AuthLoading
//                           ? null
//                           : () {
//                         final password = _passwordController.text;
//                         bool isLengthValid = password.length >= 6 && password.length <= 20;
//                         bool hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//                         bool hasDigit = _hasNumber(password);
//
//                         if (isLengthValid && hasSymbol && hasDigit) {
//                           context.read<AuthCubit>().registerUser(widget.email, password);
//                         } else {
//                           String errorMsg = "";
//                           if (!isLengthValid) errorMsg = "Password must be 6-20 characters";
//                           else if (!hasSymbol) errorMsg = "Password must have at least one symbol";
//                           else if (!hasDigit) errorMsg = "Password must have at least one number";
//
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(errorMsg),
//                               backgroundColor: Colors.red, // Rouge pour erreur de validation
//                             ),
//                           );
//                         }
//                       },
//                       child: state is AuthLoading
//                           ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                       )
//                           : MaterialButton(
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(builder: (context) => Sixpage(email: widget.email,password: _passwordController.text)),
//                           );
//                         },
//                         child: const Text(
//                           "Continue",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// Widget _buildhelppassword(String text) {
//
//   // Les 3 conditions
//   bool isLengthValid = text.length >= 6 && text.length <= 20;
//   bool hasNumber     = text.contains(RegExp(r'[0-9]'));
//   bool hasSymbol     = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _buildIndicatorRow("minimum 6 and maximum 20 characters", isLengthValid),
//       const SizedBox(height: 8),
//       _buildIndicatorRow("must have at least one number", hasNumber),
//       const SizedBox(height: 8),
//       _buildIndicatorRow("must have at least one symbol (@, #, &, ...)", hasSymbol),
//     ],
//   );
// }
//
// // ✅ Widget réutilisable pour chaque indicateur
// Widget _buildIndicatorRow(String text, bool isValid) {
//   return Row(
//     children: [
//       // ─── Cercle avec icône ────────────────────────────
//       AnimatedContainer(
//         duration: const Duration(milliseconds: 300), // ← animation douce
//         width: 20,
//         height: 20,
//         decoration: BoxDecoration(
//           color: isValid ? Colors.green : Colors.grey[300],
//           borderRadius: BorderRadius.circular(50),
//         ),
//         child: isValid
//         // ✅ Valide → icône coche blanche
//             ? const Icon(Icons.check, color: Colors.white, size: 14)
//         // ❌ Invalide → icône croix grise
//             : const Icon(Icons.close, color: Colors.transparent, size: 14),
//       ),
//
//       const SizedBox(width: 10),
//
//       // ─── Texte ────────────────────────────────────────
//       Text(
//         text,
//         style: TextStyle(
//           color: isValid ? Colors.black : Colors.grey,
//           fontSize: 13,
//           // ✅ Gras si valide
//           fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
//         ),
//       ),
//     ],
//   );
// }