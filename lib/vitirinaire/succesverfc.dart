import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import './object.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './batchReportPageV.dart';
import '../HOST.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import './PendingBatchesPage.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class SuccessedVetPage extends StatefulWidget {
  final FishBatchWithFisherman batch;
  final String op1;
  final String op2;
  final String op3;
  final String op4;
  final double op5;
  final bool op6;
  final int op7;

  const SuccessedVetPage({
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
  State<SuccessedVetPage> createState() => _VetInspectionPageState();
}

class _VetInspectionPageState extends State<SuccessedVetPage> {
  bool _isLoading = false;
  final TextEditingController _approvedController = TextEditingController();
  int? inspectId;

  Future<void> updateNote(String note, int id) async {
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

      final response = await http.put(
        Uri.parse("$HOST/api/inspections/$id/note"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"notes": note}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("message: ${jsonDecode(response.body)['message']}"),
            backgroundColor: Colors.green,
          ),
        );
        //return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("message: ${jsonDecode(response.body)['message']}"),
            backgroundColor: Colors.red,
          ),
        );
        //return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      return;
    }
  }

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
        Uri.parse("$HOST/api/inspections/${batchId}"),
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
          "notes": "",
          "decision": decision,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          inspectId = jsonDecode(response.body)['inspection_id'] as int;
        });
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
            content: Text("message: ${jsonDecode(response.body)['message']}"),
            backgroundColor: Colors.red,
          ),
        );
        //return;
      }
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
    submitInspection(
      batchId: widget.batch.id!,
      smell: widget.op1,
      gillColor: widget.op2,
      fleshFirmness: widget.op3,
      eyeClarity: widget.op4,
      internalTemperature: widget.op5,
      parasitesPresent: widget.op6,
      freshnessScore: widget.op7,
      notes: "",
      decision: 'approved',
      context: context,
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateNote(String note, int id) async {
    updateNote(note, id);
    setState(() {
      _approvedController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _submitBatches();
  }

  @override
  void dispose() {
    _approvedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Utilisation de la couleur de fond du thème
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // Utilisation des couleurs du thème pour l'AppBar
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PendingBatchesPage()),
            );
          },
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
                  _buildApprovedInputCard(
                    isDark,
                  ), //pour cause de fefutation de envoyer id de pecheur et le text
                  const SizedBox(height: 24),
                  _buildSectionTitle("Expiration Date", isDark),
                  const SizedBox(height: 12),
                  _buildExpirationCard("expiryDate", "timeLeft", isDark),
                  const SizedBox(height: 24),
                  _buildActionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    title: "Digital certificate",
                    subtitle: "PDF format",
                    actionIcon: Icons.download_outlined,
                    onTap: () => {DownloadCer("$inspectId", context)},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.remove_red_eye_outlined,
                    title: "View Batch Report",
                    subtitle: "",
                    actionIcon: Icons.open_in_new_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BatchReportPage(
                            batchId: widget.batch.id!,
                            id: inspectId!,
                          ),
                        ),
                      );
                    },
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
        // On garde l'aspect vert même en dark mode mais on l'adapte
        color: isDark ? const Color(0xFF004D40) : const Color(0xFF98E2C6),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF006F63),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "APPROVED",
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF006F63),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "PROTOCOL VERIFICATION PASSED",
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF006F63),
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF011A33),
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

  Widget _buildExpirationCard(String date, String timeLeft, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Color(0xFF00C2A0)),
          const SizedBox(width: 16),
          Text(
            date,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "($timeLeft)",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Spacer(),
          const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildApprovedInputCard(bool isDark) {
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
            controller: _approvedController,
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
              _updateNote(_approvedController.text,inspectId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF006F63,
              ), // Rouge pour l'action de rejet
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Send Approval",
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
      onTap: onTap,
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
              child: Icon(icon, color: const Color(0xFF00C2A0)),
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
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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

Future<void> DownloadCer(String id, BuildContext context) async {
  try {
    // 1. Check for token
    String? token = await _getToken();
    if (token == null) {
      print("No token found");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No token found, please login again"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 2. Request storage permission (for Android)
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ لا يحتاج permission للـ Downloads folder
      } else if (sdkInt >= 30) {
        // Android 11 و 12
        PermissionStatus status = await Permission.manageExternalStorage
            .request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please grant storage permission"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      } else {
        // Android 10 وما دون
        PermissionStatus status = await Permission.storage.request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please grant storage permission"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }
    }

    // 3. Show loading message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text("Downloading certificate..."),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
    // 4. Send request to server
    final response = await http.get(
      Uri.parse("$HOST/api/inspections/$id/certificate"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("DOWNLOAD STATUS: ${response.statusCode}");

    // 5. Handle response
    if (response.statusCode == 200) {
      // Get the correct downloads folder path
      String? downloadsPath;

      if (Platform.isAndroid) {
        // Correct way to get Download folder path on Android
        downloadsPath = '/storage/emulated/0/Download';

        // Check if folder exists, create if not
        final downloadDir = Directory(downloadsPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      }

      // Create filename with timestamp to avoid duplication
      String fileName =
          "certificate_${id}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      String filePath = "$downloadsPath/$fileName";

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Check file size to ensure it was saved correctly
      int fileSize = await file.length();
      print("File saved: $filePath, Size: $fileSize bytes");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Certificate downloaded successfully"),
                Text(
                  "Saved to: Download/$fileName",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      print("File saved successfully to: $filePath");
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("message: ${jsonDecode(response.body)['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print("Error in DownloadCer: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
