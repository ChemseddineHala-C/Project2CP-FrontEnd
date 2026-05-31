import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../HOST.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<String?> _getToken() async {
  return await storage.read(key: "token");
}

class Addbatchpage extends StatefulWidget {
  const Addbatchpage({super.key});

  @override
  State<Addbatchpage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<Addbatchpage> {
  bool _isLoading = false;
  LatLng? _currentPosition;
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  bool _gpsActive = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _gpsActive = true;
      _markers = {
        Marker(
          markerId: MarkerId('my_location'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    });

    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 13),
      ),
    );
  }

  Future<void> _openInGoogleMaps() async {
    if (_currentPosition == null) return;

    final url =
        'https://www.google.com/maps/search/?api=1'
        '&query=${_currentPosition!.latitude},${_currentPosition!.longitude}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  //
  final Map<String, List<String>> _fishByCategory = {
    "Marine Fish": [
      "Sardin",
      "Tuna",
      "Dentex (Bream)",
      "Dorade (Sea Bream)",
      "Mackerel",
      "Sea Bass",
      "Sole",
      "Rockfish",
      "Grouper",
      "Garfish",
    ],
    "FreshWater Fish": ["Carp", "Tilapia", "Perch", "Catfish", "Barbel"],
    "Molluscs": ["Octopus", "Squid", "Cuttlefish (Sepia)", "Mussel", "Oyster"],
    "Crustaceans": [
      "Crab",
      "Shrimp",
      "Lobster",
      "Small Crabs",
      "Langoustine / Norway Lobster",
    ],
  };

  final List<String> _catchMethods = [
    "Rod / Line fishing",
    "Net Fishing",
    "Spearfishing",
    "Trolling",
  ];

  String? _selectedCategory;
  String? _selectedFish;
  bool _isOtherFish = false;
  TextEditingController _otherFishController = TextEditingController();
  String? _selectedCatchMethod;
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  //image
  List<File> _photos = [];
  //
  Future<void> _addPhoto() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _photos.add(File(result.files.single.path!));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Photo added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static MediaType _getMediaType(File file) {
    String path = file.path.toLowerCase();
    if (path.endsWith('.png')) {
      return MediaType('image', 'png');
    } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    } else if (path.endsWith('.pdf')) {
      return MediaType('application', 'pdf');
    } else {
      return MediaType('application', 'octet-stream');
    }
  }

  Future<void> _addBatch() async {

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS location not available'),backgroundColor: Colors.red,)
      );
      return;
    }

    if (_selectedCategory == null ||
        (_selectedFish == null && !_isOtherFish) ||
        _selectedCatchMethod == null ||
        _quantityController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all required fields and add at least one photo",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception("No token found. Please login again.");
      }

      final fishName = _isOtherFish
          ? _otherFishController.text
          : _selectedFish ?? "";

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://$HOST:3000/api/batches"),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['category'] = _selectedCategory ?? "";
      request.fields['fish_name'] = fishName;
      request.fields['catch_method'] = _selectedCatchMethod ?? "";
      request.fields['quantity_kg'] = _quantityController.text;
      request.fields['price_per_kg'] = _priceController.text;
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();
      request.fields['additional_notes'] = _notesController.text;
      request.fields['date_caught'] = DateTime.now().toString();

      for (File photo in _photos) {
        if (await photo.exists()) {
          var multipartFile = await http.MultipartFile.fromPath(
            'batch_photo',
            photo.path,
            contentType: _getMediaType(photo),
          );
          request.files.add(multipartFile);
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Batch submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("message: ${jsonDecode(response.body)['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _otherFishController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _photos.clear();
    super.dispose();
  }

  //
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
          "Add Batch",
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
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubTitle(
                    subTitle: "BATCH DETAILS",
                    icon: Icons.sailing_outlined,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Category",
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 7),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _fishByCategory.keys
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _selectedFish = null;
                        _isOtherFish = false;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFFFFFFF),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    hint: Text(
                      "Select Category",
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Block(),
                  Text(
                    "Fish name",
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 7),
                  DropdownButtonFormField<String>(
                    value: _selectedFish,
                    items: [
                      ...?_fishByCategory[_selectedCategory]
                          ?.map(
                            (fish) => DropdownMenuItem(
                              value: fish,
                              child: Text(fish),
                            ),
                          )
                          .toList(),
                      DropdownMenuItem(
                        value: "Other",
                        child: Text(
                          "Other - Enter the name ..",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFish = value;
                        _isOtherFish = value == "Other";
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      filled: true,
                      fillColor: Color(0xFFFFFFFF),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    hint: Text(
                      "e.g. Lacha",
                      style: TextStyle(
                        color: Color(0xFFA8A8A8),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Color(0xFFA8A8A8),
                    ),
                  ),
                  //
                  if (_isOtherFish) ...[
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _otherFishController,
                      decoration: InputDecoration(
                        hintText: "Enter fish name...",
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                  //
                  Block(),
                  Text(
                    "Catch Method",
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 7),
                  DropdownButtonFormField<String>(
                    value: _selectedCatchMethod,
                    items: _catchMethods
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCatchMethod = value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFFFFFFF),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    hint: Text(
                      "Select Catch Method",
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Color(0xFF0F172A),
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
                              "Quantity (kg)",
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 7),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                filled: true,
                                fillColor: Color(0xFFFFFFFF),
                                hintText: "0.00",
                                hintStyle: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price (per kg)",
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 7),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                filled: true,
                                fillColor: Color(0xFFFFFFFF),
                                hintText: "0.00 DA",
                                hintStyle: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SubTitle(subTitle: "PHOTO", icon: Icons.camera_alt_outlined),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _addPhoto,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFFE2E8F0),
                                style: BorderStyle.solid,
                              ),
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            height: 100.33,
                            width: 111.33,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    "ADD PHOTO",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        ..._photos.asMap().entries.map((entry) {
                          int index = entry.key;
                          File photo = entry.value;

                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 5,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    photo,
                                    width: 100,
                                    height: 98,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _photos.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubTitle(
                        subTitle: "CATCH LOCATION",
                        icon: Icons.location_on,
                      ),
                      if (_gpsActive)
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color(0xFFDCFCE7),
                          ),
                          child: Text(
                            "GPS ACTIVE",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ////
                  ///
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
                        child: _currentPosition == null
                            ? Center(child: CircularProgressIndicator())
                            : Stack( children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _currentPosition!,
                                  zoom: 13,
                                ),
                                onMapCreated: (controller) {
                                  _mapController.complete(controller);
                                },
                                markers: _markers,
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                scrollGesturesEnabled: false,
                                zoomGesturesEnabled: false,
                                rotateGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _openInGoogleMaps,
                                  ),
                                ) 
                              ),
                              ]),
                      ),
                    ),
                  ),

                  ////// FOR MAP
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      filled: true,
                      fillColor: Color(0xFFFFFFFF),
                      hintText: "Gear used, or weather\n conditions...",
                      hintStyle: TextStyle(
                        color: Color(0xFF6B7280),
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 56,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _addBatch(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF023E77),
                              foregroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              alignment: Alignment.center,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Submit Batch",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.send, size: 20),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class Block extends StatelessWidget {
  const Block({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 12);
  }
}

class SubTitle extends StatelessWidget {
  final String? subTitle;
  final IconData? icon;

  const SubTitle({super.key, this.subTitle, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF023E77)),
        SizedBox(width: 5),
        Text(
          "$subTitle",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}


