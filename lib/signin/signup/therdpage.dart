import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import 'fourpage.dart';

class Therdpage extends StatefulWidget {
  const Therdpage({super.key});

  @override
  State<Therdpage> createState() => _TherdpageState();
}

class _TherdpageState extends State<Therdpage> {
  final TextEditingController _emailController = TextEditingController();//lire ce que utilisateur tape

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add your email 1 / 3"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is EmailSentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Email sent successfully!"),
                backgroundColor: Colors.green, // Fond vert pour succès
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Fourpage(email: _emailController.text),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red, // Fond rouge pour erreur
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "example@gmail.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                      final email = _emailController.text;
                      if (email.isNotEmpty) {
                        context.read<AuthCubit>().sendEmail(email);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter an email"), backgroundColor: Colors.orange),
                        );
                      }
                    },
                    child: state is AuthLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text("Create an account", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const Spacer(),
                const Center(
                  child: Text(
                    "By using Let's fishing, you agree to the",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Center(
                  child: Text(
                    "Terms and Privacy Policy",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}