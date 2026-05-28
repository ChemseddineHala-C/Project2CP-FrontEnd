import './batchDetails.dart';
import './myOrderPage.dart';
import './notifieCons.dart';
import './profilconsumer.dart';
import './shoppingCartPage.dart';
import 'package:flutter/material.dart';
//import './batchDetails.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../HOST.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class HomePageC extends StatefulWidget {
  const HomePageC({super.key});

  @override
  State<HomePageC> createState() => _HomePageCState();
}

class _HomePageCState extends State<HomePageC> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  Customer? _customer;
  bool _isLoading = true;

  static Future<Customer?> getCustomerProfile() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print("No token found");
        return null;
      }

      final response = await http.get(
        Uri.parse("http://$HOST:3000/api/batches/market"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Customer.fromJson(decoded);
      } else {
        print("Failed to get customer profile");
        return null;
      }
    } catch (e) {
      print("Error fetching customer profile: $e");
      return null;
    }
  }

  Future<void> _fetchCustomer() async {
    setState(() {
      _isLoading = true;
    });
    Customer? customer = await getCustomerProfile();
    _customer = customer;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomer();
  }

  Widget _buildProfilePhoto() {
    final photoUrl = _customer?.getProfilePhotoUrl();

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFF1F5F9),
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (_, __) {},
      );
    }

    // ✅ حالة عدم وجود صورة
    return const CircleAvatar(
      radius: 22,
      backgroundColor: Color(0xFFF1F5F9),
      child: Icon(Icons.person, color: Color(0xFF023E77)),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {}); // فقط لإعادة بناء الواجهة بعد تغيير النص
  }

  List<CustomerBatch> get _filteredProducts {
    if (_customer?.batches == null) return [];

    final query = _searchController.text.toLowerCase();

    return _customer!.batches!.where((batch) {
      // 1. Check Category Match
      bool matchesCategory =
          _selectedCategory == "All" ||
          (batch.category?.toLowerCase() == _selectedCategory.toLowerCase());

      // 2. Check Search Match (Fish Name or Fisherman Name)
      bool matchesSearch =
          (batch.fishName?.toLowerCase().contains(query) ?? false) ||
          (batch.fishermanName?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      // Implementing the Header as an AppBar to match your style
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            _buildProfilePhoto(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome back,",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  _customer?.fullName ?? "Customer",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontFamily: "Inter",
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationConsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                ),
                const Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const Block(),
                    _buildCategories(),
                    const Block(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle("Fresh Arrivals"),
                        _buildCatchOfTheDayBadge(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildProductGrid(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(false),
    );
  }

  Widget _buildSearchBar() {
    return TextFormField(
      controller: _searchController,
      onChanged: _onSearchChanged, // <--- Add this line
      decoration: InputDecoration(
        hintText: "Search for fresh fish...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        // Optional: Add a clear button when typing
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged("");
                },
              )
            : null,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        fontFamily: "work sanc",
        color: Color(0xFF111618),
      ),
    );
  }

  Widget _buildCategories() {
    final List<Map<String, dynamic>> categories = [
      {"name": "All", "icon": Icons.grid_view_rounded},
      {"name": "Marine Fish", "icon": Icons.tsunami},
      {"name": "Freshwater Fish", "icon": Icons.water},
      {"name": "Molluscs", "icon": Icons.set_meal_outlined},
      {"name": "Crustaceans", "icon": Icons.waves},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Top Categories"),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none, // Allows the selection border to show fully
          child: Row(
            children: categories.map((cat) {
              bool isSelected = _selectedCategory == cat['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat['name'];
                  });
                  // Note: You can call your product filtering logic here
                  // e.g., _filterProductsByCategory(cat['name']);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      // The Icon Box (Beige background, Gold border if selected)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E6D2), // Your beige color
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFFD5A439) // Your gold color
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: const Color(0xFFD5A439),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // The Label (Bold and dark if selected)
                      Text(
                        cat['name'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: "Inter",
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ✅ موجودة وصحيحة
  Widget _buildCatchOfTheDayBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x33D5A439),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "CATCH OF THE DAY",
        style: TextStyle(
          color: Color(0xFFD5A439),
          fontWeight: FontWeight.bold,
          fontSize: 8,
        ),
      ),
    );
  }

  // ✅ التعديل الصحيح
  Widget _buildProductGrid() {
    final productsToShow = _filteredProducts;

    if (productsToShow.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text("No products found in this category."),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: productsToShow.length,
      itemBuilder: (context, index) => _buildProductCard(productsToShow[index]),
    );
  }

  Widget _buildProductCard(CustomerBatch batch) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BatchDetails(id: batch.id!)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: batch.getFirstPhotoUrl().isNotEmpty
                      ? Image.network(
                          batch.getFirstPhotoUrl(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 40);
                          },
                        )
                      : const Icon(
                          Icons.filter_sharp,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch.category ?? "Category",
                    style: const TextStyle(
                      fontFamily: 'work sanc',
                      color: Color(0xFFD5A439),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    batch.fishName ?? "Unknown",
                    style: const TextStyle(
                      fontFamily: 'work sanc',
                      color: Color(0xFF111618),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "By ${batch.fishermanName ?? "Unknown"}",
                    style: const TextStyle(
                      fontFamily: 'work sanc',
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${batch.pricePerKg ?? 0} DA",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD5A439),
                          fontSize: 13,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFD5A439),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            onPressed: () {
              _fetchCustomer();
            },
            icon: Icon(
              Icons.home_outlined,
              color: isDark ? Colors.white54 : Color(0xFFD5A439),
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrdersPage()),
              );
            },
            icon: Icon(
              Icons.list_alt_outlined,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartPage()),
              );
            },
            icon: Icon(
              Icons.shopping_cart,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileConsumerPage()),
              );
            },
            icon: Icon(
              Icons.person,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerBatch {
  final int? id;
  final String? fishName;
  final String? category;
  final double? pricePerKg;
  final String? fishermanName;
  final String? fishermanPhoto;
  final List<String>? photo;

  CustomerBatch({
    this.id,
    this.fishName,
    this.category,
    this.pricePerKg,
    this.fishermanName,
    this.fishermanPhoto,
    this.photo,
  });

  factory CustomerBatch.fromJson(Map<String, dynamic> json) {
    List<String> photoList = [];
    if (json['photo'] != null) {
      if (json['photo'] is List) {
        photoList = List<String>.from(json['photo']);
      } else if (json['photo'] is Map) {
        photoList = (json['photo'] as Map).values
            .map((e) => e.toString())
            .toList();
      } else if (json['photo'] is String) {
        photoList = [json['photo']];
      }
    }

    return CustomerBatch(
      id: json['id'] as int?,
      fishName: json['fish_name'] as String?,
      category: json['category'] as String?,
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      fishermanName: json['fisherman_name'] as String?,
      fishermanPhoto: json['fisherman_photo'] as String?,
      photo: photoList,
    );
  }

  // ✅ دالة للحصول على رابط صورة الصياد
  String getFishermanPhotoUrl() {
    if (fishermanPhoto == null || fishermanPhoto!.isEmpty) return '';
    return "http://$HOST:3000/${fishermanPhoto!.replaceFirst("src/", "")}";
  }

  String getFirstPhotoUrl() {
    if (photo == null || photo!.isEmpty) return '';
    return "http://$HOST:3000/${photo![0].replaceFirst("src/", "")}";
  }
}

class Customer {
  final String? fullName;
  final String? profilePhoto;
  final List<CustomerBatch>? batches;

  Customer({this.fullName, this.profilePhoto, this.batches});

  factory Customer.fromJson(Map<String, dynamic> json) {
    List<CustomerBatch> batchList = [];
    if (json['batches'] != null && json['batches'] is List) {
      batchList = (json['batches'] as List)
          .map((batch) => CustomerBatch.fromJson(batch))
          .toList();
    }

    return Customer(
      fullName: json['customer']['full_name'] as String?,
      profilePhoto: json['customer']['profile_photo'] as String?,
      batches: batchList,
    );
  }

  String getProfilePhotoUrl() {
    if (profilePhoto == null || profilePhoto!.isEmpty) return '';
    return "http://$HOST:3000/${profilePhoto!.replaceFirst("src/", "")}";
  }
}

// Spacing utility re-used from your original files
class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}
