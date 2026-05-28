import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'authstate.dart';
import '../../HOST.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final String _baseUrl = "http://$HOST:3000/api";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "936821595024-uek9ov9mlscdqvbg483dughq9b5u1ksi.apps.googleusercontent.com",
  );

  Future<void> _saveTokenAndRole(
    String token,
    String role, {
    String? refreshToken,
  }) async {
    await storage.write(key: "token", value: token);
    await storage.write(key: "role", value: role);

    // 🔍 DEBUG — vérifier que la sauvegarde a fonctionné
    final savedToken = await storage.read(key: "token");
    print("TOKEN SAUVEGARDÉ: $savedToken");
  }

  //---Remplace http---
  Future<http.Response> _authorizedRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    String? token = await _getToken();

    Future<http.Response> makeRequest(String t) {
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $t",
      };
      final uri = Uri.parse(url);
      if (method == "GET") return http.get(uri, headers: headers);
      if (method == "PUT")
        return http.put(uri, headers: headers, body: jsonEncode(body));
      if (method == "POST")
        return http.post(uri, headers: headers, body: jsonEncode(body));
      if (method == "DELETE") return http.delete(uri, headers: headers);

      // Méthode inconnue → exception claire
      throw UnsupportedError("Méthode HTTP non supportée : $method");
    }

    if (token == null) {
      emit(AuthInitial()); // redirige vers login
      throw Exception("No token found");
    }
    var response = await makeRequest(token);
    return response;
  }

  // Récupère le token
  Future<String?> _getToken() async {
    return await storage.read(key: "token");
  }

  // Récupère le role
  Future<String?> getRole() async {
    return await storage.read(key: "role");
  }

  // Supprime token + role (pour logout)
  Future<void> _clearSession() async {
    await storage.delete(key: "token");
    await storage.delete(key: "role");
  }
  // await storage.delete(key: "refresh_token");

  // --- LOGIN CLASSIQUE+API ---
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        await _saveTokenAndRole(
          data['token'],
          data['user']['role'],
          // refreshToken: data['refresh_token'],
        );
        emit(AuthAuthenticated(data));
      } else {
        emit(AuthError("message: ${jsonDecode(response.body)['message']}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- PROFIL FISHERMAN+API ---
  Future<void> fetchProfile() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/fishermen/me",
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("RESPONSE DATA: $data");
        print("TOKEN: ${data['token']}");
        emit(ProfileLoaded(data));
      } else {
        emit(ProfileError("message: ${jsonDecode(response.body)['message']}"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //---Edit profil FISHERMAN+API---
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String homePort,
    required String boatName,
    required String fuel,
    File? profileImage,
  }) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }

      // ✅ Step 1 — Mettre à jour les infos texte
      final response = await _authorizedRequest(
        "PUT",
        "$_baseUrl/fishermen/me",
        body: {
          "full_name": name,
          "phone_number": phone,
          "home_port": homePort,
          "boat_name": boatName,
          "fuel_tank_capacity": fuel,
        },
      );

      if (response.statusCode != 200) {
        emit(ProfileError("message: ${jsonDecode(response.body)['message']}"));
        return;
      }
      if (profileImage != null) {
        var photoRequest = http.MultipartRequest(
          'PUT',
          Uri.parse("$_baseUrl/fishermen/me/photo"),
        );
        photoRequest.headers['Authorization'] = 'Bearer $token';

        // ✅ Détecter le type du fichier
        MediaType _getMediaType(File file) {
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

        photoRequest.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            profileImage.path,
            contentType: _getMediaType(profileImage), // ← ajouter ça
          ),
        );

        // 🔍 DEBUG
        print("PHOTO PATH: ${profileImage.path}");
        print("PHOTO TYPE: ${_getMediaType(profileImage)}");

        var photoStreamed = await photoRequest.send();
        var photoResponse = await http.Response.fromStream(photoStreamed);

        print("PHOTO STATUS: ${photoResponse.statusCode}");
        print("PHOTO RESPONSE: ${photoResponse.body}");

        if (photoResponse.statusCode != 200) {
          emit(
            ProfileError("message: ${jsonDecode(response.body)['message']}"),
          );
          return;
        }
      }

      emit(ProfileUpdatedSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // --- COMPLETE SETUP+API ---
  Future<void> submitSetup({
    required String fullName,
    required String nationalId,
    required String phone,
    required String homePort,
    required String licenseNumber,
    required String expiryDate,
    required String boatName,
    required String registrationNumber,
    File? fishingLicense,
    File? boatRegistration,
    File? Idcard,
  }) async {
    try {
      emit(SetupLoading());
      String? token = await _getToken();
      print("TOKEN DANS SUBMITSETUP: $token");
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }

      // ✅ Step 1 — Setup fisherman
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/fishermen/setup"), // ← URL corrigée
      );
      request.headers['Authorization'] = 'Bearer $token';

      // ✅ Field names corrigés selon backend
      request.fields['full_name'] = fullName;
      request.fields['national_id'] = nationalId;
      request.fields['phone_number'] = phone;
      request.fields['home_port'] = homePort;
      request.fields['fishing_license_number'] = licenseNumber;
      request.fields['license_expiry_date'] = expiryDate;

      // ✅ File names corrigés selon backend
      MediaType _getMediaType(File file) {
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

      // ✅ إضافة الملفات مع تحديد MIME type صحيح
      if (fishingLicense != null) {
        var file = await http.MultipartFile.fromPath(
          'fishing_license',
          fishingLicense.path,
          contentType: _getMediaType(fishingLicense), // تحديد نوع الملف
        );
        request.files.add(file);
      }

      if (boatRegistration != null) {
        var file = await http.MultipartFile.fromPath(
          'boat_registration',
          boatRegistration.path,
          contentType: _getMediaType(boatRegistration),
        );
        request.files.add(file);
      }

      if (Idcard != null) {
        var file = await http.MultipartFile.fromPath(
          'id_card',
          Idcard.path,
          contentType: _getMediaType(Idcard),
        );
        request.files.add(file);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        emit(AuthError("message: ${jsonDecode(response.body)['message']}"));
        return;
      }

      // ✅ Step 2 — Créer le bateau séparément
      final boatResponse = await _authorizedRequest(
        //send information of boat
        "POST",
        "$_baseUrl/boats",
        body: {
          "boat_name": boatName,
          "registration_number": registrationNumber,
          "home_port": homePort,
        },
      );

      if (boatResponse.statusCode == 200 || boatResponse.statusCode == 201) {
        emit(SetupSuccess());
      } else {
        emit(AuthError("message: ${jsonDecode(response.body)['message']}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- LOGOUT+api ---
  Future<void> logout() async {
    try {
      String? token = await _getToken();
      await http.post(
        Uri.parse("$_baseUrl/logout-fishmen"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      await _googleSignIn.signOut();
      await _clearSession();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError("Logout failed: ${e.toString()}"));
    }
  }

  Future<void> fetchvitProfile() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/veterinarians/me",
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("RESPONSE DATA: $data");
        print("TOKEN: ${data['token']}");
        emit(ProfileLoaded(data));
      } else {
        emit(
          ProfileError("Failed to load vet profile: ${response.statusCode}"),
        );
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // --- UPDATE VET PROFILE ---
  Future<void> updateProfilevit({
    required String name,
    required String phone,
    required String homePort,
    required String boatName,
    File? profileImage,
  }) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }

      // ✅ Step 1 — تحديث المعلومات النصية
      final response = await _authorizedRequest(
        "PUT",
        "$_baseUrl/veterinarians/me",
        body: {
          "full_name": name,
          "phone_number": phone,
          "home_port": homePort,
          "boat_name": boatName,
        },
      );

      if (response.statusCode != 200) {
        emit(ProfileError("Update failed: ${response.body}"));
        return;
      }

      // ✅ Step 2 — تحديث الصورة إذا تم اختيار صورة جديدة
      if (profileImage != null) {
        var photoRequest = http.MultipartRequest(
          'PUT',
          Uri.parse("$_baseUrl/veterinarians/me/photo"),
        );
        photoRequest.headers['Authorization'] = 'Bearer $token';

        // ✅ إضافة الملف مع تحديد MIME type صحيح
        photoRequest.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            profileImage.path,
            contentType: _getMediaType(profileImage), // استخدام الدالة العامة
          ),
        );

        // 🔍 DEBUG
        print("PHOTO PATH: ${profileImage.path}");
        print("PHOTO TYPE: ${_getMediaType(profileImage)}");

        var photoStreamed = await photoRequest.send();
        var photoResponse = await http.Response.fromStream(photoStreamed);

        print("PHOTO STATUS: ${photoResponse.statusCode}");
        print("PHOTO RESPONSE: ${photoResponse.body}");

        if (photoResponse.statusCode != 200) {
          emit(ProfileError("Photo update failed: ${photoResponse.body}"));
          return;
        }
      }

      emit(ProfileUpdatedSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // --- EMAIL & CODE +API---
  Future<void> sendEmail(String email) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/send-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        emit(EmailSentSuccess());
      } else {
        emit(AuthError("Server error: ${response.statusCode}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendRejectionReason({
    required String batchId,
    required String reason,
  }) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "POST",
        "$_baseUrl/api/reject-batch",
        body: {"batchId": batchId, "reason": reason},
      );

      if (response.statusCode == 200) {
        // Vous pouvez émettre un état de succès ici
        emit(InspectionDataLoaded(jsonDecode(response.body)));
      } else {
        emit(AuthError("Failed to send rejection"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> fetchInspectionDetails(String batchId) async {
    try {
      emit(AuthLoading());
      // Simulation d'un appel API avec délai
      await Future.delayed(const Duration(milliseconds: 800));

      emit(
        InspectionDataLoaded({
          "status": "Approved",
          "batchId": "#FSH-99283",
          "fisherName": "Captain Elias",
          "fishType": "Sardin",
          "expiryDate": "Mar 21, 2026",
          "timeLeft": "01 Day, 23 hours restants",
        }),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  MediaType _getMediaType(File file) {
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

  //Fill information of Vitirinaire
  Future<void> submitSetupVit({
    required String fullNameVit,
    required String nationalIdVit,
    required String phoneVit,
    required String specialization,
    required String registrationNumberVit,
    required String licenseNumberVit,
    required String expiryDateVit,
    File? fishingLicenseVit,
    File? Idcard,
  }) async {
    try {
      emit(SetupLoading());
      String? token = await _getToken();
      print("TOKEN DANS SUBMITSETUP: $token");

      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/veterinarians/setup"),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // إضافة الحقول النصية
      request.fields['full_name'] = fullNameVit;
      request.fields['national_id'] = nationalIdVit;
      request.fields['phone_number'] = phoneVit;
      request.fields['specialization'] = specialization;
      request.fields['license_number'] = licenseNumberVit;
      request.fields['license_expiry_date'] = expiryDateVit;

      // ✅ إضافة ملف fishing_license مع MIME type
      if (fishingLicenseVit != null) {
        var file = await http.MultipartFile.fromPath(
          'vet_license',
          fishingLicenseVit.path,
          contentType: _getMediaType(fishingLicenseVit),
        );
        request.files.add(file);
      }

      // ✅ إضافة ملف id_card مع MIME type
      if (Idcard != null) {
        var file = await http.MultipartFile.fromPath(
          'id_card',
          Idcard.path,
          contentType: _getMediaType(Idcard),
        );
        request.files.add(file);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(SetupSuccess());
      } else {
        emit(AuthError("Setup failed: ${response.body}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> fetchHomeData() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/fishermen/dashboard"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        // ✅ تغيير: إرسال HomeDataLoaded بدلاً من ProfileLoaded
        emit(HomeDataLoaded(data));
      } else {
        emit(AuthError("Failed to load Home page"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> fetchConsumerProfile() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/customers/me",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("RESPONSE DATA: $data");
        print("TOKEN: ${data['token']}");
        emit(ProfileLoaded(data));
      } else {
        emit(ProfileError("Failed to load profile"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //SUBMIT SETUP CONSUMER
  Future<void> submitSetupCons({
    required String fullNameCons,
    required String nationalIdCons,
    required String phoneCons,
    required String delevryAddress,
    required String nearbyPortCons,
  }) async {
    try {
      emit(SetupLoading());
      String? token = await _getToken();
      print("TOKEN DANS SUBMITSETUP: $token");
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }

      // ✅ استخدام http.post بدلاً من MultipartRequest (لا يوجد ملفات)
      final response = await http.post(
        Uri.parse("$_baseUrl/customers/setup"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "full_name": fullNameCons,
          "national_id": nationalIdCons,
          "phone_number": phoneCons,
          "delivery_address": delevryAddress,
          "nearby_port": nearbyPortCons,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(SetupSuccess());
      } else {
        emit(AuthError("Setup failed: ${response.body}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- UPDATE PASSWORD FISHERMAN+API ---
  Future<void> updatePassword({
    required String password,
    required String currentPassword,
  }) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "PUT",
        "$_baseUrl/users/change-password",
        body: {
          "current_password": currentPassword,
          "new_password": password,
          "confirm_password": password,
        },
      );

      if (response.statusCode == 200) {
        emit(PasswordUpdatedSuccess());
      } else {
        emit(ProfileError("Update failed"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // --- UPDATE PASSWORD VET ---
  Future<void> updatePasswordVit({
    required String passwordVit,
    required String currentpasswordVit,
  }) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "PUT",
        "$_baseUrl/users/change-password",
        body: {
          "current_password": currentpasswordVit,
          "new_password": passwordVit,
          "confirm_password": passwordVit,
        },
      );

      if (response.statusCode == 200) {
        emit(PasswordUpdatedSuccess());
      } else {
        emit(ProfileError("Update failed"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // --- UPDATE PASSWORD CONSUMER ---
  Future<void> updatePasswordCons({
    required String passwordCons,
    required String currentpasswordCons,
  }) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "PUT",
        "$_baseUrl/users/change-password",
        body: {
          "current_password": currentpasswordCons,
          "new_password": passwordCons,
          "confirm_password": passwordCons,
        },
      );

      if (response.statusCode == 200) {
        emit(PasswordUpdatedSuccess());
      } else {
        emit(ProfileError("Update failed"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //edit profile consumer
  Future<void> updateProfileConsumer({
    required String name_cons,
    required String phone_cons,
    required String homePort_cons,
    required String boatName_cons,
    required String delivery_address,
    File? profileImage,
  }) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }

      // ✅ Step 1 — تحديث المعلومات النصية
      final response = await _authorizedRequest(
        "PUT",
        "$_baseUrl/customers/me",
        body: {
          "full_name": name_cons,
          "phone_number": phone_cons,
          "nearby_port": homePort_cons,
          "delivery_address": delivery_address,
        },
      );

      if (response.statusCode != 200) {
        emit(ProfileError("Update failed: ${response.body}"));
        return;
      }

      // ✅ Step 2 — تحديث الصورة إذا تم اختيار صورة جديدة
      if (profileImage != null) {
        var photoRequest = http.MultipartRequest(
          'PUT',
          Uri.parse("$_baseUrl/customers/me/photo"), // ✅ تم التصحيح
        );
        photoRequest.headers['Authorization'] = 'Bearer $token';

        // ✅ إضافة الملف مع تحديد MIME type صحيح (استخدام الدالة العامة)
        photoRequest.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            profileImage.path,
            contentType: _getMediaType(profileImage), // استخدام الدالة العامة
          ),
        );

        // 🔍 DEBUG
        print("PHOTO PATH: ${profileImage.path}");
        print("PHOTO TYPE: ${_getMediaType(profileImage)}");

        var photoStreamed = await photoRequest.send();
        var photoResponse = await http.Response.fromStream(photoStreamed);

        print("PHOTO STATUS: ${photoResponse.statusCode}");
        print("PHOTO RESPONSE: ${photoResponse.body}");

        if (photoResponse.statusCode != 200) {
          emit(ProfileError("Photo update failed: ${photoResponse.body}"));
          return;
        }
      }

      emit(ProfileUpdatedSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> selectRole(String email, String password, String role) async {
    try {
      emit(AuthLoading());

      // ✅ Pas besoin de token avant — c'est le register
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password, "role": role}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        //pour verify token
        print("RESPONSE DATA: $data");
        print("TOKEN: ${data['token']}");
        print("ROLE: $role");

        if (data['token'] == null) {
          emit(AuthError("Token null reçu du backend"));
          return;
        }

        // ✅ Sauvegarde token + role reçus du backend
        await _saveTokenAndRole(data['token'], role);

        emit(RoleSelectedSuccess(role));
      } else {
        emit(AuthError("Failed: ${response.body}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- VÉRIFICATION CODE+API ---
  Future<void> verifyCode(String email, String code) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/verify-email"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "code": code}),
      );
      if (response.statusCode == 200) {
        emit(CodeVerifiedSuccess());
      } else {
        emit(AuthError("Server error: ${response.statusCode}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- ADMIN AUTHENTICATION ---
  Future<void> submitAdmin({
    required String emailvet,
    required String passwordvet,
    required String homePortvet,
    required String full_name,
    required String national_id,
    required String phone_number,
    required String specialization,
    required String license_number,
    required String license_expiry_date,
  }) async {
    try {
      emit(SetupLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "POST",
        "$_baseUrl/admins/vets",
        body: {
          "email": emailvet,
          "password": passwordvet,
          "full_name": full_name,
          "national_id": national_id,
          "phone_number": phone_number,
          "specialization": specialization,
          "license_number": license_number,
          "license_expiry_date": license_expiry_date,
          "home_port": homePortvet,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(VetCreatedSuccess());
      } else {
        emit(AuthError("Setup failed: ${response.body}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //---FETCH ADMIN---
  Future<void> fetchadmin() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 1));
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/admins/dashboard",
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        emit(AdminLoaded(data));
      } else {
        emit(AuthError("${jsonDecode(response.body)}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //---Reset password+API---
  Future<void> resetPassword(String email) async {
    try {
      emit(AuthLoading());

      final response = await http.post(
        Uri.parse("$_baseUrl/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        emit(ResetPasswordEmailSent());
      } else {
        emit(AuthError("message: ${jsonDecode(response.body)['message']}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> fetchAdminvet(String id) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/veterinarians/$id",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        emit(AdminLoaded(data));
      } else {
        emit(AuthError("Failed to load profile"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> fetchAdminpecheur(String id) async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/fishermen/$id",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        emit(AdminLoaded(data));
      } else {
        emit(AuthError("Failed to load profile"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> noti() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/notifications",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("NOTIFICATIONS: $data");
        emit(ProfileLoaded({"notifications": data}));
      } else {
        emit(ProfileError("Failed to load notifications"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
