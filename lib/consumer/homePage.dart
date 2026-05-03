import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  // Place this with your other variables (like _isLoading)
  String _selectedCategory = "All";
  bool _isLoading = false;
  List<ProductItem> _mockProducts = [];

  void _onSearchChanged(String value) {
    setState(() {
      // This empty setState triggers the _filteredProducts getter to re-calculate
    });
  }

  List<ProductItem> get _filteredProducts {
    final query = _searchController.text.toLowerCase();

    return _mockProducts.where((product) {
      // 1. Check Category Match
      bool matchesCategory =
          _selectedCategory == "All" ||
              product.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 2. Check Search Match (Fish Name or Fisher Name)
      bool matchesSearch =
          product.name.toLowerCase().contains(query) ||
              product.fisher.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //_buildHeader(),
              //const Block(),
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.waves,
            color: Color(0xFF023E77),
          ), // Placeholder for Logo
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              "Mr. Ahmed",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                fontFamily: "Inter",
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications, color: Colors.black),
            ),
            const Positioned(
              right: 12,
              top: 12,
              child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
            ),
          ],
        ),
      ],
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
    // Data structure matching your "image_47141a.png"
    final List<Map<String, dynamic>> categories = [
      {"name": "All", "icon": Icons.grid_view_rounded},
      {"name": "Marine Fish", "icon": Icons.tsunami},
      {"name": "Freshwater", "icon": Icons.water},
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
                        width: 70,
                        height: 70,
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

  Widget _buildProductGrid() {
    // Use the filtered list here
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

  Widget _buildProductCard(ProductItem item) {
    return Container(
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
                child: Image.asset(item.image, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(
                    fontFamily: 'work sanc',
                    color: Color(0xFFD5A439),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'work sanc',
                    color: Color(0xFF111618),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "By ${item.fisher}",
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
                      "${item.price} DA",
                      style: const TextStyle(
                        fontFamily: '',
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
    );
  }
}

class ProductItem {
  final String name, category, fisher, image;
  final double price;
  ProductItem({
    required this.name,
    required this.category,
    required this.fisher,
    required this.price,
    required this.image,
  });
}

// Spacing utility re-used from your original files
class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}
