import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
//import 'package:url_launcher/url_launcher.dart';
import './batchReportPageC.dart';
import './shoppingCartPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
//import './myOrderPage.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class BatchDetails extends StatefulWidget {
  final int id;
  const BatchDetails({super.key, required this.id});

  @override
  State<BatchDetails> createState() => _BatchDetailsState();
}

class _BatchDetailsState extends State<BatchDetails> {
  bool _isLoading = true;
  BatchWithInspection? _batch;

  double _quantity = 0.5;
  int _currentPhotoIndex = 0;
  late PageController _pageController;
  String _deliveryAddress = "Rue El wiam, Sidi Bel Abbes";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchBatch();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchBatch() async {
    setState(() {
      _isLoading = true;
    });
    BatchWithInspection? batch = await getBatchWithInspection(widget.id);
    setState(() {
      _batch = batch;
      _isLoading = false;
    });
  }

  static Future<BatchWithInspection?> getBatchWithInspection(
    int batchId,
  ) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print("No token found");
        return null;
      }

      final response = await http.get(
        Uri.parse("http://192.168.1.94:3000/api/batches/$batchId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return BatchWithInspection.fromJson(decoded);
      } else {
        print("Failed to get batch");
        return null;
      }
    } catch (e) {
      print("Error fetching batch: $e");
      return null;
    }
  }

  static Future<void> addToCart({
    required int batchId,
    required double quantity,
    required BuildContext context,
  }) async {
    if (batchId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Batch ID invalide"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La quantité doit être supérieure à 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print("$batchId");
    try {
      String? token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Token non trouvé. Veuillez vous reconnecter."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ إنشاء الطلب
      final response = await http.post(
        Uri.parse("http://192.168.1.94:3000/api/cart/items"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"batch_id": batchId, "quantity_kg": quantity}),
      );

      print("ADD TO CART STATUS: ${response.statusCode}");
      print("ADD TO CART RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "✅ Ajouté au panier!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (e) {
      print("Error adding to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur: $e"), backgroundColor: Colors.red),
      );
      return;
    }
  }

  static Future<void> buyNow({
    required int batchId,
    required double quantity,
    required BuildContext context,
  }) async {
    if (batchId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Batch ID invalide"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La quantité doit être supérieure à 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print("$batchId");
    try {
      String? token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Token non trouvé. Veuillez vous reconnecter."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ إنشاء الطلب
      final response = await http.post(
        Uri.parse("http://192.168.1.94:3000/api/orders/buy-now"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"batch_id": batchId, "quantity_kg": quantity}),
      );

      print("ADD TO CART STATUS: ${response.statusCode}");
      print("ADD TO CART RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "✅ Ajouté au panier!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (e) {
      print("Error adding to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur: $e"), backgroundColor: Colors.red),
      );
      return;
    }
  }

  double get _totalPrice {
    if (_batch == null) return 0;
    return _quantity * (_batch!.pricePerKg ?? 0);
  }

  // ✅ حساب وقت التخزين المتبقي (3 أيام من تاريخ الإنشاء)
  String get _shelfLifeLeft {
    if (_batch?.createdAt == null) return "N/A";
    final now = DateTime.now();
    final created = _batch!.createdAt!;
    final expiryDate = created.add(const Duration(days: 3));
    final remaining = expiryDate.difference(now);

    if (remaining.isNegative) return "Expired";
    final hoursLeft = remaining.inHours;
    if (hoursLeft < 24) return "${hoursLeft}H Left";
    final daysLeft = remaining.inDays;
    return "${daysLeft}D Left";
  }

  // ✅ تنسيق التاريخ
  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
  }

  void _editDeliveryAddress() {
    TextEditingController _addressController = TextEditingController(
      text: _deliveryAddress,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delivery Address"),
        content: TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: "Enter your address...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _deliveryAddress = _addressController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD5A43A),
            ),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF0F172A),
          ),
          title: const Text(
            "Batch Details",
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
          elevation: 3,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_batch == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF0F172A),
          ),
          title: const Text(
            "Batch Details",
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
          elevation: 3,
        ),
        body: const Center(child: Text("Batch not found")),
      );
    }

    final photoUrls = _batch!.getAllPhotoUrls();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0F172A),
        ),
        title: const Text(
          "Batch Details",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Block(),

            // ✅ Photo Carousel
            if (photoUrls.isNotEmpty) ...[
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: photoUrls.length,
                  onPageChanged: (index) {
                    setState(() => _currentPhotoIndex = index);
                  },
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        photoUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const Block(),

              // ✅ Photo Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photoUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentPhotoIndex
                          ? const Color(0xFFD5A43A)
                          : const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.no_photography,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],

            const Block(),

            // ✅ Main Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    offset: const Offset(0, -1),
                    spreadRadius: 0,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x33D5A439),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _batch!.category ?? "Category",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFFD5A439),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Fish Name + Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _batch!.fishName ?? "Unknown",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Color(0xFF334155),
                                letterSpacing: -0.6,
                              ),
                            ),
                            Text(
                              "${_batch!.remainingQuantityKg?.toStringAsFixed(1) ?? "0"} Kg Available",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF9C9C9C),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${_batch!.pricePerKg?.toStringAsFixed(2) ?? "0"} DA",
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Color(0xFF334155),
                              letterSpacing: -0.6,
                            ),
                          ),
                          const Text(
                            "Per Kilogram",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF9C9C9C),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  const Block(),

                  // Arrival (Created At)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDADADA)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.anchor,
                          color: Color(0xFFDADADA),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Arrival",
                              style: TextStyle(
                                color: Color(0xFF9C9C9C),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.6,
                              ),
                            ),
                            Text(
                              _formatDate(_batch!.createdAt),
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Block(),

                  // Freshness Score + Shelf Life
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFDADADA)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Overall Freshness Score",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${_batch!.inspection?.freshnessScore ?? 0}/100",
                                style: const TextStyle(
                                  color: Color(0xFFD5A439),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              LinearPercentIndicator(
                                percent:
                                    (_batch!.inspection?.freshnessScore ?? 0) /
                                    100,
                                lineHeight: 6,
                                backgroundColor: const Color(0xFFE2E8F0),
                                progressColor: const Color(0xFFD5A439),
                                barRadius: const Radius.circular(4),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFDADADA)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.access_time_filled,
                                color: Color(0xFFCDCDCD),
                                size: 18,
                              ),
                              const Text(
                                "Shelf Life",
                                style: TextStyle(
                                  color: Color(0xFF9C9C9C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  letterSpacing: -0.6,
                                ),
                              ),
                              Text(
                                _shelfLifeLeft,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Color(0xFF334155),
                                  fontFamily: 'Inter',
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Block(),

            // ✅ Documents Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    offset: const Offset(0, -1),
                    spreadRadius: 0,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Digital Certificate
                  GestureDetector(
                    onTap: () => {
                      DownloadCer("${_batch!.inspection!.id}", context),
                    },
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDADADA)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            color: Color(0xFFD5A439),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Digital certificate",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF334155),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                Text(
                                  "PDF format",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF9C9C9C),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.download_outlined,
                            color: Color(0xFFA2AFC1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Block(),

                  // View Batch Report
                  GestureDetector(
                    onTap: () {
                      if (_batch!.id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BatchReportPage(
                              id: _batch!.inspection!.id!,
                              batchId: _batch!.id!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDADADA)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Color(0xFFD5A439),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "View Batch Report",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF334155),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.open_in_new_sharp,
                            color: Color(0xFFA2AFC1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Block(),

            // ✅ Buy Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    offset: const Offset(0, -1),
                    spreadRadius: 0,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Quantity + Total Price
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 0.5) {
                                  setState(() => _quantity -= 0.5);
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${_quantity.toStringAsFixed(1)}kg",
                              style: const TextStyle(
                                fontFamily: 'work sanc',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                final maxKg = _batch!.remainingQuantityKg ?? 0;
                                if (_quantity + 0.5 <= maxKg) {
                                  setState(() => _quantity += 0.5);
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD5A439),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${_totalPrice.toStringAsFixed(2)} DA",
                            style: const TextStyle(
                              fontFamily: 'work sanc',
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: Color(0xFFD5A439),
                            ),
                          ),
                          const Text(
                            "Total Price",
                            style: TextStyle(
                              color: Color(0xFF9C9C9C),
                              fontSize: 15,
                              fontFamily: 'work sanc',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Block(),

                  // Delivery Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFD5A439),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Delivery to: ",
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _deliveryAddress,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      GestureDetector(
                        onTap: _editDeliveryAddress,
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFA2AFC1),
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const Block(),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            addToCart(
                              batchId: _batch!.id!,
                              quantity: _quantity,
                              context: context,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShoppingCartPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFADADAD),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Add to cart"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            buyNow(
                              batchId: _batch!.id!,
                              quantity: _quantity,
                              context: context,
                            );
                          },
                          icon: const Icon(Icons.chevron_right),
                          label: const Text("Buy now"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD5A439),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
}

// ✅ MarketBatch (keep as is for reference)
class MarketBatch {
  final String category;
  final String fishName;
  final double pricePerKg;
  final double availableKg;
  final String arrivalDate;
  final int freshnessScore;
  final int shelfLifeHours;
  final List<String> photos;
  final String deliveryAddress;

  MarketBatch({
    required this.category,
    required this.fishName,
    required this.pricePerKg,
    required this.availableKg,
    required this.arrivalDate,
    required this.freshnessScore,
    required this.shelfLifeHours,
    required this.photos,
    required this.deliveryAddress,
  });

  factory MarketBatch.fromJson(Map<String, dynamic> json) {
    return MarketBatch(
      category: json["category"],
      fishName: json["fish_name"],
      pricePerKg: json["price_per_kg"].toDouble(),
      availableKg: json["available_kg"].toDouble(),
      arrivalDate: json["arrival_date"],
      freshnessScore: json["freshness_score"],
      shelfLifeHours: json["shelf_life_hours"],
      photos: List<String>.from(json["photos"]),
      deliveryAddress: json["delivery_address"],
    );
  }
}

// ✅ Inspection Model
class BatchInspection {
  final int? id;
  final int? freshnessScore;
  final String? inspectionDecision;
  final DateTime? inspectedAt;

  BatchInspection({
    this.id,
    this.freshnessScore,
    this.inspectionDecision,
    this.inspectedAt,
  });

  factory BatchInspection.fromJson(Map<String, dynamic> json) {
    return BatchInspection(
      id: json['id'] as int?,
      freshnessScore: json['freshness_score'] as int?,
      inspectionDecision: json['inspection_decision'] as String?,
      inspectedAt: json['inspected_at'] != null
          ? DateTime.tryParse(json['inspected_at'])
          : null,
    );
  }

  String getFormattedInspectedAt() {
    if (inspectedAt == null) return 'N/A';
    return "${inspectedAt!.year}-${inspectedAt!.month}-${inspectedAt!.day} ${inspectedAt!.hour}:${inspectedAt!.minute}";
  }
}

// ✅ BatchWithInspection Model
class BatchWithInspection {
  final int? id;
  final int? fishermanId;
  final String? category;
  final String? fishName;
  final String? catchMethod;
  final double? quantityKg;
  final double? remainingQuantityKg;
  final double? pricePerKg;
  final List<String>? photo;
  final double? latitude;
  final double? longitude;
  final String? additionalNotes;
  final String? status;
  final DateTime? createdAt;
  final String? fishermanName;
  final String? boatName;
  final BatchInspection? inspection;

  BatchWithInspection({
    this.id,
    this.fishermanId,
    this.category,
    this.fishName,
    this.catchMethod,
    this.quantityKg,
    this.remainingQuantityKg,
    this.pricePerKg,
    this.photo,
    this.latitude,
    this.longitude,
    this.additionalNotes,
    this.status,
    this.createdAt,
    this.fishermanName,
    this.boatName,
    this.inspection,
  });

  factory BatchWithInspection.fromJson(Map<String, dynamic> json) {
    List<String> photoList = [];
    if (json['photo'] != null && json['photo'] is List) {
      photoList = List<String>.from(json['photo']);
    }

    return BatchWithInspection(
      id: json['id'] as int?,
      fishermanId: json['fisherman_id'] as int?,
      category: json['category'] as String?,
      fishName: json['fish_name'] as String?,
      catchMethod: json['catch_method'] as String?,
      quantityKg: (json['quantity_kg'] as num?)?.toDouble(),
      remainingQuantityKg: (json['remaining_quantity_kg'] as num?)?.toDouble(),
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      photo: photoList,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      additionalNotes: json['additional_notes'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      fishermanName: json['fisherman_name'] as String?,
      boatName: json['boat_name'] as String?,
      inspection: json['inspection'] != null
          ? BatchInspection.fromJson(json['inspection'])
          : null,
    );
  }

  String getFirstPhotoUrl() {
    if (photo == null || photo!.isEmpty) return '';
    return "http://192.168.1.94:3000/${photo![0].replaceFirst("src/", "")}";
  }

  List<String> getAllPhotoUrls() {
    if (photo == null || photo!.isEmpty) return [];
    return photo!
        .map((p) => "http://192.168.1.94:3000/${p.replaceFirst("src/", "")}")
        .toList();
  }

  String get inspectionDecisionText {
    switch (inspection?.inspectionDecision?.toLowerCase()) {
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد المراجعة';
    }
  }

  Color get inspectionDecisionColor {
    switch (inspection?.inspectionDecision?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}

Future<void> DownloadCer(String id, BuildContext context) async {
  try {
    // 1. Check for token
    String? token = await _getToken();
    if (token == null) {
      print("No token found");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No token found, please login again"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 2. Request storage permission (for Android)
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.request();

      // For Android 11+ (API 30+) need manage external storage permission
      if (await Permission.manageExternalStorage.isDenied) {
        status = await Permission.manageExternalStorage.request();
      }

      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please grant storage permission to download the file",
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // 3. Show loading message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text("Downloading certificate..."),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 4. Send request to server
    final response = await http.get(
      Uri.parse(
        "http://192.168.1.94:3000/api/inspections/batch/$id/certificate",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    print("DOWNLOAD STATUS: ${response.statusCode}");

    // 5. Handle response
    if (response.statusCode == 200) {
      // Get the correct downloads folder path
      String? downloadsPath;

      if (Platform.isAndroid) {
        // Correct way to get Download folder path on Android
        downloadsPath = '/storage/emulated/0/Download';

        // Check if folder exists, create if not
        final downloadDir = Directory(downloadsPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      }

      // Create filename with timestamp to avoid duplication
      String fileName =
          "certificate_${id}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      String filePath = "$downloadsPath/$fileName";

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Check file size to ensure it was saved correctly
      int fileSize = await file.length();
      print("File saved: $filePath, Size: $fileSize bytes");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("✅ Certificate downloaded successfully"),
                Text(
                  "Saved to: Download/$fileName",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      print("✅ File saved successfully to: $filePath");
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired, please login again"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else if (response.statusCode == 404) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Certificate not found for this ID"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download failed: Error ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print("Error in DownloadCer: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
