import 'dart:io';
import 'package:fishapp/picheur/picheur_Api.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Addbatchpage extends StatefulWidget {
  const Addbatchpage({super.key});

  @override
  State<Addbatchpage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<Addbatchpage> {
  BatchModel? _batch;
  bool _isLoading = false;
  String _error = "";

  Future<void> _getBatchDetails() async {
    setState(() => _isLoading = true);

    try {
      final data = await ApiService.get("/api/batches/widget.batchId"); //${widget.batchId}
      setState(() {
        _batch = BatchModel.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitBatch() async {
    setState(() => _isLoading = true);

    try {
      final fishName = _isOtherFish
          ? _otherFishController.text
          : _selectedFish ?? "";

      await ApiService.postMultipart(
        "/api/batches",
        {
          "category"     : _selectedCategory ?? "",
          "fish_name"    : fishName,
          "catch_method" : _selectedCatchMethod ?? "",
          "quantity"     : _quantityController.text,
          "price"        : _priceController.text,
          "latitude"     : _currentPosition?.latitude.toString() ?? "",
          "longitude"    : _currentPosition?.longitude.toString() ?? "",
          "notes"        : _notesController.text,
        },
        _photos,
        "photos",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Batch submitted successfully!")),
      );
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => _isLoading = false);
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

  //
  //GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _locationLoaded = false;

  //
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _locationLoaded = true;
    });
  }

  //image
  List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
  //
  Future<void> _addPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getBatchDetails();
  }

  //
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text(_error));
    if (_batch == null) return SizedBox();
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubTitle(subTitle: "BATCH DETAILS", icon: Icons.sailing_outlined),
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
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
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
                  borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
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
                      (fish) =>
                      DropdownMenuItem(value: fish, child: Text(fish)),
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
                  borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
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
                    (method) =>
                    DropdownMenuItem(value: method, child: Text(method)),
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
                  borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
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
                SubTitle(subTitle: "CATCH LOCATION", icon: Icons.location_on),
                if (_locationLoaded)
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
            GestureDetector(
              onTap: () => print("hello"),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: _locationLoaded
                      ? GestureDetector(
                    onTap: () => {print("map")},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(
                        "https://maps.googleapis.com/maps/api/staticmap"
                            "?center=${_currentPosition!.latitude},${_currentPosition!.longitude}"
                            "&zoom=14&size=400x200"
                            "&markers=${_currentPosition!.latitude},${_currentPosition!.longitude}"
                            "&key=YOUR_API_KEY",
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : Container(
                    color: Color(0xFFF5F7F9),
                    child: Center(child: CircularProgressIndicator()),
                  ),
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
                  borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
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
                children: [
                  Container(
                    height: 56,
                    width: 389,
                    child: ElevatedButton(
                      onPressed: () => _submitBatch(),
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
                  Container(
                    height: 56,
                    width: 389,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA8A8A8),
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
                            "Save as Draft",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.drafts_outlined, size: 18),
                        ],
                      ),
                    ),
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

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class Addbatchpage extends StatefulWidget {
//   const Addbatchpage({super.key});
//
//   @override
//   State<Addbatchpage> createState() => _AddBatchPageState();
// }
//
// class _AddBatchPageState extends State<Addbatchpage> {
//   BatchModel? _batch;
//   bool _isLoading = false;
//   String _error = "";
//
//   Future<void> _getBatchDetails() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final data = await ApiService.get("/api/batches/widget.batchId"); //${widget.batchId}
//       setState(() {
//         _batch = BatchModel.fromJson(data);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _submitBatch() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final fishName = _isOtherFish
//           ? _otherFishController.text
//           : _selectedFish ?? "";
//
//       await ApiService.postMultipart(
//         "/api/batches",
//         {
//           "category"     : _selectedCategory ?? "",
//           "fish_name"    : fishName,
//           "catch_method" : _selectedCatchMethod ?? "",
//           "quantity"     : _quantityController.text,
//           "price"        : _priceController.text,
//           "latitude"     : _currentPosition?.latitude.toString() ?? "",
//           "longitude"    : _currentPosition?.longitude.toString() ?? "",
//           "notes"        : _notesController.text,
//         },
//         _photos,
//         "photos",
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Batch submitted successfully!")),
//       );
//       Navigator.pop(context);
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     }
//
//     setState(() => _isLoading = false);
//   }
//
//   //
//   final Map<String, List<String>> _fishByCategory = {
//     "Marine Fish": [
//       "Sardin",
//       "Tuna",
//       "Dentex (Bream)",
//       "Dorade (Sea Bream)",
//       "Mackerel",
//       "Sea Bass",
//       "Sole",
//       "Rockfish",
//       "Grouper",
//       "Garfish",
//     ],
//     "FreshWater Fish": ["Carp", "Tilapia", "Perch", "Catfish", "Barbel"],
//     "Molluscs": ["Octopus", "Squid", "Cuttlefish (Sepia)", "Mussel", "Oyster"],
//     "Crustaceans": [
//       "Crab",
//       "Shrimp",
//       "Lobster",
//       "Small Crabs",
//       "Langoustine / Norway Lobster",
//     ],
//   };
//
//   final List<String> _catchMethods = [
//     "Rod / Line fishing",
//     "Net Fishing",
//     "Spearfishing",
//     "Trolling",
//   ];
//
//   String? _selectedCategory;
//   String? _selectedFish;
//   bool _isOtherFish = false;
//   TextEditingController _otherFishController = TextEditingController();
//   String? _selectedCatchMethod;
//   TextEditingController _quantityController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();
//   TextEditingController _notesController = TextEditingController();
//
//   //
//   //GoogleMapController? _mapController;
//   LatLng? _currentPosition;
//   bool _locationLoaded = false;
//
//   //
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;
//
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever)
//       return;
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     setState(() {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//       _locationLoaded = true;
//     });
//   }
//
//   //image
//   List<File> _photos = [];
//   final ImagePicker _picker = ImagePicker();
//   //
//   Future<void> _addPhoto() async {
//     final XFile? image = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (image != null) {
//       setState(() {
//         _photos.add(File(image.path));
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _getBatchDetails();
//   }
//
//   //
//   Widget build(BuildContext context) {
//     if (_isLoading) return Center(child: CircularProgressIndicator());
//     if (_error.isNotEmpty) return Center(child: Text(_error));
//     if (_batch == null) return SizedBox();
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F7F9),
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {},
//           icon: Icon(Icons.arrow_back),
//           color: Color(0xFF0F172A),
//         ),
//         title: Text(
//           "Add Batch",
//           style: TextStyle(
//             color: Color(0xFF0F172A),
//             fontFamily: "Inter",
//             fontWeight: FontWeight.w700,
//             fontSize: 24,
//             letterSpacing: -0.6,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SubTitle(subTitle: "BATCH DETAILS", icon: Icons.sailing_outlined),
//             SizedBox(height: 20),
//             Text(
//               "Category",
//               style: TextStyle(
//                 color: Color(0xFF334155),
//                 fontFamily: "Inter",
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//             SizedBox(height: 7),
//             DropdownButtonFormField<String>(
//               value: _selectedCategory,
//               items: _fishByCategory.keys
//                   .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
//                   .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCategory = value;
//                   _selectedFish = null;
//                   _isOtherFish = false;
//                 });
//               },
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Color(0xFFFFFFFF),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(13),
//                   borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
//                 ),
//               ),
//               hint: Text(
//                 "Select Category",
//                 style: TextStyle(
//                   color: Color(0xFF0F172A),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16,
//                 ),
//               ),
//               icon: Icon(
//                 Icons.keyboard_arrow_down_outlined,
//                 color: Color(0xFF0F172A),
//               ),
//             ),
//             Block(),
//             Text(
//               "Fish name",
//               style: TextStyle(
//                 color: Color(0xFF334155),
//                 fontFamily: "Inter",
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//             SizedBox(height: 7),
//             DropdownButtonFormField<String>(
//               value: _selectedFish,
//               items: [
//                 ...?_fishByCategory[_selectedCategory]
//                     ?.map(
//                       (fish) =>
//                       DropdownMenuItem(value: fish, child: Text(fish)),
//                 )
//                     .toList(),
//                 DropdownMenuItem(
//                   value: "Other",
//                   child: Text(
//                     "Other - Enter the name ..",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _selectedFish = value;
//                   _isOtherFish = value == "Other";
//                 });
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(13),
//                 ),
//                 filled: true,
//                 fillColor: Color(0xFFFFFFFF),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(13),
//                   borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
//                 ),
//               ),
//               hint: Text(
//                 "e.g. Lacha",
//                 style: TextStyle(
//                   color: Color(0xFFA8A8A8),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16,
//                 ),
//               ),
//               icon: Icon(
//                 Icons.keyboard_arrow_down_outlined,
//                 color: Color(0xFFA8A8A8),
//               ),
//             ),
//             //
//             if (_isOtherFish) ...[
//               SizedBox(height: 8),
//               TextFormField(
//                 controller: _otherFishController,
//                 decoration: InputDecoration(
//                   hintText: "Enter fish name...",
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ],
//             //
//             Block(),
//             Text(
//               "Catch Method",
//               style: TextStyle(
//                 color: Color(0xFF334155),
//                 fontFamily: "Inter",
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//             SizedBox(height: 7),
//             DropdownButtonFormField<String>(
//               value: _selectedCatchMethod,
//               items: _catchMethods
//                   .map(
//                     (method) =>
//                     DropdownMenuItem(value: method, child: Text(method)),
//               )
//                   .toList(),
//               onChanged: (value) {
//                 setState(() => _selectedCatchMethod = value);
//               },
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Color(0xFFFFFFFF),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(13),
//                   borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
//                 ),
//               ),
//               hint: Text(
//                 "Select Catch Method",
//                 style: TextStyle(
//                   color: Color(0xFF0F172A),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16,
//                 ),
//               ),
//               icon: Icon(
//                 Icons.keyboard_arrow_down_outlined,
//                 color: Color(0xFF0F172A),
//               ),
//             ),
//             Block(),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Quantity (kg)",
//                         style: TextStyle(
//                           color: Color(0xFF334155),
//                           fontFamily: "Inter",
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                       ),
//                       SizedBox(height: 7),
//                       TextFormField(
//                         controller: _quantityController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(13),
//                             borderSide: BorderSide(
//                               width: 1.5,
//                               color: Color(0xFFE2E8F0),
//                             ),
//                           ),
//                           filled: true,
//                           fillColor: Color(0xFFFFFFFF),
//                           hintText: "0.00",
//                           hintStyle: TextStyle(
//                             color: Color(0xFF6B7280),
//                             fontFamily: "Inter",
//                             fontWeight: FontWeight.w400,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 15),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Price (per kg)",
//                         style: TextStyle(
//                           color: Color(0xFF334155),
//                           fontFamily: "Inter",
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                       ),
//                       SizedBox(height: 7),
//                       TextFormField(
//                         controller: _priceController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(13),
//                             borderSide: BorderSide(
//                               width: 1.5,
//                               color: Color(0xFFE2E8F0),
//                             ),
//                           ),
//                           filled: true,
//                           fillColor: Color(0xFFFFFFFF),
//                           hintText: "0.00 DA",
//                           hintStyle: TextStyle(
//                             color: Color(0xFF6B7280),
//                             fontFamily: "Inter",
//                             fontWeight: FontWeight.w400,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             SubTitle(subTitle: "PHOTO", icon: Icons.camera_alt_outlined),
//             SizedBox(height: 10),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: _addPhoto,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Color(0xFFE2E8F0),
//                           style: BorderStyle.solid,
//                         ),
//                         color: Color(0xFFFFFFFF),
//                         borderRadius: BorderRadius.circular(13),
//                       ),
//                       height: 100.33,
//                       width: 111.33,
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add_a_photo_outlined,
//                               color: Color(0xFF94A3B8),
//                             ),
//                             SizedBox(height: 3),
//                             Text(
//                               "ADD PHOTO",
//                               style: TextStyle(
//                                 color: Color(0xFF94A3B8),
//                                 fontFamily: "Inter",
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 5),
//                   ..._photos.asMap().entries.map((entry) {
//                     int index = entry.key;
//                     File photo = entry.value;
//
//                     return Stack(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.symmetric(
//                             vertical: 0,
//                             horizontal: 5,
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.file(
//                               photo,
//                               width: 100,
//                               height: 98,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           top: 4,
//                           right: 12,
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _photos.removeAt(index);
//                               });
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 Icons.close,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SubTitle(subTitle: "CATCH LOCATION", icon: Icons.location_on),
//                 if (_locationLoaded)
//                   Container(
//                     padding: EdgeInsets.all(3),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       color: Color(0xFFDCFCE7),
//                     ),
//                     child: Text(
//                       "GPS ACTIVE",
//                       style: TextStyle(
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 10,
//                         color: Color(0xFF15803D),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             SizedBox(height: 10),
//             GestureDetector(
//               onTap: () => print("hello"),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: SizedBox(
//                   height: 180,
//                   width: double.infinity,
//                   child: _locationLoaded
//                       ? GestureDetector(
//                     onTap: () => {print("map")},
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(13),
//                       child: Image.network(
//                         "https://maps.googleapis.com/maps/api/staticmap"
//                             "?center=${_currentPosition!.latitude},${_currentPosition!.longitude}"
//                             "&zoom=14&size=400x200"
//                             "&markers=${_currentPosition!.latitude},${_currentPosition!.longitude}"
//                             "&key=YOUR_API_KEY",
//                         width: double.infinity,
//                         height: 180,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   )
//                       : Container(
//                     color: Color(0xFFF5F7F9),
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//                 ),
//               ),
//             ),
//             ////// FOR MAP
//             SizedBox(height: 15),
//             TextFormField(
//               controller: _notesController,
//               maxLines: 2,
//               minLines: 1,
//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(13),
//                   borderSide: BorderSide(width: 1.5, color: Color(0xFFE2E8F0)),
//                 ),
//                 filled: true,
//                 fillColor: Color(0xFFFFFFFF),
//                 hintText: "Gear used, or weather\n conditions...",
//                 hintStyle: TextStyle(
//                   color: Color(0xFF6B7280),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             SizedBox(height: 15),
//             Container(
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 children: [
//                   Container(
//                     height: 56,
//                     width: 389,
//                     child: ElevatedButton(
//                       onPressed: () => _submitBatch(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF023E77),
//                         foregroundColor: Color(0xFFFFFFFF),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(13),
//                         ),
//                         alignment: Alignment.center,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Submit Batch",
//                             style: TextStyle(
//                               fontFamily: "Inter",
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Icon(Icons.send, size: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     height: 56,
//                     width: 389,
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFA8A8A8),
//                         foregroundColor: Color(0xFFFFFFFF),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(13),
//                         ),
//                         alignment: Alignment.center,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Save as Draft",
//                             style: TextStyle(
//                               fontFamily: "Inter",
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Icon(Icons.drafts_outlined, size: 18),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class Block extends StatelessWidget {
//   const Block({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(height: 12);
//   }
// }
//
// class SubTitle extends StatelessWidget {
//   final String? subTitle;
//   final IconData? icon;
//
//   const SubTitle({super.key, this.subTitle, this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: Color(0xFF023E77)),
//         SizedBox(width: 5),
//         Text(
//           "$subTitle",
//           style: TextStyle(
//             color: Color(0xFF64748B),
//             fontFamily: "Inter",
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//             letterSpacing: 0.7,
//           ),
//         ),
//       ],
//     );
//   }
// }
