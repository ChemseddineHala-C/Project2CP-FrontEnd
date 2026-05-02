import 'package:checkmark/checkmark.dart';
import 'package:fishapp/signin/signup/selectrole.dart';
import 'package:flutter/material.dart';
class Sixpage extends StatefulWidget {
  final String email;
  const Sixpage({super.key, required this.email});

  @override
  State<Sixpage> createState() => _SixpageState();
}

class _SixpageState extends State<Sixpage> {
  bool _checked = false; // 1. Déclarer la variable

  @override
  void initState() {
    super.initState();
    // Lancer l'animation après un petit délai=500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _checked = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrer le contenu verticalement
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: CheckMark(
                active: _checked,
                curve: Curves.decelerate,
                duration: const Duration(milliseconds: 800),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your account",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              "was successfully created!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text("Only one click to explore the fish's world"),
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              height: 50,
              child: MaterialButton(
                color: const Color(0xFF013D73),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => RoleSelectionPage(email: widget.email)),
                  );
                },
                child: const Text(
                  "Log-in",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "By using Let's fishing, you agree to the",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Terms and Privacy Policy",
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}