import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'firstpage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {

  late AnimationController _waveController;
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Firstpage(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          // ─── Fond dégradé bleu ────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFB8D8E8),
                  Color(0xFF5BA3C4),
                  Color(0xFF3D8BAD),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ─── Vagues animées ───────────────────────
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildWave(size: size, offset: _waveController.value,
                      color: Colors.white.withOpacity(0.08),
                      amplitude: 30, speed: 1.0, verticalPosition: 0.15),
                  _buildWave(size: size, offset: _waveController.value,
                      color: Colors.white.withOpacity(0.07),
                      amplitude: 25, speed: 1.3, verticalPosition: 0.28),
                  _buildWave(size: size, offset: _waveController.value,
                      color: Colors.white.withOpacity(0.08),
                      amplitude: 20, speed: 0.8, verticalPosition: 0.42),
                  _buildWave(size: size, offset: _waveController.value,
                      color: Colors.white.withOpacity(0.07),
                      amplitude: 28, speed: 1.1, verticalPosition: 0.55),
                  _buildWave(size: size, offset: _waveController.value,
                      color: Colors.white.withOpacity(0.06),
                      amplitude: 22, speed: 0.9, verticalPosition: 0.68),
                  _buildWave(size: size, offset: _waveController.value,
                      color: Colors.white.withOpacity(0.08),
                      amplitude: 18, speed: 1.2, verticalPosition: 0.80),
                  _buildWave(size: size, offset: _waveController.value,
                      color: Colors.white.withOpacity(0.06),
                      amplitude: 24, speed: 0.7, verticalPosition: 0.92),
                ],
              );
            },
          ),

          // ─── Logo PNG au centre ───────────────────
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                );
              },

              // ✅ CORRECTION — Image.asset pour PNG
              child: Image.asset(
                'images/Bahr.png',
                width: 280,
                // ↑ ajuste selon la taille souhaitée
                fit: BoxFit.contain,
                // ↑ garde les proportions du logo
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWave({
    required Size size,
    required double offset,
    required Color color,
    required double amplitude,
    required double speed,
    required double verticalPosition,
  }) {
    return Positioned(
      top: size.height * verticalPosition - amplitude,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: Size(size.width, amplitude * 2.5),
        painter: _WavePainter(
          offset: offset * speed,
          color: color,
          amplitude: amplitude,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double offset;
  final Color color;
  final double amplitude;

  _WavePainter({
    required this.offset,
    required this.color,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, amplitude);

    for (double x = 0; x <= size.width; x++) {
      final y = amplitude +
          amplitude *
              math.sin((x / size.width * 2 * math.pi) +
                  (offset * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.offset != offset;
}