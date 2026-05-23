import 'package:fishapp/consumer/homePage.dart';
import 'package:fishapp/consumer/profilconsumer.dart';
import 'package:fishapp/consumer/shoppingCartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FlutterSecureStorage storage = const FlutterSecureStorage();

Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

// ==================== MODELS ====================

class OrderItem {
  final int? id;
  final int? batchId;
  final double? quantityKg;
  final double? unitPrice;
  final double? subtotal;
  final String? fishName;
  final String? category;
  final List<String>? photo;

  OrderItem({
    this.id,
    this.batchId,
    this.quantityKg,
    this.unitPrice,
    this.subtotal,
    this.photo,
    this.fishName,
    this.category,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    List<String> photoList = [];
    if (json['photo'] != null) {
      if (json['photo'] is List) {
        photoList = List<String>.from(json['photo']);
        print("it's list");
      } else if (json['photo'] is String) {
        photoList = [json['photo']];
        print("it's string");
      }
    }

    return OrderItem(
      id: json['id'] as int?,
      batchId: json['batch_id'] as int?,
      quantityKg: (json['quantity_kg'] as num?)?.toDouble(),
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      fishName: json['fish_name'] as String?,
      category: json['category'] as String?,
      photo: photoList,
    );
  }

  String getFirstPhotoUrl() {
    if (photo == null || photo!.isEmpty) return '';

    String rawPath = photo![0];
    String cleanPath = rawPath
        .replaceAll('"', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(",")[0]
        .replaceFirst('src', '');

    print(cleanPath);

    return "http://localhost:3000$cleanPath";
  }
}

class Order {
  final int? id;
  final int? customerId;
  final double? totalPrice;
  final double? deliveryFee;
  final String? status;
  final String? deliveryAddress;
  final DateTime? createdAt;
  final List<OrderItem> items;

  Order({
    this.id,
    this.customerId,
    this.totalPrice,
    this.deliveryFee,
    this.status,
    this.deliveryAddress,
    this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      itemList = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      status: json['status'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      items: itemList,
    );
  }
}

// ==================== PAGE ====================

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  bool _isLoading = true;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  static Future<List<Order>> getOrders() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print("No token found");
        return [];
      }

      final response = await http.get(
        Uri.parse("http://localhost:3000/api/orders"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("GET ORDERS STATUS: ${response.statusCode}");
      print("GET ORDERS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          List<Order> orders = [];
          for (var item in decoded) {
            try {
              orders.add(Order.fromJson(item));
            } catch (e) {
              print("Error parsing order: $e");
            }
          }
          return orders;
        }
      }
      return [];
    } catch (e) {
      print("ERROR getOrders: $e");
      return [];
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final orders = await getOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  /// Flatten all orders into individual (Order, OrderItem) pairs for card display
  List<({Order order, OrderItem item})> get _allPairs {
    List<({Order order, OrderItem item})> pairs = [];
    for (var order in _orders) {
      for (var item in order.items) {
        pairs.add((order: order, item: item));
      }
    }
    return pairs;
  }

  List<({Order order, OrderItem item})> get _filteredPairs {
    return _allPairs.where((pair) {
      final matchesSearch =
          pair.item.fishName?.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ??
          false;

      final matchesFilter =
          _selectedFilter == "All" ||
          (pair.order.status?.toLowerCase() == _selectedFilter.toLowerCase());

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
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black12,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: "Search by fish name...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          "All",
                          "Delivered",
                          "Pending",
                          "Processing",
                        ].map(_buildFilterChip).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cards
                    if (_filteredPairs.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No orders found.',
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
                        itemCount: _filteredPairs.length,
                        itemBuilder: (context, index) {
                          final pair = _filteredPairs[index];
                          return OrderCard(order: pair.order, item: pair.item);
                        },
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD5A439) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePageC()),
            ),
            icon: const Icon(Icons.home_outlined, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.list_alt_outlined,
              color: Color(0xFFD5A439),
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ShoppingCartPage()),
            ),
            icon: const Icon(Icons.shopping_cart, color: Colors.grey),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileConsumerPage()),
            ),
            icon: const Icon(Icons.person, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ==================== ORDER CARD ====================

class OrderCard extends StatelessWidget {
  final Order order;
  final OrderItem item;
  const OrderCard({super.key, required this.order, required this.item});

  /// Total price = subtotal * delivery_fee
  double get _cardTotal => (item.subtotal ?? 0) + (order.deliveryFee ?? 0);

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return "${months[date.month - 1]} ${date.day}, $h:$m";
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "delivered":
        return const Color(0xFF047857);
      case "pending":
        return const Color(0xFFB45309);
      case "processing":
        return const Color(0xFF094BB4);
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case "delivered":
        return const Color(0xFFD1FAE5);
      case "pending":
        return const Color(0xFFFEF3C7);
      case "processing":
        return const Color(0xFFC7DCFE);
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order.status ?? "pending";
    final photoUrl = item.getFirstPhotoUrl();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fish image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey[100],
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 30,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(Icons.set_meal, size: 30, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),

          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fishName ?? "Unknown",
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "• ${_formatDate(order.createdAt)}",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category ?? "",
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Status + qty + price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor(status),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quantity
              Text(
                "${(item.quantityKg ?? 0).toStringAsFixed(1)} kg",
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 2),

              // Total = subtotal × delivery_fee
              Text(
                "${_cardTotal.toStringAsFixed(2)} DA",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD5A439),
                  fontSize: 15,
                ),
              ),
              
            ],
          ),
          
        ],
      ),
    );
  }
}

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}
