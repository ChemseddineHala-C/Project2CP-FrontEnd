import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InspectionHistoryPage extends StatefulWidget {
  const InspectionHistoryPage({super.key});

  @override
  State<InspectionHistoryPage> createState() => _InspectionHistoryPageState();
}

class _InspectionHistoryPageState extends State<InspectionHistoryPage> {
  // Variables
  List<InspectionItem> _inspections = [];
  bool _isLoading = false;
  String _selectedFilter = "ALL";

  // filtring list
  List<InspectionItem> get _filteredInspections =>
      _inspections.where((item) {
        if (_selectedFilter == "ALL") return true;
        return item.status.toLowerCase() == _selectedFilter.toLowerCase();
      }).toList();



  @override
  void initState() {
    super.initState();
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
          "Inspection History",
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
              ["ALL", "APPROVED", "REJECTED"]
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
                          ? const Color(0xFF01A896)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: _selectedFilter == filter
                            ? Colors.white
                            : const Color(0xFF334155),
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

          Block(),

          Text(
            "RECENT INSPECTIONS",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

          Block(),

          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount:_filteredInspections.length,
            itemBuilder: (context, index) => InspectionCard(
              inspection: _filteredInspections[index],
            ),
          ),
        ],
        ),
      ),
    );
  }
}


class InspectionCard extends StatelessWidget {
  final InspectionItem inspection;

  const InspectionCard({super.key, required this.inspection});

  Color _statusColor() {
    switch (inspection.status) {
      case "APPROVED":
        return Color(0xFF047857);
      case "REJECTED":
        return Color(0xFFBE123C);
      default:
        return Colors.grey;
    }
  }

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
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: inspection.status == "APPROVED"? Color(0xFFD1FAE5):Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  inspection.status == "APPROVED"
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: _statusColor(),
                ),
              ),

              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection.batchNumber,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      inspection.date,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: inspection.status == "APPROVED"? Color(0xFFD1FAE5):Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  inspection.status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: _statusColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),


          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.description_outlined, size: 18),
              label: Text("View Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A896),

                foregroundColor:  Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InspectionItem {
  final String batchNumber;
  final String date;
  final String status;

  InspectionItem({
    required this.batchNumber,
    required this.date,
    required this.status,
  });

  factory InspectionItem.fromJson(Map<String, dynamic> json) {
    return InspectionItem(
      batchNumber: json["batch_number"],
      date: json["date"],
      status: json["status"],
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