import 'package:fishapp/signin/signup/sixpage.dart';
import 'package:fishapp/signin/signup/therdpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import 'fivepage.dart';
import 'package:fishapp/signin/signup/sixpage.dart';
import 'package:fishapp/signin/signup/therdpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

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
          // AuthAuthenticated géré dans Fivepage directement ✅
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("Begin with Let's Fishing new free account.",
                    textAlign: TextAlign.center),
                const Text("This helps you keep your Fishing way easier.",
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),

                // EMAIL BUTTON
                _buildButton(
                  text: "Continue with email",
                  color: const Color(0xFF013D73),
                  textColor: Colors.white,
                  onPressed: isLoading
                      ? null
                      : () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Therdpage())),
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
          ));
        },
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 280,
      height: 50,
      child: MaterialButton(
        elevation: 0,
        color: color,
        disabledColor: color.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: onPressed,
        child: Text(text,
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}




