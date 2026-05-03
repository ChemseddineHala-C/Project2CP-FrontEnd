import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../vitirinaire/batchReportPageV.dart';

class BatchDetails extends StatefulWidget {
  const BatchDetails({super.key});

  @override
  State<BatchDetails> createState() => _BatchDetailsState();
}

class _BatchDetailsState extends State<BatchDetails> {
  final MarketBatch _batch = MarketBatch(
    category: "MARINE FISH",
    fishName: "Sea Bream",
    pricePerKg: 2450.00,
    availableKg: 12.5,
    arrivalDate: "Mar 31, 2026 3:12 PM",
    freshnessScore: 85,
    shelfLifeHours: 14,
    photos: ["images/fish1.png", "images/fish2.png", "images/fish3.jpg"],
    deliveryAddress: "Rue El wiam, Sidi Bel Abbes",
  );

  double _quantity = 3.0;
  int _currentPhotoIndex = 0;
  PageController _pageController = PageController();

  double get _totalPrice => _quantity * _batch.pricePerKg;

  //
  String _deliveryAddress = "Rue El wiam, Sidi Bel Abbes";

  void _editDeliveryAddress() {
    TextEditingController _addressController = TextEditingController(
      text: _deliveryAddress,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delivery Address"),
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
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _deliveryAddress = _addressController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD5A43A)),
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
        backgroundColor: Colors.white,
      ),
    );
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
          "batch Details",
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Block(),

            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _batch.photos.length,
                onPageChanged: (index) {
                  setState(() => _currentPhotoIndex = index);
                },

                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(_batch.photos[index], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

            Block(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _batch.photos.length,
                    (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentPhotoIndex
                        ? Color(0xFFD5A43A)
                        : Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            Block(),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0, -1),
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0x33D5A439),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _batch.category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFFD5A439),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  // Fish Name + Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _batch.fishName,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Color(0xFF334155),
                                letterSpacing: -0.6,
                              ),
                            ),
                            Text(
                              "${_batch.availableKg} Kg Available",
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
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${_batch.pricePerKg.toStringAsFixed(2)} DA",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Color(0xFF334155),
                              letterSpacing: -0.6,
                            ),
                          ),
                          Text(
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
                  //Block(),
                  Divider(),
                  Block(),
                  // Arrival
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFDADADA)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.anchor, color: Color(0xFFDADADA), size: 18),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                              _batch.arrivalDate,
                              style: TextStyle(
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

                  Block(),

                  // Freshness Score + Shelf Life
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFDADADA)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Overall Freshness Score",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${_batch.freshnessScore}/100",
                                style: TextStyle(
                                  color: Color(0xFFD5A439),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),

                              SizedBox(height: 6),
                              LinearPercentIndicator(
                                percent: _batch.freshnessScore / 100,
                                lineHeight: 6,
                                backgroundColor: Color(0xFFE2E8F0),
                                progressColor: Color(0xFFD5A439),
                                barRadius: Radius.circular(4),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFDADADA)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                color: Color(0xFFCDCDCD),
                                size: 18,
                              ),
                              Text(
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
                                "${_batch.shelfLifeHours}H Left",
                                style: TextStyle(
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

            Block(),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0, -1),
                    spreadRadius: 0,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Digital Certificate
                  GestureDetector(
                    onTap: () => {},
                    child: Container(
                      padding: EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFDADADA)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            color: Color(0xFFD5A439),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                  "PDF format - 1.2 MB",
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
                          Icon(
                            Icons.download_outlined,
                            color: Color(0xFFA2AFC1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Block(),

                  // View Batch Report
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BatchReportPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFDADADA)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            color: Color(0xFFD5A439),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "View Batch Report",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF334155),
                              fontFamily: 'Inter',
                            ),
                          ),
                          Spacer(),
                          Icon(
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

            Block(),

            // ── Buy Section ───────────────────────
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0, -1),
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
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFFF6F7F8),
                          borderRadius: BorderRadiusGeometry.circular(20),
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "${_quantity}kg",
                              style: TextStyle(
                                fontFamily: 'work sanc',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                if (_quantity < _batch.availableKg) {
                                  setState(() => _quantity += 0.5);
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(0xFFD5A439),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${_totalPrice.toStringAsFixed(2)} DA",
                            style: TextStyle(
                              fontFamily: 'work sanc',
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: Color(0xFFD5A439),
                            ),
                          ),
                          Text(
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

                  Block(),

                  // Delivery Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFD5A439),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
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
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      GestureDetector(
                        onTap: _editDeliveryAddress, // ← هنا
                        child: Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFA2AFC1),
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  Block(),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print("add");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFADADAD),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Add to cart"),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print("buy");
                          },
                          icon: Icon(Icons.chevron_right),
                          label: Text("Buy now"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD5A439),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 52),
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

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}
