import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './VetInspectionPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './object.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class PendingBatchesPage extends StatefulWidget {
  const PendingBatchesPage({super.key});

  @override
  State<PendingBatchesPage> createState() => _PendingBatchesPageState();
}

class _PendingBatchesPageState extends State<PendingBatchesPage> {
  List<FishBatchWithFisherman> _batches = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedType = "All Types";
  bool _isLoading = false;

  static Future<List<FishBatchWithFisherman>> getBatchesWithFisherman() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse("http://localhost:3000/api/inspections/pending"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonArray = jsonDecode(response.body);
        return FishBatchWithFisherman.fromJsonList(jsonArray);
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching pending Batch: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  Future<void> _fetchBatches() async {
    setState(() {
      _isLoading = true;
    });
    List<FishBatchWithFisherman> batches = await getBatchesWithFisherman();
    setState(() {
      _batches = batches;
      _isLoading = false;
    });
  }

  // List<FishBatchWithFisherman> get _filteredBatches => _batches.where((batch) {
  //   final matchSearch = batch.id.contains(
  //     _searchQuery,
  //   );
  //   final matchType =
  //       _selectedType == "All Types" || batch.category == _selectedType;
  //   return matchSearch && matchType;
  // }).toList();

  List<FishBatchWithFisherman> get _filteredBatches {
    return _batches.where((batch) {
      final matchSearch = batch.id.toString().contains(_searchQuery);

      final matchType =
          _selectedType == "All Types" || batch.category == _selectedType;
      return matchSearch && matchType;
    }).toList();
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
          "Pending Batches",
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
                  TextFormField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Search Batch ID",
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  Block(),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ["All Types", "Sardin", "Roudji", "Atlantic Salmon"]
                              .map(
                                (type) => GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedType = type),
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedType == type
                                          ? Color(0xFF01A896)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        color: _selectedType == type
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 13,
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
                    "TODAY'S ARRIVALS",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF000000),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Block(),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _filteredBatches.length,
                    itemBuilder: (context, index) =>
                        PendingBatchCard(batch: _filteredBatches[index]),
                  ),
                ],
              ),
            ),
    );
  }
}

class PendingBatchCard extends StatelessWidget {
  final FishBatchWithFisherman batch;

  const PendingBatchCard({super.key, required this.batch});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${batch.id}',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${batch.status}',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4),
          Text(
            '${batch.fishermanName}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "CATEGORY",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${batch.category}",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.set_meal, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "TYPE",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${batch.fishName}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "QUANTITY",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${batch.quantityKg} Kg',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "ARRIVAL",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${batch.createdAt.toString().substring(11, 16)}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => vetInspectionPage(batch: batch,)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Verify Batch"),
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
