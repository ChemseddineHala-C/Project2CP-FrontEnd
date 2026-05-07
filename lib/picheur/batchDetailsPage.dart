import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'objects.dart';

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
  bool _isLoading = false;
  FishBatch? _batch;

  Future<FishBatch?> getBatchById() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse("http://localhost:3000/api/batches/${widget.batch.id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        return FishBatch.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching batch: $e");
      return null;
    }
  }

  Future<void> _fetchBatch() async {
    setState(() {
      _isLoading = true;
    });
    FishBatch? batch = await getBatchById();
    setState(() {
      _batch = batch;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBatch();
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
                  _statusCard(widget.batch.status!),
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
                    height: 86,
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
                          widget.batch.fishName!,
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            decoration: widget.batch.status == "Rejected"
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
                                "${widget.batch.quantityKg!} kg", // Corrigé : quantity au lieu de weight
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
                                "${widget.batch.pricePerKg! * widget.batch.quantityKg!} DA", // Corrigé : total au lieu de price
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
                          widget.batch.createdAt
                              .toString()
                              .replaceFirst('T', ' ')
                              .substring(0, 16),
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
                          widget.batch.catchMethod ?? "Longline",
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
                      children: widget.batch.photos!
                          .map(
                            (path) => Row(
                              children: [
                                _buildFishImage(path),
                                if (widget.batch.photos!.last != path)
                                  const SizedBox(width: 10),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.history, color: Color(0xFF023E77)),
                      const SizedBox(width: 5),
                      const Text(
                        "Status History",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Version manuelle de la timeline (pour éviter l'erreur de package)
                  // Column(
                  //   children: List.generate(
                  //     events.length,
                  //         (index) => _buildTimelineTile(index),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
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
                            "Download Receipt (PDF)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        "http://localhost:3000/${path.replaceFirst("src", "")}" ?? "",
        width: 139,
        height: 127,
        fit: BoxFit.cover,
      ),
    );
  }

  //   Widget _buildTimelineTile(int index) {
  //     return Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Column(
  //           children: [
  //             Container(
  //               width: 16,
  //               height: 16,
  //               decoration: BoxDecoration(
  //                 color: index == 0
  //                     ? const Color(0xFF023E77)
  //                     : const Color(0xFFC4D3E0),
  //                 shape: BoxShape.circle,
  //                 border: Border.all(color: Colors.white, width: 3),
  //               ),
  //             ),
  //             if (index != events.length - 1)
  //               Container(width: 2, height: 50, color: const Color(0xFF023E77)),
  //           ],
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 events[index]["title"]!,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               Text(
  //                 events[index]["subtitle"]!,
  //                 style: const TextStyle(color: Colors.grey, fontSize: 14),
  //               ),
  //               const SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  // }

  Widget _statusCard(String status) {
    Color bgColor;
    Color textColor;
    Color border;
    IconData icon;

    switch (status) {
      case "Approved":
        bgColor = Color(0xFFECFDF5);
        textColor = Color(0xFF065F46);
        icon = Icons.check_circle_outline;
        border = Color(0xFFD1FAE5);
        break;
      case "Rejected":
        bgColor = Color(0xFFFFEBEC);
        textColor = Color(0xFFBD3456);
        icon = Icons.cancel_outlined;
        border = Color(0x99FAD6D1);
        break;
      case "Pending":
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
