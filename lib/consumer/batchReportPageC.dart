import 'package:flutter/material.dart';

class BatchReportPage extends StatefulWidget {
  const BatchReportPage({super.key});

  @override
  State<BatchReportPage> createState() => _BatchReportPageState();
}

class _BatchReportPageState extends State<BatchReportPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("Batch Informations"),
            const SizedBox(height: 10),
            _buildBatchHeaderCard(),
            const Block(),
            _sectionLabel("Inspection Details"),
            const SizedBox(height: 10),
            _buildInspectionDetailCard(),
            const Block(),
            _buildSummaryQuote("hello"),
            const Block(),
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF191C1D),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildBatchHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0x1ABFC8CD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _infoTile("N/A", "N/A", isMain: true),
              const SizedBox(width: 12),
              _infoTile("FISHER NAME", "N/A"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoTile("CATCH DATE", "N/A"),
              const SizedBox(width: 12),
              _infoTile("INSPECTION DATE", "N/A"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, {bool isMain = false}) {
    return Expanded(
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isMain ? Colors.white : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isMain ? 18 : 10,
                fontWeight: FontWeight.w800,
                color: isMain
                    ? const Color(0xFFD5A439)
                    : const Color(0xFF6F787D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isMain ? Color(0xFF3F484C) : Color(0xFF191C1D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionDetailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Inspector Details",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          _inspectorTile("Dr Ahmed Nacer", "#MAR-5542", "images/fish1.png"),
          Block(),
          const Text(
            "Quality Inspection",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          _freshnessBar(45),
          _qualityCard(Icons.air, "SMELL", "Neutral / Sea-like"),
          _qualityCard(Icons.visibility_outlined, "EYE CLARITY", "b"),
          _qualityCard(Icons.front_hand_outlined, "FLESH FIRMNESS", "c"),
          _qualityCard(Icons.water_drop_outlined, "GILL COLOR", "d"),
          _qualityCard(Icons.thermostat, "TEMPERATURE", "e"),
        ],
      ),
    );
  }

  Widget _inspectorTile(String full_name, String ID, String picture) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person_2_outlined, color: Color(0xFFD5A439)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dr $full_name",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF191C1D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "ID LICENSE: $ID",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF6F787D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _freshnessBar(double score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Color(0x1A0C6780),
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.signal_cellular_alt_outlined,
              color: const Color(0xFFD5A439),
              size: 18,
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
                    Text(
                      "freshness_score".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6F787D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "${score.toInt()}/100",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD5A439),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: const Color(0xFFD5A439),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualityCard(IconData icon, String data1, String data2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Color(0x1A0C6780),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD5A439), size: 18),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data1,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6F787D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  data2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF191C1D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(radius: 5, backgroundColor: _pointColor(data2)),
        ],
      ),
    );
  }

  Widget _buildSummaryQuote(String summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border(left: BorderSide(color: Color(0xFFD5A439), width: 4)),
      ),
      child: Text(
        summary,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontStyle: FontStyle.italic,
          color: Color(0xFF3F484C),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text(
          "Download Certificate (PDF)",
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
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
    );
  }
}

// Re-using your Block widget for consistency
class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}

Color _pointColor(String str) {
  Color _tmpColor = Colors.black;
  switch (str) {
    case "Neutral / Sea-like":
      _tmpColor = Color(0xFFD7FFE1);
      break;
    case "Strong":
      _tmpColor = Color(0xFFFFFCD7);
      break;
    case "Sour / Ammonia-like":
      _tmpColor = Color(0xFFFFD7D7);
      break;
  }

  switch (str) {
    case "Bright Red":
      _tmpColor = Color(0xFFD7FFE1);
      break;
    case "Brownish / Dark Red":
      _tmpColor = Color(0xFFFFFCD7);
      break;
    case "Gray / Green / Black":
      _tmpColor = Color(0xFFFFD7D7);
      break;
    case "Not a Mesure ..":
      _tmpColor = Color(0xFFF2F2F2);
      break;
  }

  switch (str) {
    case "Firm":
      _tmpColor = Color(0xFFD7FFE1);
      break;
    case "Slightly Soft":
      _tmpColor = Color(0xFFFFFCD7);
      break;
    case "Soft":
      _tmpColor = Color(0xFFFFDFA0);
      break;
    case "Mushy":
      _tmpColor = Color(0xFFFFD7D7);
  }

  switch (str) {
    case "Clear / Bright":
      _tmpColor = Color(0xFFD7FFE1);
      break;
    case "Slightly Cloudy":
      _tmpColor = Color(0xFFFFFCD7);
      break;
    case "Cloudy":
      _tmpColor = Color(0xFFFFDFA0);
      break;
    case "Sunken / Opaque":
      _tmpColor = Color(0xFFFFD7D7);
  }

  // double? value = double.parse(str);
  // if (value != null){
  //   _tmpColor = (value > -1 && value < 4) ? Color(0xFFD7FFE1) : Color(0xFFFFD7D7) ;
  // }

  return _tmpColor;
}
