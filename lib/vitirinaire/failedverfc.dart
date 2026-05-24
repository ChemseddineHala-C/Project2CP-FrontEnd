import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import './object.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../vitirinaire/PendingBatchesPage.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class FailedvetPage extends StatefulWidget {
  final FishBatchWithFisherman batch;
  final String op1;
  final String op2;
  final String op3;
  final String op4;
  final double op5;
  final bool op6;
  final int op7;

  const FailedvetPage({
    super.key,
    required this.batch,
    required this.op1,
    required this.op2,
    required this.op3,
    required this.op4,
    required this.op5,
    required this.op6,
    required this.op7,
  });

  @override
  State<FailedvetPage> createState() => _FailedvetPageState();
}

class _FailedvetPageState extends State<FailedvetPage> {
  final TextEditingController _rejectionController = TextEditingController();
  bool _isLoading = false;

  Future<void> submitInspection({
    required int batchId,
    required String? smell,
    required String? gillColor,
    required String? fleshFirmness,
    required String? eyeClarity,
    required double internalTemperature,
    required bool parasitesPresent,
    required int freshnessScore,
    required String notes,
    required String decision,
    required BuildContext context,
  }) async {
    try {

      String? token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No token found. Please login again."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("http://192.168.1.94:3000/api/inspections/${batchId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "batch_id": batchId,
          "smell": smell,
          "gill_color": gillColor,
          "flesh_firmness": fleshFirmness,
          "eye_clarity": eyeClarity,
          "internal_temperature": internalTemperature,
          "parasites_present": parasitesPresent,
          "freshness_score": freshnessScore,
          "notes": notes,
          "decision": decision,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inspection submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        //return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
        //return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PendingBatchesPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      return;
    }
  }

  Future<void> _submitBatches() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await submitInspection(
        batchId: widget.batch.id!,
        smell: widget.op1,
        gillColor: widget.op2,
        fleshFirmness: widget.op3,
        eyeClarity: widget.op4,
        internalTemperature: widget.op5,
        parasitesPresent: widget.op6,
        freshnessScore: widget.op7,
        notes: _rejectionController.text,
        decision: 'rejected',
        context: context,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _rejectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF011A33),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Vet Inspection",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF011A33),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Batch Identity", isDark),
                  const SizedBox(height: 12),
                  _buildIdentityCard(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Notes", isDark),
                  const SizedBox(height: 12),
                  _buildRejectionInputCard(
                    isDark,
                  ), //pour cause de fefutation de envoyer id de pecheur et le text
                  const SizedBox(height: 24),
                  _buildActionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    title: "Digital certificate",
                    subtitle: "PDF format",
                    actionIcon: Icons.download_outlined,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.remove_red_eye_outlined,
                    title: "View Batch Report",
                    subtitle: "",
                    actionIcon: Icons.open_in_new_outlined,
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        // Couleur de fond adaptée au mode sombre
        color: isDark ? const Color(0xFF422222) : const Color(0xFFFBABAB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white10
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.block,
              color: isDark ? const Color(0xFFFF5252) : const Color(0xFFE53935),
              size: 45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "REJECTED",
            style: TextStyle(
              color: isDark ? const Color(0xFFFF5252) : const Color(0xFFE53935),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "PROTOCOL VERIFICATION FAILED",
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFFE53935),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF011A33),
        ),
      ),
    );
  }

  Widget _buildIdentityCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildIdentityItem("BATCH ID", '${widget.batch.id}', isDark),
          const Divider(height: 32),
          _buildIdentityItem(
            "FISHER NAME",
            '${widget.batch.fishermanName}',
            isDark,
          ),
          const Divider(height: 32),
          _buildIdentityItem("FISH TYPE", '${widget.batch.fishName}', isDark),
        ],
      ),
    );
  }

  Widget _buildIdentityItem(String label, String value, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF011A33),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRejectionInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).cardColor, // Utilisation de cardColor pour la cohérence
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _rejectionController,
            maxLines: 4,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Add any informations related to inspection..",
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey,
              ),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _submitBatches();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFFE53935,
              ), // Rouge pour l'action de rejet
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Send Rejection",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    String? subtitle,
    required IconData actionIcon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFE53935)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark
                          ? Colors.white
                          : Colors.black, // Correction ici
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(actionIcon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
