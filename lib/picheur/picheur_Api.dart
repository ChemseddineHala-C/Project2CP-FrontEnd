import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const storage = FlutterSecureStorage();

  // Save Token
  static Future<void> saveToken(String token) async {
    await storage.write(key: "token", value: token);
  }

  // getToken
  static Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  // delete Token after log out
  static Future<void> clearToken() async {
    await storage.delete(key: "token");
  }
}

class ApiService {
  static const String baseUrl = "http://192.168.1.5:4010";

  // ── Headers ──────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ── GET ────────────────────────────────────
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _headers(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("No internet connection");
    }
  }

  // ── POST JSON ──────────────────────────────
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("No internet connection");
    }
  }

  // ── POST Multipart ────────────────
  static Future<dynamic> postMultipart(
      String endpoint,
      Map<String, String> fields,
      List<File> files,
      String fileField,
      ) async {
    try {
      final token = await AuthService.getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl$endpoint"),
      );

      request.headers["Authorization"] = "Bearer $token";
      request.fields.addAll(fields);

      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, file.path),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      throw Exception("No internet connection");
    }
  }

  // ── Treating Response ────────────────────
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else if (response.statusCode == 404) {
      throw Exception("Not found");
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}

class BatchModel {
  final String? id;
  final String category;
  final String fishName;
  final String catchMethod;
  final double quantity;
  final double price;
  final double? total;
  final double latitude;
  final double longitude;
  final String? notes;
  final String? status;
  final String? date;
  final List<String>? photos;

  BatchModel({
    this.id,
    required this.category,
    required this.fishName,
    required this.catchMethod,
    required this.quantity,
    required this.price,
    this.total,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.status,
    this.date,
    this.photos,
  });

  // ── من JSON إلى Object ← للـ GET ──────────
  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json["id"],
      category: json["category"],
      fishName: json["fish_name"],
      catchMethod: json["catch_method"],
      quantity: (json["quantity"] as num).toDouble(),
      price: (json["price"] as num).toDouble(),
      total: json["total"] != null ? (json["total"] as num).toDouble() : null,
      latitude: (json["latitude"] as num).toDouble(),
      longitude: (json["longitude"] as num).toDouble(),
      notes: json["notes"],
      status: json["status"],
      date: json["date"],
      photos: json["photos"] != null ? List<String>.from(json["photos"]) : [],
    );
  }

  // ── من Object إلى JSON ← للـ POST ─────────
  Map<String, String> toFields() {
    return {
      "category": category,
      "fish_name": fishName,
      "catch_method": catchMethod,
      "quantity": quantity.toString(),
      "price": price.toString(),
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "notes": notes ?? "",
    };
  }
}
