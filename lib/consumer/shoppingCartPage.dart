import 'package:fishapp/consumer/homePage.dart';
import 'package:fishapp/consumer/myOrderPage.dart';
import 'package:fishapp/consumer/profilconsumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}


class CartApiService {
  static Future<Cart?> getCart() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print("No token found");
        return null;
      }

      final response = await http.get(
        Uri.parse("http://localhost:3000/api/cart"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("GET CART STATUS: ${response.statusCode}");
      print("GET CART RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Cart.fromJson(decoded);
      }
      return null;
    } catch (e) {
      print("ERROR getCart: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateCartItemQuantity({
    required int cartItemId,
    required double quantity,
  }) async {
    if (quantity <= 0) return null;

    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.put(
        Uri.parse("http://localhost:3000/api/cart/items/$cartItemId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"quantity_kg": quantity}),
      );

      print("UPDATE CART ITEM STATUS: ${response.statusCode}");
      print("UPDATE CART ITEM RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("ERROR updateCartItemQuantity: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> removeCartItem({
    required int cartItemId,
  }) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.delete(
        Uri.parse("http://localhost:3000/api/cart/items/$cartItemId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("DELETE CART ITEM STATUS: ${response.statusCode}");
      print("DELETE CART ITEM RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("ERROR removeCartItem: $e");
      return null;
    }
  }
}



class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  bool _isLoading = true;
  Cart? _cart;
  bool _isUpdating = false;


  Future<void> placeOrder(BuildContext context) async {
    try {
        Cart? cart = await CartApiService.getCart();
    if (cart == null || cart.items == null || cart.items!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your cart is empty"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

      String? token = await _getToken();
      if (token == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No Token"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final response = await http.post(
        Uri.parse("http://localhost:3000/api/orders"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("PLACE ORDER STATUS: ${response.statusCode}");
      print("PLACE ORDER RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${data['message']}, orderId:${data['order_id']}, Total:${data['total_price']}DA"),
              backgroundColor: Colors.green,
            ),
          );
        }

        _fetchCart();
        
      } else {
        final data = jsonDecode(response.body);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error placing order: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() {
      _isLoading = true;
    });
    Cart? cart = await CartApiService.getCart();
    setState(() {
      _cart = cart;
      _isLoading = false;
    });
  }

  Future<void> _updateQuantity(int index, double change) async {
    if (_cart == null || _cart!.items == null || index >= _cart!.items!.length)
      return;
    if (_isUpdating) return;

    CartItem item = _cart!.items![index];
    double currentQty = item.quantityKg ?? 0;
    double newQuantity = currentQty + change;

    if (newQuantity < 0.5) return;

    if (item.remainingQuantityKg != null &&
        newQuantity > item.remainingQuantityKg!) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Maximum available: ${item.remainingQuantityKg} kg"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    Map<String, dynamic>? result = await CartApiService.updateCartItemQuantity(
      cartItemId: item.id!,
      quantity: newQuantity,
    );

    if (result != null) {
      await _fetchCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Quantity updated"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Failed to update quantity"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isUpdating = false;
    });
  }

  Future<void> _removeItem(int index) async {
    if (_cart == null || _cart!.items == null || index >= _cart!.items!.length)
      return;
    if (_isUpdating) return;

    CartItem item = _cart!.items![index];

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove item"),
        content: Text("Remove ${item.fishName ?? "this item"} from cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isUpdating = true;
    });

    Map<String, dynamic>? result = await CartApiService.removeCartItem(
      cartItemId: item.id!,
    );

    if (result != null) {
      await _fetchCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Item removed from cart"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Failed to remove item"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isUpdating = false;
    });
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
          "Shopping Cart",
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
          : _cart == null || _cart!.items == null || _cart!.items!.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cart!.items!.length,
                    itemBuilder: (context, index) => _buildCartCard(index),
                  ),
                  // const Block(),
                  // _buildPromoCodeField(),
                  const Block(),
                  _buildSummaryCard(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(false),
    );
  }

  Widget _buildCartCard(int index) {
    if (_cart == null ||
        _cart!.items == null ||
        index >= _cart!.items!.length) {
      return const SizedBox.shrink();
    }

    CartItem item = _cart!.items![index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: Image.network(
                item.getFirstPhotoUrl(),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "images/grey.jpg",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.fishName ?? "Unknown",
                        style: const TextStyle(
                          fontFamily: 'work sanc',
                          color: Color(0xFF111618),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _isUpdating ? null : () => _removeItem(index),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFF87171),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${((item.pricePerKg ?? 0) * (item.quantityKg ?? 0)).toStringAsFixed(2)} DA",
                      style: const TextStyle(
                        fontFamily: 'work sanc',
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD5A439),
                        fontSize: 16,
                      ),
                    ),
                    _buildQuantitySelector(index),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(int index) {
    if (_cart == null ||
        _cart!.items == null ||
        index >= _cart!.items!.length) {
      return const SizedBox.shrink();
    }
    CartItem item = _cart!.items![index];
    double qty = item.quantityKg ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _quantityBtn(
            Icons.remove,
            () => _updateQuantity(index, -0.5),
            isMinus: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "${qty.toStringAsFixed(1)}kg",
              style: const TextStyle(
                fontFamily: 'work sanc',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF111618),
              ),
            ),
          ),
          _quantityBtn(
            Icons.add,
            () => _updateQuantity(index, 0.5),
            isMinus: false,
          ),
        ],
      ),
    );
  }

  Widget _quantityBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isMinus = false,
  }) {
    return GestureDetector(
      onTap: _isUpdating ? null : onTap,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: isMinus ? Colors.white : const Color(0xFFD5A439),
        child: Icon(
          icon,
          color: isMinus ? Colors.grey : Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildPromoCodeField() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x0D1DA7ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Color(0xFFD5A439)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Have a promo code?",
              style: TextStyle(
                fontFamily: 'work sanc',
                color: Color(0xFF617C89),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Apply",
              style: TextStyle(
                fontFamily: 'work sanc',
                color: Color(0xFFD5A439),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          _summaryRow(
            "Subtotal",
            "${(_cart?.subtotal ?? 0).toStringAsFixed(2)} DA",
          ),
          const SizedBox(height: 12),
          _summaryRow(
            "Delivery Fee",
            "${(_cart?.deliveryFee ?? 0).toStringAsFixed(2)} DA",
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _summaryRow(
            "Total Amount",
            "${(_cart?.total ?? 0).toStringAsFixed(2)} DA",
            isTotal: true,
          ),
          const Block(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _isUpdating ? null : () => placeOrder(context),
              icon: const Text(""),
              label: const Text(
                "Proceed to Checkout",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD5A439),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            color: isTotal ? const Color(0xFF111618) : const Color(0xFF617C89),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w400,
            color: isTotal ? const Color(0xFFD5A439) : const Color(0xFF617C89),
          ),
        ),
      ],
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePageC()),
              );
            },
            icon: Icon(
              Icons.home_outlined,
              color: isDark ? Colors.white54 : Colors.grey,
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
            onPressed: () {},
            icon: Icon(
              Icons.shopping_cart,
              color: isDark ? Colors.white54 : const Color(0xFFD5A439),
              size: 30,
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

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}

class CartItem {
  final int? id;
  final int? cartId;
  final int? batchId;
  final double? quantityKg;
  final double? pricePerKg;
  final DateTime? createdAt;
  final String? fishName;
  final String? category;
  final double? remainingQuantityKg;
  final List<String>? photo;
  final String? batchStatus;

  CartItem({
    this.id,
    this.cartId,
    this.batchId,
    this.quantityKg,
    this.pricePerKg,
    this.createdAt,
    this.fishName,
    this.category,
    this.remainingQuantityKg,
    this.photo,
    this.batchStatus,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    List<String> photoList = [];

    if (json['photo'] != null) {
      if (json['photo'] is List) {
        // حالة القائمة العادية
        photoList = List<String>.from(json['photo']);
      } else if (json['photo'] is String) {
        String photoString = json['photo'];
        try {
          dynamic decoded = jsonDecode(photoString);
          if (decoded is List) {
            photoList = List<String>.from(decoded);
          } else if (decoded is String) {
            photoList = [decoded];
          }
        } catch (e) {
          photoList = [photoString];
        }
      } else if (json['photo'] is Map) {
        photoList = (json['photo'] as Map).values
            .map((e) => e.toString())
            .toList();
      }
    }

    return CartItem(
      id: json['id'] as int?,
      cartId: json['cart_id'] as int?,
      batchId: json['batch_id'] as int?,
      quantityKg: (json['quantity_kg'] as num?)?.toDouble(),
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      fishName: json['fish_name'] as String?,
      category: json['category'] as String?,
      remainingQuantityKg: (json['remaining_quantity_kg'] as num?)?.toDouble(),
      photo: photoList,
      batchStatus: json['batch_status'] as String?,
    );
  }

  String getFirstPhotoUrl() {
    if (photo == null || photo!.isEmpty) return '';

    String rawPath = photo![0];

    String cleanPath = rawPath
        .replaceAll('"', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceFirst('src', '');

    return "http://localhost:3000$cleanPath";
  }

  List<String> getAllPhotoUrls() {
    if (photo == null || photo!.isEmpty) return [];
    return photo!
        .map((p) => "http://localhost:3000/${p.replaceFirst("src/", "")}")
        .toList();
  }
}

class Cart {
  final int? cartId;
  final List<CartItem>? items;
  final double? subtotal;
  final double? deliveryFee;
  final double? total;

  Cart({this.cartId, this.items, this.subtotal, this.deliveryFee, this.total});

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      itemList = (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    }

    return Cart(
      cartId: json['cart_id'] as int?,
      items: itemList,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

