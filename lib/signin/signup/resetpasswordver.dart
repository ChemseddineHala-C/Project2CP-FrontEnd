import 'package:flutter/material.dart';

class ResetPasswordSentPage extends StatelessWidget {
  final String email; // ← reçoit l'email depuis ForgotPasswordPage

  const ResetPasswordSentPage({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Reset password",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 60),

            // ─── Icône enveloppe + cadenas ────────────
            _buildEnvelopeIcon(),

            const SizedBox(height: 48),

            // ─── Texte message ────────────────────────
            _buildMessage(),

            const SizedBox(height: 40),

            // ─── Bouton Back to login ─────────────────
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  // ─── Widget Enveloppe avec cadenas ───────────────────
  Widget _buildEnvelopeIcon() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [

            // ─── Enveloppe (fond violet clair) ────────
            CustomPaint(
              size: const Size(160, 120),
              painter: _EnvelopePainter(),
            ),

            // ─── Cadenas au centre ─────────────────────
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF013D73),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Texte du message ────────────────────────────────
  Widget _buildMessage() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
          height: 1.6,
        ),
        children: [
          const TextSpan(text: "We have sent an email\nto "),
          // Email en gras
          TextSpan(
            text: email,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const TextSpan(
            text: " with\ninstructions to reset your password.",
          ),
        ],
      ),
    );
  }

  // ─── Bouton Back to login ────────────────────────────
  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => const LoginPage()),
          //   );
          // Retourne à LoginPage en supprimant toutes les pages
          // Navigator.popUntil(context, (route) => route.isFirst);

          // ↑ ou Navigator.pop(context) si tu veux juste revenir en arrière
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF013D73),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Back to login",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─── Painter pour dessiner l'enveloppe ──────────────────
class _EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E0FF) // ← violet très clair
      ..style = PaintingStyle.fill;

    // Corps de l'enveloppe (rectangle arrondi)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.25, size.width, size.height * 0.75),
      const Radius.circular(12),
    );
    canvas.drawRRect(bodyRect, paint);

    // Rabat de l'enveloppe (triangle en haut)
    final flapPath = Path();
    flapPath.moveTo(0, size.height * 0.25);            // coin gauche
    flapPath.lineTo(size.width / 2, size.height * 0.6); // pointe bas
    flapPath.lineTo(size.width, size.height * 0.25);   // coin droit
    flapPath.close();
    canvas.drawPath(flapPath, paint);

    // Haut de l'enveloppe (triangle inversé = ouverture)
    final topPath = Path();
    topPath.moveTo(0, 0);                              // coin haut gauche
    topPath.lineTo(size.width / 2, size.height * 0.35); // pointe bas
    topPath.lineTo(size.width, 0);                     // coin haut droit
    topPath.close();

    final topPaint = Paint()
      ..color = const Color(0xFFD4C8F5) // ← violet légèrement plus foncé
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);
  }

  @override
  bool shouldRepaint(_EnvelopePainter oldDelegate) => false;
}