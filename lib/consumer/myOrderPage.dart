import 'package:flutter/material.dart';


class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  // --- BACKEND HANDLING VARIABLES ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  bool _isLoading = false;
  List<OrderItem> _orders = [];

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  void initState() {
    super.initState();
  }


  List<OrderItem> get _filteredOrders {
    return _orders.where((order) {
      // Check if the name contains the search text
      bool matchesSearch = order.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Check if the status matches the selected chip
      bool matchesFilter = _selectedFilter == "All" ||
          order.status == _selectedFilter.toUpperCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
        ),
        title: const Text(
          "My Orders",
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
        shadowColor: Colors.black,
        elevation: 3,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar - Styled like your myBatches.dart
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
            // Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  "All",
                  "Delivered",
                  "Pending",
                  "Processing",
                ].map((filter) => _buildFilterChip(filter)).toList(),
              ),
            ),
            const Block(),
            if (_filteredOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No Orderss found for that name.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                ),
              )
            else
            // Orders List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) =>
                    OrderCard(order: _filteredOrders[index]),
              ),
            // Skeleton loader placeholder (as seen in your image)
            //const OrderSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    bool isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD5A439)
              : Colors.white, // Golden color from image
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filter,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderItem order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[100],
                  child: Image.asset(
                    order.images.isNotEmpty
                        ? order.images[0]
                        : "images/grey.jpg",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ), // Placeholder for Image.asset
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "• ${order.date}",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _actionButton(order.status),
                  ],
                ),
              ),
              // Status & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusChip(order.status),
                  const SizedBox(height: 16),
                  Text(
                    "${order.weight} kg",
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "${order.totalPrice} DA",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD5A439),
                      fontSize: 16,
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

  Widget _statusChip(String status) {
    Color color, bgColor;
    switch (status) {
      case "DELIVERED":
        color = const Color(0xFF047857);
        bgColor = const Color(0xFFD1FAE5);
        break;
      case "PENDING":
        color = const Color(0xFFB45309);
        bgColor = const Color(0xFFFEF3C7);
        break;
      case "PROCESSING":
        color = const Color(0xFF094BB4);
        bgColor = const Color(0xFFC7DCFE);
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionButton(String status) {
    String label = status == "DELIVERED"
        ? "Reorder"
        : (status == "PENDING" ? "Cancel" : "Track Order");
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
    );
  }
}

// Visual Rhythm: Re-using your Block widget
class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}

// Placeholder for the bottom card in your image
class OrderSkeleton extends StatelessWidget {
  const OrderSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 12, color: Colors.grey[200]),
                const SizedBox(height: 8),
                Container(width: 150, height: 12, color: Colors.grey[200]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderItem {
  final String name, date, status;
  final List<String> images;
  final double weight, totalPrice;
  OrderItem({
    required this.name,
    required this.date,
    required this.status,
    required this.weight,
    required this.totalPrice,
    required this.images,
  });
}
