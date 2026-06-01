import 'package:flutter/material.dart';
import 'objects.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../HOST.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class BatchDetailspage extends StatefulWidget {
  final FishBatch batch;
  const BatchDetailspage({super.key, required this.batch});
  @override
  State<BatchDetailspage> createState() => _BatchDetailsState();
}

class _BatchDetailsState extends State<BatchDetailspage> {
  bool _isLoading = true;

  Future<void> _delay5Seconds() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _delay5Seconds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0F172A),
        ),
        title: const Text(
          "Batch Details",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.6,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusCard(widget.batch.status ?? 'unknown'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.sailing_outlined,
                        color: Color(0xFF023E77),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Catch Summary",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    //height: 86,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fish name",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.batch.fishName ?? 'Unknown fish',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            decoration:
                                widget.batch.status?.toLowerCase() == "rejected"
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Weight",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.batch.quantityKg != null
                                    ? "${widget.batch.quantityKg!.toStringAsFixed(2)} kg"
                                    : 'N/A',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Value",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.batch.pricePerKg != null &&
                                        widget.batch.quantityKg != null
                                    ? "${(widget.batch.pricePerKg! * widget.batch.quantityKg!).toStringAsFixed(2)} DA"
                                    : 'N/A',
                                style: const TextStyle(
                                  color: Color(0xFF023E77),
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.article_outlined,
                        color: Color(0xFF023E77),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Log Details",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(13),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildLogTile(
                          Icons.calendar_today_outlined,
                          "Date & Time",
                          widget.batch.createdAt != null
                              ? widget.batch.createdAt!
                                    .toString()
                                    .replaceFirst('T', ' ')
                                    .substring(0, 16)
                              : 'Unknown',
                        ),
                        const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                        _buildLogTile(
                          Icons.directions_boat_outlined,
                          "Vessel Name",
                          "Sea's King",
                        ),
                        const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                        _buildLogTile(
                          Icons.anchor_outlined,
                          "Catch Method",
                          widget.batch.catchMethod ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF023E77),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Catch Location",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 192,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            Image.asset(
                              "images/mapLocation.jpg",
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                // decoration: BoxDecoration(

                                //   borderRadius: BorderRadius.circular(6),
                                // ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "COORDINATES",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      "${widget.batch.latitude?.toStringAsFixed(4) ?? 'N/A'}° N, "
                                      "${widget.batch.longitude?.toStringAsFixed(4) ?? 'N/A'}° W",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Color(0xFF023E77),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Catch Photos",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "View All (${widget.batch.photos!.length})",
                        style: const TextStyle(
                          color: Color(0xFF023E77),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.batch.photos?.isNotEmpty == true
                          ? widget.batch.photos!
                                .map(
                                  (path) => Row(
                                    children: [
                                      _buildFishImage(path),
                                      if (widget.batch.photos!.last != path)
                                        const SizedBox(width: 10),
                                    ],
                                  ),
                                )
                                .toList()
                          : [
                              Container(
                                width: 139,
                                height: 127,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'No photos',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                              ),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.batch.status!.compareTo('pending') != 0)
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print(widget.batch.boatId);
                          DownloadCer("${widget.batch.id}", context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF023E77),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_alt_outlined, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Download Report (PDF)",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLogTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.network(
        "$HOST${path.replaceFirst("src", "")}",
        width: 139,
        height: 127,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _statusCard(String status) {
    final normalizedStatus = status.toLowerCase();
    Color bgColor;
    Color textColor;
    Color border;
    IconData icon;

    switch (normalizedStatus) {
      case "approved":
        bgColor = Color(0xFFECFDF5);
        textColor = Color(0xFF065F46);
        icon = Icons.check_circle_outline;
        border = Color(0xFFD1FAE5);
        break;
      case "rejected":
        bgColor = Color(0xFFFFEBEC);
        textColor = Color(0xFFBD3456);
        icon = Icons.cancel_outlined;
        border = Color(0x99FAD6D1);
        break;
      case "pending":
        bgColor = Color(0xFFFEF3C7);
        textColor = Color(0xFFB45309);
        icon = Icons.access_time_outlined;
        border = Color(0xFFF0E6BC);
        break;
      default:
        bgColor = Color(0xFFE3E3E3);
        textColor = Color(0xFF475569);
        icon = Icons.history;
        border = Color(0xFFE1E1E1);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 78,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CURRENT STATUS",
                style: TextStyle(
                  color: textColor,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
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
      Uri.parse(
        "$HOST/api/inspections/batch/$id/certificate",
      ),
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
    // } else if (response.statusCode == 401) {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text("Session expired, please login again"),
    //         backgroundColor: Colors.orange,
    //       ),
    //     );
    //   }
    // } else if (response.statusCode == 404) {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text("Certificate not found for this ID"),
    //         backgroundColor: Colors.orange,
    //       ),
    //     );
    //   }
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
