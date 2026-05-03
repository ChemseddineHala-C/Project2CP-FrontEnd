import 'package:flutter/material.dart';


// final List<CartItem> _mockCartItems = [
//   CartItem(
//     name: "Fresh Bluefin Tuna",
//     fisherName: "Capt, Ahmed",
//     pricePerKg: 1920.0, // Calculated from 4800 / 2.5
//     weightKg: 2.5,
//     image: "images/fish1.png", // Replace with your assets
//   ),
//   CartItem(
//     name: "King Crab Legs",
//     fisherName: "Capt, Ahmed",
//     pricePerKg: 3700.0,
//     weightKg: 1.0,
//     image: "images/fish1.png",
//   ),
//   CartItem(
//     name: "Atlantic Salmon",
//     fisherName: "Capt, Ahmed",
//     pricePerKg: 933.33,
//     weightKg: 3.0,
//     image: "images/fish1.png",
//   ),
// ];

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {

  bool _isLoading = false;
  List<CartItem> _cartItems = [];
  final double _deliveryFee = 485.00;

  @override
  void initState() {
    super.initState();
  }




  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get _totalAmount {
    return _subtotal + _deliveryFee;
  }


  void _updateQuantity(int index, double change) {
    setState(() {
      double newWeight = _cartItems[index].weightKg + change;
      if (newWeight >= 0.5) { // Minimum weight constraint
        _cartItems[index].weightKg = newWeight;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
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
            letterSpacing: -0.6, // Matching your title styling
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
            // Item List using your ListView.builder pattern
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) => _buildCartCard(index),
            ),
            const Block(), // Vertical spacing widget re-used from your files
            _buildPromoCodeField(),
            const Block(),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS FOLLOWING YOUR RHYTHM ---

  Widget _buildCartCard(int index) {
    CartItem item = _cartItems[index];
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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: Image.asset(
                item.image.isNotEmpty
                    ? item.image
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: const TextStyle(fontFamily: 'work sanc',color: Color(0xFF111618),fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _removeItem(index),
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFF87171), size: 20),
                    ),
                  ],
                ),
                Text(item.fisherName, style: const TextStyle(fontFamily: 'work sanc',color: Color(0xFF617C89), fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${item.totalPrice.toStringAsFixed(2)} DA",
                      style: const TextStyle(fontFamily: 'work sanc',fontWeight: FontWeight.w800, color: Color(0xFFD5A439), fontSize: 16),
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
    CartItem item = _cartItems[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _quantityBtn(Icons.remove, () => _updateQuantity(index, -0.5), isMinus: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "${item.weightKg}kg",
              style: const TextStyle(fontFamily: 'work sanc',fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF111618)),
            ),
          ),
          _quantityBtn(Icons.add, () => _updateQuantity(index, 0.5)),
        ],
      ),
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap, {bool isMinus = false}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: isMinus ? Colors.white : const Color(0xFFD5A439),
        child: Icon(icon, color: isMinus ? Colors.grey : Colors.white, size: 16),
      ),
    );
  }

  Widget _buildPromoCodeField() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x0D1DA7ED), // Light blue tint
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Color(0xFFD5A439)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Have a promo code?",
              style: TextStyle(fontFamily: 'work sanc',color: Color(0xFF617C89), fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Apply", style: TextStyle(fontFamily: 'work sanc',color: Color(0xFFD5A439), fontWeight: FontWeight.w700)),
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
          _summaryRow("Subtotal", "${_subtotal.toStringAsFixed(2)} DA"),
          const SizedBox(height: 12),
          _summaryRow("Delivery Fee", "${_deliveryFee.toStringAsFixed(2)} DA"),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _summaryRow("Total Amount", "${_totalAmount.toStringAsFixed(2)} DA", isTotal: true),
          const Block(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Text(""), // Empty space to match the spacing
              label: const Text("Proceed to Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD5A439),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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


  Widget _navIcon(IconData icon, bool isActive) {
    return Icon(icon, color: isActive ? const Color(0xFFD5A439) : Colors.grey[300], size: isActive ? 28 : 24);
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
  final String name, fisherName, image;
  final double pricePerKg;
  double weightKg;
  CartItem({required this.name, required this.fisherName, required this.image, required this.pricePerKg, required this.weightKg});
  double get totalPrice => pricePerKg * weightKg;
}