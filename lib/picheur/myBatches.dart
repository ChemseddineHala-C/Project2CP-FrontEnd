import './profil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './objects.dart';
import 'Weather&Safety.dart';
import 'addBatchPage.dart';
import 'batchDetailsPage.dart';
import 'homepage.dart';
import '../HOST.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class MyBatchesPage extends StatefulWidget {
  const MyBatchesPage({super.key});

  @override
  State<MyBatchesPage> createState() => _MyBatchesPageState();
}

class _MyBatchesPageState extends State<MyBatchesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  bool _isLoading = false;
  List<FishBatch> _batches = [];

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  static Future<List<FishBatch>> getBatches() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse("http://$HOST:3000/api/batches/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        List<dynamic> jsonArray = jsonDecode(response.body);
        return FishBatch.fromJsonList(jsonArray);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchBatches() async {
    setState(() {
      _isLoading = true;
    });
    List<FishBatch> batches = await getBatches();
    setState(() {
      _batches = batches;
      _isLoading = false;
    });
  }

  List<FishBatch> get _filteredBatches => _batches.where((batch) {
    return _matchesFilter(batch) && _matchesSearch(batch);
  }).toList();

  bool _matchesFilter(FishBatch batch) {
    final status = batch.status?.toLowerCase() ?? '';
    return _selectedFilter == "All" || status == _selectedFilter.toLowerCase();
  }

  bool _matchesSearch(FishBatch batch) {
    if (_searchQuery.isEmpty) return true;
    return (batch.fishName ?? '').toLowerCase().contains(
      _searchQuery.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back),
          color: Color(0xFF0F172A),
        ),
        title: Text(
          "My Batches",
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Material(
              color: const Color(0x1A0F68E6),
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Addbatchpage()),
                  );
                },
                borderRadius: BorderRadius.circular(50),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: Color(0xFF023E77)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchController,
                    onChanged: _updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: "Search batches...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const Block(),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ["All", "Pending", "Approved", "Rejected", "Expired"]
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
                                          ? const Color(0xFF023E77)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      filter,
                                      style: TextStyle(
                                        color: _selectedFilter == filter
                                            ? Colors.white
                                            : const Color(0xFF475569),
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
                  const Block(),
                  if (_filteredBatches.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No batches found for that name.',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredBatches.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BatchDetailspage(
                                batch: _filteredBatches[index],
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: BatchCard(_filteredBatches[index]),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePageP()),
            ),
            icon: _navIcon(Icons.home, false),
          ),
          IconButton(
            onPressed: () {
              _fetchBatches();
            }, // Déjà sur cette page
            icon: _navIcon(Icons.anchor, true),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeatherSafetypage()),
              );
            },
            icon: _navIcon(Icons.remove_red_eye, false),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
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
      color: isActive ? const Color(0xFF023E77) : Colors.grey,
      size: isActive ? 30 : 24,
    );
  }
}

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 20);
  }
}

Widget BatchCard(FishBatch batch) {
  Color bgColor;
  Color textColor;

  final status = batch.status?.toLowerCase() ?? 'unknown';
  switch (status) {
    case "approved":
      bgColor = Color(0xFFECFDF5);
      textColor = Color(0xFF065F46);

      break;
    case "rejected":
      bgColor = Color(0xFFFFEBEC);
      textColor = Color(0xFFBD3456);

      break;
    case "pending":
      bgColor = Color(0xFFFEF3C7);
      textColor = Color(0xFFB45309);

      break;
    default:
      bgColor = Color(0xFFE3E3E3);
      textColor = Color(0xFF475569);
  }

  final imageUrl = batch.photos?.isNotEmpty == true
      ? batch.photos![0].replaceFirst("src", "")
      : null;
  final fishName = batch.fishName ?? 'Unnamed batch';
  final quantityText = batch.quantityKg != null
      ? "${batch.quantityKg!.toStringAsFixed(2)} kg"
      : 'N/A';
  final dateText = batch.dateCaught != null
      ? batch.dateCaught!
            .toIso8601String()
            .replaceFirst('T', ' ')
            .substring(0, 16)
      : 'Unknown date';
  final unitPriceText = batch.pricePerKg != null
      ? "${batch.pricePerKg!.toStringAsFixed(2)} DA/kg"
      : 'N/A';
  final totalPriceText = batch.pricePerKg != null && batch.quantityKg != null
      ? "${(batch.pricePerKg! * batch.quantityKg!).toStringAsFixed(2)} DA"
      : 'N/A';

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? Image.network(
                      "http://$HOST:3000$imageUrl",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "images/grey.jpg",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      "images/grey.jpg",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fishName,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$quantityText\n$dateText",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                batch.status!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              unitPriceText,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                Text(
                  totalPriceText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF023E77),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
