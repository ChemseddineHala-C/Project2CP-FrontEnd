import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../HOST.dart';


final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class Adminvitinfo extends StatefulWidget {
  final String id;
  const Adminvitinfo({super.key, required this.id});

  @override
  State<Adminvitinfo> createState() => _AdminvitinfoState();
}

class _AdminvitinfoState extends State<Adminvitinfo> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchAdminvet(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "User Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF011A33),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF01A896)),
            );
          }

          if (state is AdminLoaded) {
            final user = state.user;
            final documents = (user["documents"] is List)
                ? List.from(user["documents"])
                : <dynamic>[];

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AuthCubit>().fetchAdminvet(widget.id),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(user, isDark),
                    const SizedBox(height: 24),
                    _buildSection(
                      isDark: isDark,
                      number: "1",
                      title: "Personal Information",
                      children: [
                        _label("Full Name", isDark),
                        _readOnlyField(
                          safeText(user["full_name"], "Dr Ahmed"),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _label("National ID / Passport", isDark),
                        _readOnlyField(
                          safeText(user["national_id"], "10002651"),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _label("Phone Number", isDark),
                        _readOnlyField(
                          safeText(user["phone_number"], "+213 674854088"),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _label("Email Address", isDark),
                        _readOnlyField(
                          safeText(user["email"], "Projet@esi-sba.dz"),
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      number: "2",
                      title: "Licenses & Documents",
                      children: [
                        _label("Specialization", isDark),
                        _readOnlyField(
                          safeText(user["specialization"], "Aquatic Pathology"),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _label("Primary License #", isDark),
                        _readOnlyField(
                          safeText(user["license_number"], "LIC-00-1122"),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _label("Expiry Date", isDark),
                        _readOnlyField(
                          safeDate(user["license_expiry_date"], "17-09-2026"),
                          isDark,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Required Uploads (PDF or JPG)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDownloadTile(
                          Icons.description,
                          "License",
                          extractDocumentUrl(documents, 0),
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildDownloadTile(
                          Icons.badge_outlined,
                          "ID Card",
                          extractDocumentUrl(documents, 1),
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (user["account_status"]?.toString() == "pending")
                      _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Text(
              "No Data",
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user, bool isDark) {
    Color cover = user["account_status"] == "approved" ? Color(0xFFD1FAE5): user["account_status"] == "rejected"? Color(0xFFFEE2E2):user["account_status"] == "pending"? Color(0xFFFEF3C7):Color(0xFFE3E3E3) ;
    Color word = user["account_status"] == "approved" ? Color(0xFF047857): user["account_status"] == "rejected"? Color(0xFFBA1A1A):user["account_status"] == "pending"? Color(0xFFB45309):Color(0xFF475569) ;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 65,
              height: 65,
              color: Colors.grey[200],
              child: user["profile_photo"] != null
                  ? Image.network(
                      'http://$HOST:3000' +
                          user["profile_photo"].toString().replaceFirst(
                            'src',
                            '',
                          ),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person, size: 35, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["full_name"] ?? "Dr, Elias Khaled",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Vet ID: ${user["id"] ?? "#F-9281"}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              safeText(user["account_status"], 'Unknown'),
              style: TextStyle(
                color: word,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String number,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFF01A896),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : const Color(0xFF475569),
      ),
    ),
  );

  Widget _readOnlyField(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  String safeText(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String safeDate(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString();
    if (text.length >= 10) return text.substring(0, 10);
    return fallback;
  }

  String? extractDocumentUrl(List<dynamic> documents, int index) {
    if (documents.length <= index) return null;
    final item = documents[index];
    if (item is! Map) return null;
    final fp = item['file_path'];
    if (fp == null) return null;
    return 'http://$HOST:3000' + fp.toString().replaceFirst('src', '');
  }

  Widget _buildDownloadTile(
    IconData icon,
    String title,
    String? filename,
    bool isDark,
  ) {
    final label = (filename != null && filename.isNotEmpty)
        ? filename.split('/')[5]
        : 'No file available';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF01A896).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF01A896), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: (filename != null && filename.isNotEmpty)
                ? () => openFile(context, filename)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2F1),
              foregroundColor: const Color(0xFF01A896),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "see",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              statusAccount(widget.id, context, "reject");
              setState(() {});
            },
            icon: const Icon(Icons.block, color: Colors.white, size: 20),
            label: const Text(
              "Reject",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              statusAccount(widget.id, context, "approve");
              setState(() {});
            },
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              "Approve",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void openFile(BuildContext context, String url) {
    print(url);
    final isPdf = url.toLowerCase().endsWith('.pdf');
    final isImage =
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png');

    if (isPdf) {
      // Call the async function properly
      _showPdfViewer(context, url);
    } else if (isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Image'),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            body: InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      );
    } else {
      // Show error dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type of file is not supported')),
      );
    }
  }

  void _showPdfViewer(BuildContext context, String url) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final token    = await _getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(response.bodyBytes, flush: true);

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 217, 208, 208),
                title: const Text('Document'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: PDFView(
                filePath: file.path,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('PDF error: $e');
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void statusAccount(String id, BuildContext context, String action) async {
    try {
      String? token = await _getToken();
      if (token == null) {
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

      final response = await http.put(
        Uri.parse("http://$HOST:3000/api/veterinarians/$id/$action"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OK"), backgroundColor: Colors.green),
          );
        }
        return;
      }
    } catch (e) {
      print("$e");
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
}
