import 'package:fishapp/vitirinaire/failedverfc.dart';
import 'package:fishapp/vitirinaire/succesverfc.dart';
import './object.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class vetInspectionPage extends StatefulWidget {
  final FishBatchWithFisherman batch;
  const vetInspectionPage({super.key, required this.batch});

  @override
  State<vetInspectionPage> createState() => _VetInspectionPageState();
}

class _VetInspectionPageState extends State<vetInspectionPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  late LatLng    _catchLocation;
  late Set<Marker> _markers;

  Future<void> _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1'
                '&query=${widget.batch.latitude},${widget.batch.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();

    _catchLocation = LatLng(widget.batch.latitude!, widget.batch.longitude!);

    _markers = {
      Marker(
        markerId: MarkerId('catch_location'),
        position: _catchLocation,
        infoWindow: InfoWindow(title: 'Catch Location'),
      )
    };
  }
  //variables
  String? _selectedSmell;
  String? _selectedGillColor;
  String? _selectedFleshFirmness;
  String? _selectedEyeClarity;
  bool _parasitesPresent = false;
  double _internalTemp = 00;
  int get _freshnessScore => _calculateScore();
  TextEditingController _tempController = TextEditingController(text: "00");

  final List<String> _smellOptions = [
    "Neutral / Sea-like",
    "Strong",
    "Sour / Ammonia-like",
  ];

  final List<String> _gillColorOptions = [
    "Bright Red",
    "Brownish / Dark Red",
    "Gray / Green / Black",
    "Not a Mesure ..",
  ];

  final List<String> _fleshFirmnessOptions = [
    "Firm",
    "Slightly Soft",
    "Soft",
    "Mushy",
  ];

  final List<String> _eyeClarityOptions = [
    "Clear / Bright",
    "Slightly Cloudy",
    "Cloudy",
    "Sunken / Opaque",
  ];

  int _calculateScore() {
    int score = 0;

    switch (_selectedSmell) {
      case "Neutral / Sea-like":
        score += 16;
        break;
      case "Strong":
        score += 10;
        break;
      case "Sour / Ammonia-like":
        score += 5;
        break;
      default:
        score += 0;
    }

    switch (_selectedGillColor) {
      case "Bright Red":
        score += 16;
        break;
      case "Brownish / Dark Red":
        score += 10;
        break;
      case "Gray / Green / Black":
        score += 5;
        break;
      case "Not a Mesure ..":
        score += 5;
        break;
      default:
        score += 0;
    }

    switch (_selectedFleshFirmness) {
      case "Firm":
        score += 16;
        break;
      case "Slightly Soft":
        score += 10;
        break;
      case "Soft":
        score += 5;
        break;
      case "Mushy":
        score += 3;
      default:
        score += 0;
    }

    switch (_selectedEyeClarity) {
      case "Clear / Bright":
        score += 16;
        break;
      case "Slightly Cloudy":
        score += 10;
        break;
      case "Cloudy":
        score += 5;
        break;
      case "Sunken / Opaque":
        score += 3;
      default:
        score += 0;
    }

    _parasitesPresent ? score += 0 : score += 20;

    (_internalTemp > -1 && _internalTemp < 4) ? score += 14 : score += 5;

    return score.clamp(0, 100);
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
          "Vet Inspection",
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0x0F68E61A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF00A896),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Batch ID: ${widget.batch.id}",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Capt. ${widget.batch.fishermanName} • Fishtype: ${widget.batch.fishName}",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Block(),
            subTitle('CATCH LOCATION'),
            GestureDetector(
              onTap: _openInGoogleMaps,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _catchLocation,
                      zoom:   12
                    ),
                    onMapCreated: (controller) {
                      _mapController.complete(controller);
                    },
                    markers:                _markers,
                    zoomControlsEnabled:    false,
                    myLocationButtonEnabled: false,
                    scrollGesturesEnabled:  false,
                    zoomGesturesEnabled:    false,
                    rotateGesturesEnabled:  false,
                    tiltGesturesEnabled:    false,
                  ),
                ),
              ),
            ),
            Block(),
            subTitle('BATCH PHOTOS'),
            SizedBox(height: 10),
            (widget.batch.photo == null || widget.batch.photo!.isEmpty)
                ? const Text("No photos available")
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.batch.photo!
                          .map(
                            (path) => Row(
                              children: [
                                _buildFishImage(path),
                                if (widget.batch.photo!.last != path)
                                  const SizedBox(width: 10),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),

            Block(),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Physical Assessment",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),

                  Block(),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Smell",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedSmell,
                              hint: Text("Select"),
                              items: _smellOptions
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedSmell = value),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _selectedSmell == null
                                    ? Colors.white
                                    : _selectedSmell == _smellOptions[0]
                                    ? Color(0xFFD7FFE1)
                                    : _selectedSmell == _smellOptions[1]
                                    ? Color(0xFFFFFCD7)
                                    : Color(0xFFFFD7D7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gill Color",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedGillColor,
                              hint: Text("Select"),
                              items: _gillColorOptions
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedGillColor = value),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _selectedGillColor == null
                                    ? Colors.white
                                    : _selectedGillColor == _gillColorOptions[0]
                                    ? Color(0xFFD7FFE1)
                                    : _selectedGillColor == _gillColorOptions[1]
                                    ? Color(0xFFFFFCD7)
                                    : _selectedGillColor == _gillColorOptions[2]
                                    ? Color(0xFFFFD7D7)
                                    : Color(0xFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Block(),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Flesh Firmness",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedFleshFirmness,
                              hint: Text("Select"),
                              items: _fleshFirmnessOptions
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(
                                () => _selectedFleshFirmness = value,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _selectedFleshFirmness == null
                                    ? Colors.white
                                    : _selectedFleshFirmness ==
                                          _fleshFirmnessOptions[0]
                                    ? Color(0xFFD7FFE1)
                                    : _selectedFleshFirmness ==
                                          _fleshFirmnessOptions[1]
                                    ? Color(0xFFFFFCD7)
                                    : _selectedFleshFirmness ==
                                          _fleshFirmnessOptions[2]
                                    ? Color(0xFFFFDFA0)
                                    : Color(0xFFFFD7D7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Eye Clarity",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedEyeClarity,
                              hint: Text("Select"),
                              items: _eyeClarityOptions
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedEyeClarity = value),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _selectedEyeClarity == null
                                    ? Colors.white
                                    : _selectedEyeClarity ==
                                          _eyeClarityOptions[0]
                                    ? Color(0xFFD7FFE1)
                                    : _selectedEyeClarity ==
                                          _eyeClarityOptions[1]
                                    ? Color(0xFFFFFCD7)
                                    : _selectedEyeClarity ==
                                          _eyeClarityOptions[2]
                                    ? Color(0xFFFFDFA0)
                                    : Color(0xFFFFD7D7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Block(),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Internal Temperature (°C)",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 6),
                            TextFormField(
                              controller: _tempController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(
                                () => _internalTemp = double.parse(value),
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFF8FAFC),
                                suffixIcon: Icon(
                                  Icons.thermostat,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Parasites Present",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _parasitesPresent = true,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 17,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _parasitesPresent
                                            ? Color(0x0F68E61A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _parasitesPresent
                                              ? Color(0xFF00A896)
                                              : Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(
                                            color: _parasitesPresent
                                                ? Color(0xFF00A896)
                                                : Color(0xFF0F172A),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _parasitesPresent = false,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 17,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !_parasitesPresent
                                            ? Color(0x0F68E61A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: !_parasitesPresent
                                              ? Color(0xFF00A896)
                                              : Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "No",
                                          style: TextStyle(
                                            color: !_parasitesPresent
                                                ? Color(0xFF00A896)
                                                : Color(0xFF0F172A),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
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

                  Block(),

                  Row(
                    children: [
                      Text(
                        "Overall Freshness Score",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Spacer(),
                      Text(
                        _freshnessScore > 0 ? "$_freshnessScore/100" : "--/100",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF00A896),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearPercentIndicator(
                    percent: _freshnessScore / 100,
                    lineHeight: 10,
                    backgroundColor: Color(0xFFE2E8F0),
                    progressColor: Color(0xFF00A896),
                    barRadius: Radius.circular(8),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "POOR",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "EXCELLENT",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  Block(),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {

                            if (_selectedSmell == null ||
                                _selectedGillColor == null ||
                                _selectedFleshFirmness == null ||
                                _selectedEyeClarity == null ||
                                _tempController.text.isEmpty || double.tryParse(_tempController.text) == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please complete all quality inspection fields"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }  

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FailedvetPage(
                                  batch: widget.batch,
                                  op1: _selectedSmell!,
                                  op2: _selectedGillColor!,
                                  op3: _selectedFleshFirmness!,
                                  op4: _selectedEyeClarity!,
                                  op5: double.parse(_tempController.text),
                                  op6: _parasitesPresent,
                                  op7: _freshnessScore,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.cancel_outlined),
                          label: Text(
                            "Reject",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Color(0xFFEF4444),
                            elevation: 5,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            
                            if (_selectedSmell == null ||
                                _selectedGillColor == null ||
                                _selectedFleshFirmness == null ||
                                _selectedEyeClarity == null ||
                                _tempController.text.isEmpty || double.tryParse(_tempController.text) == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please complete all quality inspection fields"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuccessedVetPage(
                                  batch: widget.batch,
                                  op1: _selectedSmell!,
                                  op2: _selectedGillColor!,
                                  op3: _selectedFleshFirmness!,
                                  op4: _selectedEyeClarity!,
                                  op5: double.parse(_tempController.text),
                                  op6: _parasitesPresent,
                                  op7: _freshnessScore,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.check_circle_outline),
                          label: Text(
                            "Approve",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Color(0xFF10B981),
                            elevation: 5,
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

// class VetInspection {
//   final String batchId;
//   final String captainName;
//   final String vesselName;
//   final double latitude;
//   final double longitude;
//   final List<String> photos;
//   String? smell;
//   String? gillColor;
//   String? fleshFirmness;
//   bool? parasitesPresent;
//   double? internalTemp;

//   VetInspection({
//     required this.batchId,
//     required this.captainName,
//     required this.vesselName,
//     required this.latitude,
//     required this.longitude,
//     required this.photos,
//     this.smell,
//     this.gillColor,
//     this.fleshFirmness,
//     this.parasitesPresent,
//     this.internalTemp,
//   });
// }

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}

Widget subTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Color(0xFF94A3B8),
    ),
  );
}

Widget _buildFishImage(String? path) {
  if (path == null || path.isEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.asset(
        "images/grey.jpg",
        width: 139,
        height: 127,
        fit: BoxFit.cover,
      ),
    );
  }

  final imageUrl = "http://192.168.1.94:3000${path.replaceFirst('src', '')}";

  return ClipRRect(
    borderRadius: BorderRadius.circular(13),
    child: Image.network(
      imageUrl,
      width: 139,
      height: 127,
      fit: BoxFit.cover,
      // errorBuilder: (context, error, stackTrace) =>
      //   Image.asset(
      //     "images/grey.jpg",
      //     width: 139,
      //     height: 127,
      //     fit: BoxFit.cover,
      //   ),
    ),
  );
}
