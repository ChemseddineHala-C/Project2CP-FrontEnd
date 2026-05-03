import 'package:fishapp/picheur/profil.dart';
import 'package:flutter/material.dart';
import 'Weather&Safety.dart';
import 'addBatchPage.dart';
import 'batchDetailsPage.dart';
import 'homepage.dart';
import 'objects.dart';

class MyBatchesPage extends StatefulWidget {
  const MyBatchesPage({super.key});

  @override
  State<MyBatchesPage> createState() => _MyBatchesPageState();
}

class _MyBatchesPageState extends State<MyBatchesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  bool _isLoading = true;
  List<BatchItem> _batches = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  void _loadBatches() {
    setState(() {
      _isLoading = false;
    });
  }

  List<BatchItem> get _filteredBatches => _batches.where((batch) {
    return _matchesFilter(batch) && _matchesSearch(batch);
  }).toList();

  bool _matchesFilter(BatchItem batch) {
    return _selectedFilter == "All" ||
        batch.status.toLowerCase() == _selectedFilter.toLowerCase();
  }

  bool _matchesSearch(BatchItem batch) {
    if (_searchQuery.isEmpty) return true;
    return batch.fishName.toLowerCase().contains(_searchQuery.toLowerCase());
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
                    MaterialPageRoute(
                      builder: (context) => Addbatchpage(),
                    ),
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
              MaterialPageRoute(builder: (_) => HomePage()),
            ),
            icon: _navIcon(Icons.home, false),
          ),
          IconButton(
            onPressed: () {}, // Déjà sur cette page
            icon: _navIcon(Icons.anchor, true),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherSafetypage(),
                ),
              );
            },
            icon: _navIcon(Icons.remove_red_eye, false),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
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

// class BatchItem {
//   final String fishName;
//   final double quantity;
//   final String date;
//   final double pricePerKg;
//   final double total;
//   final String status;
//   final String? imageUrl;

//   BatchItem({
//     required this.fishName,
//     required this.quantity,
//     required this.date,
//     required this.pricePerKg,
//     required this.total,
//     required this.status,
//     this.imageUrl,
//   });
// }

Widget BatchCard(BatchItem batch) {
  Color bgColor;
  Color textColor;

  switch (batch.status) {
    case "Approved":
      bgColor = Color(0xFFECFDF5);
      textColor = Color(0xFF065F46);

      break;
    case "Rejected":
      bgColor = Color(0xFFFFEBEC);
      textColor = Color(0xFFBD3456);

      break;
    case "Pending":
      bgColor = Color(0xFFFEF3C7);
      textColor = Color(0xFFB45309);

      break;
    default:
      bgColor = Color(0xFFE3E3E3);
      textColor = Color(0xFF475569);
  }

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
              child: Image.asset(
                batch.pictures.isNotEmpty
                    ? batch.pictures[0]
                    : "images/grey.jpg",
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
                    batch.fishName,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${batch.quantity} kg\n${batch.date}",
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
                batch.status,
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
              "${batch.pricePerKg} DA/kg",
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
                  "${batch.total} DA",
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
