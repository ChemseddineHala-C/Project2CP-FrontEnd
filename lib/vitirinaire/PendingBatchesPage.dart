import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PendingBatchesPage extends StatefulWidget {
  const PendingBatchesPage({super.key});

  @override
  State<PendingBatchesPage> createState() => _PendingBatchesPageState();
}

class _PendingBatchesPageState extends State<PendingBatchesPage> {

  //final List<PendingBatch> _batches = [];
  final List<PendingBatch> _batches = [
    PendingBatch(
      batchNumber: "#BT-9842",
      captainName: "Capt. Fouad",
      type: "Sardin",
      quantity: 1250,
      arrival: "08:30 AM",
      portTemp: 1.2,
      status: "Pending",
    ),
    PendingBatch(
      batchNumber: "#BT-9845",
      captainName: "Capt. Mohamed",
      type: "Roudji",
      quantity: 980,
      arrival: "09:15 AM",
      portTemp: 0.8,
      status: "Pending",
    ),
    PendingBatch(
      batchNumber: "#BT-9849",
      captainName: "Capt. Yassin",
      type: "Atlantic Salmon",
      quantity: 2100,
      arrival: "11:00 AM",
      portTemp: 1.5,
      status: "Pending",
    ),
  ];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedType = "All Types";

  List<PendingBatch> get _filteredBatches => _batches.where((batch) {
    final matchSearch = batch.batchNumber.toLowerCase()
        .contains(_searchQuery.toLowerCase());
    final matchType = _selectedType == "All Types" ||
        batch.type == _selectedType;
    return matchSearch && matchType;
  }).toList();






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
          "Pending Batches",
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
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

          TextFormField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "Search Batch ID",
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          Block(),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All Types", "Sardin", "Roudji", "Atlantic Salmon"].map((type) =>
                  GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedType == type
                            ? Color(0xFF01A896)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: _selectedType == type
                              ? Colors.white
                              : Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
              ).toList(),
            ),
          ),

          Block(),

          Text(
            "TODAY'S ARRIVALS",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF000000),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          Block(),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _filteredBatches.length,
            itemBuilder: (context, index) => PendingBatchCard(
              batch: _filteredBatches[index],
            ),
          ),


        ]
        ),
      ),
    );
  }
}

class PendingBatch {
  final String batchNumber;
  final String captainName;
  final String type;
  final double quantity;
  final String arrival;
  final double portTemp;
  final String status;

  PendingBatch({
    required this.batchNumber,
    required this.captainName,
    required this.type,
    required this.quantity,
    required this.arrival,
    required this.portTemp,
    required this.status,
  });
}

class PendingBatchCard extends StatelessWidget {
  final PendingBatch batch;

  const PendingBatchCard({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Text(
                batch.batchNumber,
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  batch.status,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4),
          Text(
            batch.captainName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.set_meal, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "TYPE",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      batch.type,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop_outlined, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "QUANTITY",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${batch.quantity} kg",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "ARRIVAL",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      batch.arrival,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thermostat, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "PORT TEMP",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${batch.portTemp}°C",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Verify Batch"),
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