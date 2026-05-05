import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../consumer/interfaceconsumer.dart';
import '../picheur/interfacepage.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import '../vitirinaire/interfacevit.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          "Login into account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final role = state.user['role'];

            if (role == "fisherman") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Interfacepage()),
              );
            } else if (role == "veterinarian") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Interfacevitpage()),
              );
            } else if (role == "customer") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Interfaceconsumerpage()),
              );
            }
          }

          if (state is AuthError) {
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

          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Log into account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // EMAIL
                    _buildInputField(
                      label: "Email",
                      hint: "example@mail.com",
                      controller: _emailController,
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    _buildInputField(
                      label: "Password",
                      hint: "Enter password",
                      controller: _passwordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 30),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A3D62),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {},
                      child: const Text("Forgot password?"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 INPUT FIELD
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _isObscured : false,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isObscured
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _isObscured = !_isObscured);
              },
            )
                : null,
          ),
        ),
      ],
    );
  }
}











// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isObscured = true;
//   bool _isLoading = false;
//
//   // Handles the "Log in" action
//   void _handleLogin() async {
//     setState(() => _isLoading = true);
//
//     // Simulate network delay for the loading state shown in page 05
//     await Future.delayed(const Duration(seconds: 2));
//
//     if (mounted) {
//       setState(() => _isLoading = false);
//       // Navigate to Home or show error
//     }
//   }
//   // void _login() {
//   //   context.read<AuthCubit>().login(email, password);
//   // }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _login() {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("All fields are required"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     // ✅ Envoie au backend — listener gère la navigation
//     context.read<AuthCubit>().login(
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back),
//           color: const Color(0xFF0F172A),
//         ),
//         title: const Text(
//           "Login into account",
//           style: TextStyle(
//             color: Color(0xFF0F172A),
//             fontWeight: FontWeight.w700,
//             fontSize: 24,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         shadowColor: Colors.black,
//         elevation: 3,
//       ), // Light blue background from images
//       body:BlocConsumer<AuthCubit, AuthState>(
//           listener: (context, state) {
//             if (state is AuthAuthenticated) {
//               // naviguer selon le role
//               final role = state.user['role'];
//               if (role == "fisherman") {
//                 Navigator.pushReplacement(context,
//                     MaterialPageRoute(builder: (_) => Interfacepage()));
//               } else if (role == "veterinarian") {
//                 Navigator.pushReplacement(context,
//                     MaterialPageRoute(builder: (_) => Interfacevitpage()));
//               } else if (role == "customer") {
//                 Navigator.pushReplacement(context,
//                     MaterialPageRoute(builder: (_) => Interfaceconsumerpage()));
//               }
//             } else if (state is AuthError) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//               );
//             }
//           },
//           builder: (context, state) {
//             final isLoading = state is AuthLoading;
//       child:Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 24),
//           padding: const EdgeInsets.all(32),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(40),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHeader(),
//                 const Block(),
//                 _buildInputField(
//                   label: "Email",
//                   hint: "example@example",
//                   controller: _emailController,
//                   icon: null,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildInputField(
//                   label: "Password",
//                   hint: "Enter password",
//                   controller: _passwordController,
//                   isPassword: true,
//                 ),
//                 const Block(),
//                 _buildLoginButton(),
//                 const SizedBox(height: 16),
//                 TextButton(
//                   onPressed: () {},
//                   child: const Text(
//                     "Forgot password?",
//                     style: TextStyle(
//                       color: Color(0xFF0F172A),
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),);
//                 }
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.arrow_back, size: 20),
//           ),
//         ),
//         const Text(
//           "Log into account",
//           style: TextStyle(
//             fontWeight: FontWeight.w800,
//             fontSize: 18,
//             fontFamily: "Inter",
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInputField({
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//     bool isPassword = false,
//     IconData? icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 13,
//             color: Color(0xFF1E293B),
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           obscureText: isPassword ? _isObscured : false,
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//             suffixIcon: isPassword
//                 ? IconButton(
//                     icon: Icon(
//                       _isObscured
//                           ? Icons.visibility_off_outlined
//                           : Icons.visibility_outlined,
//                       color: Colors.grey,
//                       size: 20,
//                     ),
//                     onPressed: () => setState(() => _isObscured = !_isObscured),
//                   )
//                 : null,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoginButton() {
//     // Colors from page 04 (Active) and page 05 (Loading/Disabled)
//     final Color btnColor = _isLoading
//         ? const Color(0xFF8BA7C1)
//         : const Color(0xFF0A3D62);
//
//     return SizedBox(
//       width: double.infinity,
//       height: 55,
//       child: ElevatedButton(
//         // onPressed: _isLoading ? null : _handleLogin,
//         onPressed: _isLoading ? null : _login,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: btnColor,
//           disabledBackgroundColor: const Color(0xFF8BA7C1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//         child: _isLoading
//             ? const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Text(
//                     "Log in",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               )
//             : const Text(
//                 "Log in",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//       ),
//     );
//   }
// }
//
// // Re-using your Block spacing from previous files
// class Block extends StatelessWidget {
//   const Block({super.key});
//   @override
//   Widget build(BuildContext context) => const SizedBox(height: 24);
// }







