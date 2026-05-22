import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class BatchReportPage extends StatefulWidget {
  final int batchId;
  final int id;
  const BatchReportPage({super.key, required this.id, required this.batchId});

  @override
  State<BatchReportPage> createState() => _BatchReportPageState();
}

class _BatchReportPageState extends State<BatchReportPage> {
  bool _isLoading = false;
  InspectionReport? _report;

  static Future<InspectionReport?> getInspectionReport(int batchId) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print("No token found");
        return null;
      }

      // ✅ تصحيح الرابط (إزالة الشرطة المائلة الزائدة)
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/inspections/$batchId/report"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("GET INSPECTION REPORT STATUS: ${response.statusCode}");
      print("GET INSPECTION REPORT RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return InspectionReport.fromJson(decoded);
      } else {
        print("Failed to get inspection report");
        return null;
      }
    } catch (e) {
      print("Error fetching inspection report: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
    });
    InspectionReport? report = await getInspectionReport(widget.id);
    setState(() {
      _report = report;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ التحقق من وجود البيانات قبل بناء الواجهة
    if (_report == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF0F172A),
          ),
          title: const Text(
            "Inspection Report",
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text("No data available")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0F172A),
        ),
        title: const Text(
          "Inspection Report",
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  _buildSummaryQuote(),
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
    // ✅ التحقق من وجود البيانات
    if (_report!.batchInformations == null) {
      return const SizedBox.shrink();
    }

    final batchInfo = _report!.batchInformations!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1ABFC8CD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _infoTile(
                batchInfo.fishName ?? 'N/A',
                '${batchInfo.batchId ?? "N/A"}',
                isMain: true,
              ),
              const SizedBox(width: 12),
              _infoTile("FISHER NAME", batchInfo.fishermanName ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoTile("CATCH DATE", _formatDate(batchInfo.dateCaught)),
              const SizedBox(width: 12),
              _infoTile(
                "INSPECTION DATE",
                batchInfo.getFormattedInspectionDate(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ دالة مساعدة لتنسيق التاريخ
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      return dateString.replaceFirst('T', ' ').substring(0, 16);
    } catch (e) {
      return dateString;
    }
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
              maxLines: 3,
              style: TextStyle(
                fontSize: 10,
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
                color: isMain
                    ? const Color(0xFF3F484C)
                    : const Color(0xFF191C1D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionDetailCard() {
    // ✅ التحقق من وجود البيانات
    if (_report!.inspectorDetails == null ||
        _report!.qualityInspection == null) {
      return const SizedBox.shrink();
    }

    final inspector = _report!.inspectorDetails!;
    final quality = _report!.qualityInspection!;

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
          _inspectorTile(
            inspector.vetName ?? 'Unknown',
            inspector.vetLicense ?? 'N/A',
            inspector.vetPhoto ?? '',
          ),
          const Block(),
          const Text(
            "Quality Inspection",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          _freshnessBar((quality.freshnessScore ?? 0).toDouble()),
          _qualityCard(Icons.air, "SMELL", quality.smell ?? 'N/A'),
          _qualityCard(
            Icons.visibility_outlined,
            "EYE CLARITY",
            quality.eyeClarity ?? 'N/A',
          ),
          _qualityCard(
            Icons.front_hand_outlined,
            "FLESH FIRMNESS",
            quality.fleshFirmness ?? 'N/A',
          ),
          _qualityCard(
            Icons.water_drop_outlined,
            "GILL COLOR",
            quality.gillColor ?? 'N/A',
          ),
          _qualityCard(
            Icons.thermostat,
            "TEMPERATURE",
            "${quality.internalTemperature ?? 0}°C",
          ),
          _qualityCard(
            Icons.bug_report,
            "PARASITES",
            (quality.parasitesPresent == true) ? "Present" : "Not Present",
          ),
        ],
      ),
    );
  }

  Widget _inspectorTile(String full_name, String ID, String picture) {
    // ✅ التحقق من صحة رابط الصورة
    final imageUrl = picture.isNotEmpty
        ? "http://localhost:3000/${picture.replaceFirst("src/", "")}"
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40), // ✅ شكل دائري
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 40, // ✅ العرض
                    height: 40, // ✅ الارتفاع
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.person_2_outlined,
                          color: Color(0xFFD5A439),
                          size: 40,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 40,
                        height: 40,
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_2_outlined,
                      color: Color(0xFFD5A439),
                      size: 40,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                full_name.isNotEmpty ? "Dr $full_name" : "Unknown",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF191C1D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ID != 'N/A' ? "ID LICENSE: $ID" : "No license",
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
              color: const Color(0x1A0C6780),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.signal_cellular_alt_outlined,
              color: Color(0xFFD5A439),
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
                      style: TextStyle(
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
                const SizedBox(height: 8),
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
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
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

  Widget _buildSummaryQuote() {
    // ✅ استخدام notes من التقرير
    final notes = _report?.notes ?? "No additional notes";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border(left: BorderSide(color: Color(0xFFD5A439), width: 4)),
      ),
      child: Text(
        notes,
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
        onPressed: () {
          print(widget.batchId);
          DownloadCer("${widget.id}", context);
        },
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
  Color _tmpColor = Colors.grey.shade300;

  // ✅ للرائحة (Smell)
  if (str.contains("Neutral") || str.contains("Sea-like")) {
    _tmpColor = const Color(0xFFD7FFE1);
  } else if (str.contains("Strong")) {
    _tmpColor = const Color(0xFFFFFCD7);
  } else if (str.contains("Sour") || str.contains("Ammonia")) {
    _tmpColor = const Color(0xFFFFD7D7);
  }

  // ✅ للون الخياشيم (Gill Color)
  if (str.contains("Bright Red")) {
    _tmpColor = const Color(0xFFD7FFE1);
  } else if (str.contains("Brownish") || str.contains("Dark Red")) {
    _tmpColor = const Color(0xFFFFFCD7);
  } else if (str.contains("Gray") ||
      str.contains("Green") ||
      str.contains("Black")) {
    _tmpColor = const Color(0xFFFFD7D7);
  } else if (str.contains("Not a Mesure")) {
    _tmpColor = const Color(0xFFF2F2F2);
  }

  // ✅ لقوام اللحم (Flesh Firmness)
  if (str.contains("Firm") && !str.contains("Slightly")) {
    _tmpColor = const Color(0xFFD7FFE1);
  } else if (str.contains("Slightly Soft")) {
    _tmpColor = const Color(0xFFFFFCD7);
  } else if (str.contains("Soft") && !str.contains("Slightly")) {
    _tmpColor = const Color(0xFFFFDFA0);
  } else if (str.contains("Mushy")) {
    _tmpColor = const Color(0xFFFFD7D7);
  }

  // ✅ لوضوح العين (Eye Clarity)
  if (str.contains("Clear") || str.contains("Bright")) {
    _tmpColor = const Color(0xFFD7FFE1);
  } else if (str.contains("Slightly Cloudy")) {
    _tmpColor = const Color(0xFFFFFCD7);
  } else if (str.contains("Cloudy") && !str.contains("Slightly")) {
    _tmpColor = const Color(0xFFFFDFA0);
  } else if (str.contains("Sunken") || str.contains("Opaque")) {
    _tmpColor = const Color(0xFFFFD7D7);
  }

  // ✅ لدرجة الحرارة (Temperature)
  if (str.contains("°C")) {
    try {
      double temp = double.parse(str.replaceAll("°C", "").trim());
      if (temp >= 0 && temp <= 4) {
        _tmpColor = const Color(0xFFD7FFE1);
      } else if (temp > 4 && temp <= 7) {
        _tmpColor = const Color(0xFFFFFCD7);
      } else if (temp > 7) {
        _tmpColor = const Color(0xFFFFD7D7);
      }
    } catch (e) {
      // إذا فشل التحويل، استخدم اللون الافتراضي
    }
  }

  // ✅ للطفيليات (Parasites)
  if (str.contains("Not Present")) {
    _tmpColor = const Color(0xFFD7FFE1);
  } else if (str.contains("Present")) {
    _tmpColor = const Color(0xFFFFD7D7);
  }

  return _tmpColor;
}

Future<void> DownloadCer(String id, BuildContext context) async {
  try {
    String? token = await _getToken();
    if (token == null) {
      print("No token found");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No token found"), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Downloading certificate..."),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }

    final response = await http.get(
      Uri.parse("http://localhost:3000/api/inspections/$id/certificate"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("DOWNLOAD STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      // ✅ حفظ الملف في Download folder على Android
      final directory = await getApplicationDocumentsDirectory();
      final downloadsPath = '${directory?.path}/Download';
      final downloadsDir = Directory(downloadsPath);
      
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      
      final file = File('$downloadsPath/certificate_$id.pdf');
      await file.writeAsBytes(response.bodyBytes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Saved to: ${file.path}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      print("File saved to: ${file.path}");
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print("Error: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}

class BatchInformations {
  final int? batchId;
  final String? fishName;
  final String? category;
  final double? quantityKg;
  final String? dateCaught;
  final String? fishermanName;
  final String? fishermanPhoto;
  final DateTime? inspectionDate;

  BatchInformations({
    this.batchId,
    this.fishName,
    this.category,
    this.quantityKg,
    this.dateCaught,
    this.fishermanName,
    this.fishermanPhoto,
    this.inspectionDate,
  });

  factory BatchInformations.fromJson(Map<String, dynamic> json) {
    return BatchInformations(
      batchId: json['batch_id'] as int?,
      fishName: json['fish_name'] as String?,
      category: json['category'] as String?,
      quantityKg: (json['quantity_kg'] as num?)?.toDouble(),
      dateCaught: json['date_caught'] as String?,
      fishermanName: json['fisherman_name'] as String?,
      fishermanPhoto: json['fisherman_photo'] as String?,
      inspectionDate: json['inspection_date'] != null
          ? DateTime.tryParse(json['inspection_date'])
          : null,
    );
  }

  String getFormattedCatchDate() {
    if (dateCaught == null) return 'N/A';
    try {
      return dateCaught!.replaceFirst('T', ' ').substring(0, 16);
    } catch (e) {
      return dateCaught!;
    }
  }

  String getFormattedInspectionDate() {
    if (inspectionDate == null) return 'N/A';
    return "${inspectionDate!.year}-${inspectionDate!.month}-${inspectionDate!.day} ${inspectionDate!.hour}:${inspectionDate!.minute}";
  }
}

// ✅ نموذج لتفاصيل المفتش
class InspectorDetails {
  final String? vetName;
  final String? vetLicense;
  final String? vetPhoto;

  InspectorDetails({this.vetName, this.vetLicense, this.vetPhoto});

  factory InspectorDetails.fromJson(Map<String, dynamic> json) {
    return InspectorDetails(
      vetName: json['vet_name'] as String?,
      vetLicense: json['vet_license'] as String?,
      vetPhoto: json['vet_photo'] as String?,
    );
  }

  String getVetPhotoUrl() {
    if (vetPhoto == null || vetPhoto!.isEmpty) return '';
    return "http://localhost:3000/${vetPhoto!.replaceFirst("src/", "")}";
  }
}

// ✅ نموذج لفحص الجودة
class QualityInspection {
  final int? freshnessScore;
  final String? smell;
  final String? eyeClarity;
  final String? fleshFirmness;
  final String? gillColor;
  final double? internalTemperature;
  final bool? parasitesPresent;

  QualityInspection({
    this.freshnessScore,
    this.smell,
    this.eyeClarity,
    this.fleshFirmness,
    this.gillColor,
    this.internalTemperature,
    this.parasitesPresent,
  });

  factory QualityInspection.fromJson(Map<String, dynamic> json) {
    bool? parasitesPresentValue;
    if (json['parasites_present'] != null) {
      if (json['parasites_present'] is bool) {
        parasitesPresentValue = json['parasites_present'];
      } else if (json['parasites_present'] is int) {
        parasitesPresentValue = json['parasites_present'] == 1;
      }
    }

    return QualityInspection(
      freshnessScore: json['freshness_score'] as int?,
      smell: json['smell'] as String?,
      eyeClarity: json['eye_clarity'] as String?,
      fleshFirmness: json['flesh_firmness'] as String?,
      gillColor: json['gill_color'] as String?,
      internalTemperature: (json['internal_temperature'] as num?)?.toDouble(),
      parasitesPresent: parasitesPresentValue,
    );
  }
}

// ✅ النموذج الرئيسي لتقرير الفحص
class InspectionReport {
  final BatchInformations? batchInformations;
  final InspectorDetails? inspectorDetails;
  final QualityInspection? qualityInspection;
  final String? notes;
  final String? decision;

  InspectionReport({
    this.batchInformations,
    this.inspectorDetails,
    this.qualityInspection,
    this.notes,
    this.decision,
  });

  factory InspectionReport.fromJson(Map<String, dynamic> json) {
    return InspectionReport(
      batchInformations: json['batch_informations'] != null
          ? BatchInformations.fromJson(json['batch_informations'])
          : null,
      inspectorDetails: json['inspector_details'] != null
          ? InspectorDetails.fromJson(json['inspector_details'])
          : null,
      qualityInspection: json['quality_inspection'] != null
          ? QualityInspection.fromJson(json['quality_inspection'])
          : null,
      notes: json['notes'] as String?,
      decision: json['decision'] as String?,
    );
  }

  Color get decisionColor {
    switch (decision?.toLowerCase()) {
      case 'approved':
        return const Color(0xFF047857);
      case 'rejected':
        return const Color(0xFFBE123C);
      default:
        return Colors.orange;
    }
  }

  String get decisionText {
    switch (decision?.toLowerCase()) {
      case 'approved':
        return 'APPROVED';
      case 'rejected':
        return 'REJECTED';
      default:
        return 'PENDING';
    }
  }
}
