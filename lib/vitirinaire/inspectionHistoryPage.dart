import './dashboardVet.dart';
import './profilevit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './object.dart';
import './batchReportPageV.dart';
import '../HOST.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class InspectionHistoryPage extends StatefulWidget {
  const InspectionHistoryPage({super.key});

  @override
  State<InspectionHistoryPage> createState() => _InspectionHistoryPageState();
}

class _InspectionHistoryPageState extends State<InspectionHistoryPage> {
  final Color primaryTeal = Color(0xFF00A896);
  List<Inspection> _inspections = [];
  bool _isLoading = false;
  String _selectedFilter = "ALL";

  static Future<List<Inspection>> getAllInspections() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse("$HOST/api/inspections/history"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("GET INSPECTIONS STATUS: ${response.statusCode}");
      print("GET INSPECTIONS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return Inspection.fromJsonList(decoded);
        } else if (decoded is Map && decoded.containsKey('data')) {
          return Inspection.fromJsonList(decoded['data']);
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching inspections: $e");
      return [];
    }
  }

  Future<void> _fetchInspections() async {
    setState(() {
      _isLoading = true;
    });
    List<Inspection> inspections = await getAllInspections();
    setState(() {
      _inspections = inspections;
      _isLoading = false;
    });
  }

  List<Inspection> get _filteredInspections => _inspections.where((item) {
    if (_selectedFilter == "ALL") return true;
    return item.decision!.toLowerCase() == _selectedFilter.toLowerCase();
  }).toList();

  @override
  void initState() {
    super.initState();
    _fetchInspections();
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InspectorDashboard()),
              );
            },
            icon: _navIcon(Icons.home_outlined, false),
          ),
          IconButton(
            onPressed: () {
              _fetchInspections();
            },
            icon: _navIcon(Icons.access_time_outlined, true),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilevitPage()),
              );
            },
            icon: _navIcon(Icons.person, false),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? const Color(0xFF00A896) : Colors.grey.shade400,
      size: 28,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: Color(0xFF0F172A),
        ),
        title: Text(
          "Inspection History",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.6,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 3,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["ALL", "APPROVED", "REJECTED"]
                          .map(
                            (filter) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedFilter == filter
                                      ? const Color(0xFF01A896)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: _selectedFilter == filter
                                        ? Colors.white
                                        : const Color(0xFF334155),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  Block(),

                  Text(
                    "RECENT INSPECTIONS",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  Block(),

                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredInspections.length,
                          itemBuilder: (context, index) => InspectionCard(
                            inspection: _filteredInspections[index],
                          ),
                        ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

class InspectionCard extends StatelessWidget {
  final Inspection inspection;

  const InspectionCard({super.key, required this.inspection});

  Color _statusColor() {
    switch (inspection.decision!.toUpperCase()) {
      case "APPROVED":
        return Color(0xFF047857);
      case "REJECTED":
        return Color(0xFFBE123C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: inspection.decision!.toUpperCase() == "APPROVED"
                      ? Color(0xFFD1FAE5)
                      : Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  inspection.decision!.toUpperCase() == "APPROVED"
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: _statusColor(),
                ),
              ),

              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${inspection.batchId}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${inspection.inspectedAt}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: inspection.decision!.toUpperCase() == "APPROVED"
                      ? Color(0xFFD1FAE5)
                      : Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  inspection.decision!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: _statusColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BatchReportPage(
                      batchId: inspection.id!.toInt(),
                      id: inspection.batchId!.toInt(),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.description_outlined, size: 18),
              label: Text("View Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A896),

                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}
