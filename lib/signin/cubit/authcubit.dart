import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart'; 
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'authstate.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final String _baseUrl = "http://localhost:3000/api";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "936821595024-uek9ov9mlscdqvbg483dughq9b5u1ksi.apps.googleusercontent.com",
  );

  // Sauvegarde token ET role ensemble
  // Future<void> _saveTokenAndRole(String token, String role,
  //     // {String? refreshToken}
  //     ) async {
  //   await storage.write(key: "token", value: token);
  //   await storage.write(key: "role", value: role);
  //   // if (refreshToken != null) {
  //   //   await storage.write(key: "refresh_token", value: refreshToken);
  //   // }
  // }
  // Dans _saveTokenAndRole — ajouter print pour vérifier
  Future<void> _saveTokenAndRole(String token, String role, {String? refreshToken}) async {
    await storage.write(key: "token", value: token);
    await storage.write(key: "role", value: role);

    // 🔍 DEBUG — vérifier que la sauvegarde a fonctionné
    final savedToken = await storage.read(key: "token");
    print("TOKEN SAUVEGARDÉ: $savedToken");
  }
  //---refresh token---
  // Future<bool> _refreshToken() async {
  //   try {
  //     final refreshToken = await storage.read(key: "refresh_token");
  //     if (refreshToken == null) return false;
  //
  //     final response = await http.post(
  //       Uri.parse("$_baseUrl/refresh-token-fishmen"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"refresh_token": refreshToken}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // Mettre à jour les tokens
  //       await storage.write(key: "token", value: data['token']);
  //       if (data['refresh_token'] != null) {
  //         await storage.write(key: "refresh_token", value: data['refresh_token']);
  //       }
  //       return true;
  //     } else {
  //       // Refresh token expiré → logout
  //       await _clearSession();
  //       emit(AuthInitial());
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

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
      // if (method == "GET") return http.get(uri, headers: headers);
      // if (method == "PUT") return http.put(uri, headers: headers, body: jsonEncode(body));
      // return http.post(uri, headers: headers, body: jsonEncode(body));
      if (method == "GET")    return http.get(uri, headers: headers);
      if (method == "PUT")    return http.put(uri, headers: headers, body: jsonEncode(body));
      if (method == "POST")   return http.post(uri, headers: headers, body: jsonEncode(body));
      if (method == "DELETE") return http.delete(uri, headers: headers);

      // Méthode inconnue → exception claire
      throw UnsupportedError("Méthode HTTP non supportée : $method");
    }
    if (token == null) {
      emit(AuthInitial()); // redirige vers login
      throw Exception("No token found");
    }
    var response = await makeRequest(token);

    // Si token expiré → on tente le refresh
    // if (response.statusCode == 401) {
    //   final refreshed = await _refreshToken();
    //   if (refreshed) {
    //     token = await _getToken();
    //     response = await makeRequest(token!); // on réessaie
    //   }
    // }

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
    // await storage.delete(key: "refresh_token");
  }
  // --- LOGIN GOOGLE+API ---
  // Future<void> signInWithGoogle() async {
  //   try {
  //     emit(AuthLoading());
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();//pour ouvrir boit de google account
  //
  //     if (googleUser == null) {
  //       emit(AuthError("User cancelled"));
  //       return;
  //     }
  //
  //     final googleAuth = await googleUser.authentication; //pour access aux token
  //     final String? idToken = googleAuth.idToken;
  //     final String? serverAuthCode = googleUser.serverAuthCode;
  //     final String email = googleUser.email;
  //
  //     // Vérification si le token est bien présent
  //     if (idToken == null) {
  //       emit(AuthError("Failed to get ID Token from Google"));
  //       return;
  //     }
  //     // final response= await _authorizedRequest("Post", "$_baseUrl/auth/google-login-fishmen", body: jsonEncode({
  //     //   "idToken": idToken,
  //     //   "clientId": "936821595024-uek9ov9mlscdqvbg483dughq9b5u1ksi.apps.googleusercontent.com",
  //     //   "serverAuthCode": serverAuthCode,
  //     // }),);
  //     final response = await http.post(
  //       Uri.parse("$_baseUrl/google-login-fishmen"),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({
  //         "idToken": idToken,
  //         "clientId": "936821595024-uek9ov9mlscdqvbg483dughq9b5u1ksi.apps.googleusercontent.com",
  //         "serverAuthCode": serverAuthCode,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // Sauvegarde token + role si le serveur les renvoie
  //       if (data['token'] != null && data['role'] != null) {
  //         await _saveTokenAndRole(data['token'], data['role']);
  //       }
  //       // Succès : on envoie l'email pour la suite (Fivepage)
  //       emit(GooglePasswordRequired(email));
  //     }else {
  //       emit(AuthError("Server error: ${response.body}"));
  //     }
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }
  //
  // // --- LOGIN FACEBOOK+API ---
  // Future<void> signInWithFacebook() async {
  //   try {
  //     emit(AuthLoading());
  //     final LoginResult result = await FacebookAuth.instance.login();
  //
  //     if (result.status != LoginStatus.success) {
  //       emit(AuthError("Facebook login cancelled"));
  //       return;
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse("$_baseUrl/facebook-login-fishmen"),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({"accessToken": result.accessToken!.token}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // ✅ Sauvegarde token + role
  //       await _saveTokenAndRole(data['token'], data['role']);
  //       emit(AuthAuthenticated(data));
  //     } else {
  //       emit(AuthError("Server error during Facebook login"));
  //     }
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }

  // --- LOGIN CLASSIQUE+API ---
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/login-fishmen"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokenAndRole(data['token'], data['role'],
          // refreshToken: data['refresh_token'],
        );
        emit(AuthAuthenticated(data));
      } else {
        emit(AuthError("Invalid email or password"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  // --- INSCRIPTION+API ---
  // Future<void> registerUser(String email, String password) async {
  //   try {
  //     emit(AuthLoading());
  //     final response = await http.post(
  //       Uri.parse("$_baseUrl/register-fishmen"),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({"email": email, "password": password}),
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final userData = jsonDecode(response.body);
  //       await _saveTokenAndRole(userData['token'], userData['role'],
  //         // refreshToken: userData['refresh_token']
  //       );
  //       emit(AuthAuthenticated(userData));
  //     } else {
  //       emit(AuthError("Registration failed: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }

  // --- PROFIL ---

  // Future<void> fetchProfile() async {
  //   emit(ProfileLoaded({
  //     "name": "Captain Ahmed",
  //     "email": "ahmed@mail.com",
  //     "boatName": "Sea Explorer",
  //     "registration": "MAR-9999",
  //     "homePort": "Oran",
  //     "licenseExpiry": "2026",
  //   }));
  // }


  // --- PROFIL FISHERMAN+API ---
  Future<void> fetchProfile() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest("GET", "$_baseUrl/fishermen/me");
      // final response = await http.get(
      //   Uri.parse("$_baseUrl/auth/get-profile-fishmen"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      // );

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



  //---Edit profil FISHERMAN+API---
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String homePort,
    required String boatName,
    required String capacity,
    File? profileImage
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
        "$_baseUrl/get-Edit-profile-fishmen",
        body: {
          "fullName": name,
          "phone": phone,
          "homePort": homePort,
          "boatName": boatName,
          "capacity": capacity,
        },
      );
      // final response = await http.put(
      //   Uri.parse("$_baseUrl/auth/get-Edit-profile-fishmen"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      //   body: jsonEncode({
      //     "fullName": name,
      //     "phone": phone,
      //     "homePort": homePort,
      //     "boatName": boatName,
      //     "capacity": capacity,
      //   }),
      // );

      if (response.statusCode == 200) {
        emit(ProfileUpdatedSuccess());
      } else {
        emit(ProfileError("Update failed"));
      }
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
      request.fields['full_name']              = fullName;
      request.fields['national_id']            = nationalId;
      request.fields['phone_number']           = phone;
      request.fields['home_port']              = homePort;
      request.fields['fishing_license_number'] = licenseNumber;
      request.fields['license_expiry_date']    = expiryDate;

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
        emit(AuthError("Setup failed: ${response.body}"));
        return;
      }

      // ✅ Step 2 — Créer le bateau séparément
      final boatResponse = await _authorizedRequest(//send information of boat
        "POST",
        "$_baseUrl/boats",
        body: {
          "boat_name":            boatName,
          "registration_number":  registrationNumber,
          "home_port":            homePort,
        },
      );

      if (boatResponse.statusCode == 200 || boatResponse.statusCode == 201) {
        emit(SetupSuccess());
      } else {
        emit(AuthError("Boat creation failed: ${boatResponse.body}"));
      }

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  // Future<void> submitSetup({
  //   required String fullName,
  //   required String nationalId,
  //   required String phone,
  //   required String email,
  //   required String boatName,
  //   required String registrationNumber,
  //   required String vesselType,
  //   required String homePort,
  //   required String licenseNumber,
  //   required String expiryDate,
  //   File? fishingLicense,
  //   File? boatRegistration,
  //   File? Idcard,
  // }) async {
  //   try {
  //     emit(SetupLoading());
  //     String? token = await _getToken();
  //     if (token == null) {
  //       emit(AuthError("No token found"));
  //       return;
  //     }
  //     var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/complete-setup-fishmen"));
  //     request.headers.addAll({
  //       "Authorization": "Bearer $token",
  //     });
  //
  //     request.fields['fullName'] = fullName;
  //     request.fields['nationalId'] = nationalId;
  //     request.fields['phone'] = phone;
  //     request.fields['email'] = email;
  //     request.fields['boatName'] = boatName;
  //     request.fields['registrationNumber'] = registrationNumber;
  //     request.fields['vesselType'] = vesselType;
  //     request.fields['homePort'] = homePort;
  //     request.fields['licenseNumber'] = licenseNumber;
  //     request.fields['expiryDate'] = expiryDate;
  //
  //     if (fishingLicense != null) {
  //       request.files.add(await http.MultipartFile.fromPath('fishingLicense', fishingLicense.path));
  //     }
  //     if (boatRegistration != null) {
  //       request.files.add(await http.MultipartFile.fromPath('boatRegistration', boatRegistration.path));
  //     }
  //     if (Idcard != null) {
  //       request.files.add(await http.MultipartFile.fromPath('Id-Card', Idcard.path));
  //     }
  //
  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       emit(SetupSuccess());
  //     } else {
  //       emit(AuthError("Setup failed: ${response.body}"));
  //     }
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }

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
      await FacebookAuth.instance.logOut();
      await _clearSession();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError("Logout failed: ${e.toString()}"));
    }
  }

  // --- VET PROFILE ---
  Future<void> fetchvitProfile() async {
    emit(ProfileLoaded({
      "name": "Captain hako",
      "email": "hako@mail.com",
      "boatName": "Sea Explorer",
      "registration": "MAR-9999",
      "homePort": "Oran",
      "licenseExpiry": "2026",
    }));
  }
  // Future<void> fetchvitProfile() async {
  //   try {
  //     emit(AuthLoading());
  //     String? token = await _getToken();
  //     if (token == null) {
  //       emit(AuthError("No token found"));
  //       return;
  //     }
  //        final response= await _authorizedRequest("GET", "$_baseUrl/auth/profile-vit");
  //     final response = await http.get(
  //       Uri.parse("$_baseUrl/auth/profile-vit"),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       emit(ProfileLoaded(data));
  //     } else {
  //       emit(ProfileError("Failed to load vet profile: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(ProfileError(e.toString()));
  //   }
  // }

  // --- UPDATE VET PROFILE ---

  //edite profile de vitirinaire
  Future<void> updateProfilevit({
    required String name,
    required String phone,
    required String homePort,
    required String boatName,
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
        "$_baseUrl/api/profile",
        body: {
          "Vname": name,
          "Vphone": phone,
          "VhomePort": homePort,
          "VboatName": boatName,
        },
      );
      // final response = await http.put(
      //   Uri.parse("$_baseUrl/api/profile"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      //   body: jsonEncode({
      //     "Vname": name,
      //     "Vphone": phone,
      //     "VhomePort": homePort,
      //     "VboatName": boatName,
      //   }),
      // );

      if (response.statusCode == 200) {
        emit(ProfileUpdatedSuccess());
      } else {
        emit(ProfileError("Update failed"));
      }
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
        body: {
          "batchId": batchId,
          "reason": reason,
        },
      );
      // final response = await http.post(
      //   Uri.parse("$_baseUrl/api/reject-batch"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      //   body: jsonEncode({
      //     "batchId": batchId,
      //     "reason": reason,
      //   }),
      // );

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

// --- VET INSPECTION DATA ---par simulation
  //   Future<void> fetchInspectionDetails(String batchId) async {
//     try {
//       emit(AuthLoading());
//   String? token = await _getToken();
//   if (token == null) {
//   emit(AuthError("No token found"));
//   return;
//   }

//       final response await _authorizedRequest("GET", "$_baseUrl/api/inspection/$batchId");
//
//       final response = await http.get(
//         Uri.parse("https://yourbackend.com/api/inspection/$batchId"),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token", // 🔐 important
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         emit(InspectionDataLoaded({
//           "status": data["status"],
//           "batchId": data["batchId"],
//           "fisherName": data["fisherName"],
//           "fishType": data["fishType"],
//           "expiryDate": data["expiryDate"],
//           "timeLeft": data["timeLeft"],
//         }));
//       } else {
//         emit(AuthError("Failed to load inspection data"));
//       }
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }
  Future<void> fetchInspectionDetails(String batchId) async {
    try {
      emit(AuthLoading());
      // Simulation d'un appel API avec délai
      await Future.delayed(const Duration(milliseconds: 800));

      emit(InspectionDataLoaded({
        "status": "Approved",
        "batchId": "#FSH-99283",
        "fisherName": "Captain Elias",
        "fishType": "Sardin",
        "expiryDate": "Mar 21, 2026",
        "timeLeft": "01 Day, 23 hours restants",
      }));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  //Fill information of Vitirinaire
  Future<void> submitSetupVit({
    required String fullNameVit,
    required String nationalIdVit,
    required String phoneVit,
    // required String emailVit,
    // required String boatNameVit,
    required String specialization,
    required String registrationNumberVit,
    // required String homePortVit,
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
      var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/veterinarians/setup"));
      // request.headers.addAll({
      //   "Authorization": "Bearer $token",
      //   "Content-Type": "multipart/form-data",
      // });
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['full_name'] = fullNameVit;
      request.fields['national_id'] = nationalIdVit;
      request.fields['phone_number'] = phoneVit;
      request.fields['specialization'] = specialization;
      request.fields['license_number'] = licenseNumberVit;
      request.fields['license_expiry'] = expiryDateVit;

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

      // if (fishingLicenseVit != null) {
      //   request.files.add(await http.MultipartFile.fromPath('fishingLicense', fishingLicenseVit.path));
      // }
      if (fishingLicenseVit != null) {
      var file = await http.MultipartFile.fromPath(
        'fishing_license',
        fishingLicenseVit.path,
        contentType: _getMediaType(fishingLicenseVit), // تحديد نوع الملف
      );
      request.files.add(file);
    }
      // if (boatRegistrationVit != null) {
      //   request.files.add(await http.MultipartFile.fromPath('boatRegistration', boatRegistrationVit.path));
      // }
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

      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   emit(SetupSuccess());
      // }
      if (response.statusCode != 200 && response.statusCode != 201) {
      emit(AuthError("Setup failed: ${response.body}"));
      return;
    }
      // else {
      //   emit(AuthError("Setup failed: ${response.body}"));
      // }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  // --- HOME DATA FISHERMAN ---
  // Future<void> fetchHomeData() async {
  //   try {
  //     emit(AuthLoading());
  //     // String? token = await _getToken();
  //     // if (token == null) {
  //     //   emit(AuthError("No token found"));
  //     //   return;
  //     // }
  //     await Future.delayed(const Duration(seconds: 1));
  //     emit(HomeDataLoaded({
  //       "userName":        "Capt. Ahmed",
  //       "earnings":        "12,450.00 DA",
  //       "earningsTrend":   "8.4%",
  //       "weight":          "4,250 kg",
  //       "weightTrend":     "5.2%",
  //       "pendingBatches":  24,
  //       "approvedBatches": 85,
  //       "rejectedBatches": 12,
  //       "expiredBatches":  7,
  //
  //       // ✅ Donut — valeurs numériques
  //       "batch_approved":  72.0,
  //       "batch_expired":   18.0,
  //       "batch_pending":    4.0,
  //       "batch_rejected":   6.0,
  //
  //       // ✅ Donut — labels String
  //       "approved_label": "72%",
  //       "expired_label":  "18%",
  //       "pending_label":   "4%",
  //       "rejected_label":  "6%",
  //       "batch":          "105",   // ← nombre au centre
  //
  //       // ✅ Fish distribution
  //       "sardine_pct":    42.5,
  //       "salmon_pct":     28.1,
  //       "tuna_pct":       15.4,
  //       "seabass_pct":     9.2,
  //       "other_pct":       4.8,
  //       "sardine_label":  "42.5%",
  //       "salmon_label":   "28.1%",
  //       "tuna_label":     "15.4%",
  //       "seabass_label":   "9.2%",
  //       "other_label":     "4.8%",
  //     }));
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }
  Future<void> fetchHomeData() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 1));
      final response = await _authorizedRequest("GET", "$_baseUrl/get-profile-fishmen");
      // final response = await http.get(
      //   Uri.parse("$_baseUrl/auth/get-profile-fishmen"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      // );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ProfileLoaded(data));
      } else {
        emit(AuthError("Failed to load Home page"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //profile de consumer
  Future<void> fetchConsumerProfile() async {
    emit(ProfileLoaded({
      "name": "Captain hako",
      "email": "hako@mail.com",
      "boatName": "Sea Explorer",
      "registration": "MAR-9999",
      "homePort": "Oran",
      "licenseExpiry": "2026",
    }));
  }
  // Future<void> fetchConsumerProfile() async {
  //   try {
  //     emit(AuthLoading());
  //     String? token = await _getToken();
  //     if (token == null) {
  //       emit(AuthError("No token found"));
  //       return;
  //     }
  //     final response = await _authorizedRequest("GET", "$_baseUrl/api/profileConsumer");
  //     final response = await http.get(
  //       Uri.parse("https://api.example.com/profileConsumer"),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       emit(ProfileLoaded(data));
  //     } else {
  //       emit(ProfileError("Failed to load profile"));
  //     }
  //   } catch (e) {
  //     emit(ProfileError(e.toString()));
  //   }
  // }



  //Fill information of Consumer
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

      var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/customers/setup"));
      // request.headers.addAll({
      //   "Authorization": "Bearer $token",
      //   "Content-Type": "multipart/form-data",
      // });
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['full_name'] = fullNameCons;
      request.fields['national_id'] = nationalIdCons;
      request.fields['phone_number'] = phoneCons;
      request.fields['delivery_address'] = delevryAddress;
      request.fields['nearby_port'] = nearbyPortCons;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
      emit(AuthError("Setup failed: ${response.body}"));
      return;
    }
      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   emit(SetupSuccess());
      // } else {
      //   emit(AuthError("Setup failed: ${response.body}"));
      // }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  // --- UPDATE PASSWORD FISHERMAN+API ---
  Future<void> updatePassword({
    required String password, required String currentPassword,
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
        "$_baseUrl/change-password",
        body: {
          "currentPassword": currentPassword,
          "password": password,
        },
      );
      // final response = await http.put(
      //   Uri.parse("$_baseUrl/auth/change-password"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      //   body: jsonEncode({
      //     "currentPassword": currentPassword,
      //     "password": password,
      //   }),
      // );

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
      final response = await _authorizedRequest("PUT", "$_baseUrl/auth/update-profile",
          body:{
            "currentpasswordVit":currentpasswordVit,
            "passwordVit": passwordVit,
          });
      // final response = await http.put(
      //   Uri.parse("$_baseUrl/auth/update-profile"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      //   body: jsonEncode({
      //     "currentpasswordVit":currentpasswordVit,
      //     "passwordVit": passwordVit,
      //   }),
      // );

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
      final response = await _authorizedRequest("PUT", "$_baseUrl/auth/update-profile",
          body:{
            "currentpaaswordCons":currentpasswordCons,
            "passwordCons": passwordCons,
          });
      // final response = await http.put(
      //   Uri.parse("$_baseUrl/auth/update-profile"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      //   body: jsonEncode({
      //     "currentpaaswordCons":currentpasswordCons,
      //     "passwordCons": passwordCons,
      //   }),
      // );

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
  }) async {
    try {
      emit(AuthLoading());
      String? token_cons = await _getToken();
      if (token_cons == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
          "PUT",
          "$_baseUrl/auth/update-profile",
          body: {
            "fullName": name_cons,
            "phone": phone_cons,
            "homePort": homePort_cons,
            "boatName": boatName_cons,
          });
      // final response = await http.put(
      //   Uri.parse("$_baseUrl/auth/update-profile"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token_cons",
      //   },
      //   body: jsonEncode({
      //     "fullName": name_cons,
      //     "phone": phone_cons,
      //     "homePort": homePort_cons,
      //     "boatName": boatName_cons,
      //   }),
      // );

      if (response.statusCode == 200) {
        emit(ProfileUpdatedSuccess());
      } else {
        emit(ProfileError("Update failed"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
  // --- SÉLECTION DU RÔLE ---
  // Future<void> selectRole(String email,String password,String role) async {
  //   try {
  //     emit(AuthLoading());
  //
  //     String? token = await _getToken();
  //     if (token == null) {
  //       emit(AuthError("No token found"));
  //       return;
  //     }
  //
  //     // Envoie le rôle au backend
  //     // final response = await _authorizedRequest("POST", "$_baseUrl/auth/send-email-fishmen", body: {
  //     //   "email":email,
  //     //   "role": role});
  //     //")
  //     final response = await http.post(
  //       Uri.parse("$_baseUrl/auth/register"),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode({
  //         "email":email,
  //         "password": password,
  //         "role": role}),
  //       // on envoie : {"role": "fishmen"}
  //       // ou         {"role": "vet"}
  //       // ou         {"role": "consumer"}
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Sauvegarde le rôle localement
  //       await storage.write(key: "role", value: role);
  //       emit(RoleSelectedSuccess(role)); // → redirige selon le rôle
  //     }
  //     else {
  //       emit(AuthError("Failed to select role: ${response.body}"));
  //     }
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }
  Future<void> selectRole(String email, String password, String role) async {
    try {
      emit(AuthLoading());

      // ✅ Pas besoin de token avant — c'est le register
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": role,
        }),
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
        await _saveTokenAndRole(
          data['token'],
          role,
        );

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
          headers:
          {
            "Content-Type": "application/json",
          },
          body: jsonEncode({"email": email, "code": code,}));
      if (response.statusCode == 200) {
        emit(CodeVerifiedSuccess());
      } else {
        emit(AuthError("Server error: ${response.statusCode}"));
      }
    }catch(e){
      emit(AuthError(e.toString()));

    }
  }
  // --- ADMIN AUTHENTICATION ---
  Future<void> submitAdmin({
    required String emailvet,
    required String passwordvet,
    required String homePortvet,
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
          "$_baseUrl/auth/code_verification",
          body: {
            "emailvet": emailvet,
            "passwordvet": passwordvet,
            "homePortvet": homePortvet,
          });
      // final response = await http.post(
      //     Uri.parse("$_baseUrl/auth/code_verification"),
      //     headers:
      //     {
      //       "Content-Type": "application/json",
      //       "Authorization": "Bearer $token",
      //     },
      //     body: jsonEncode({"emailvet": emailvet, "passwordvet": passwordvet, "homePortvet": homePortvet,}));

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
      final response = await _authorizedRequest("GET", "$_baseUrl/api/profile");
      // final response = await http.get(
      //   Uri.parse("https://yourbackend.com/api/profile"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      // );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(AdminLoaded(data));
      } else {
        emit(AuthError("Failed to load Admin page"));
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
        Uri.parse("$_baseUrl/reset-password-fishmen"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        emit(ResetPasswordEmailSent());
      } else {
        emit(AuthError("Failed to send reset email"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> fetchAdminvet() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/auth/profile-fishmen",
      );
      // final response = await http.get(
      //   Uri.parse("$_baseUrl/auth/profile-fishmen"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      // );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(AdminLoaded(data));
      } else {
        emit(AuthError("Failed to load profile"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> fetchAdminpecheur() async {
    try {
      emit(AuthLoading());
      String? token = await _getToken();
      if (token == null) {
        emit(AuthError("No token found"));
        return;
      }
      final response = await _authorizedRequest(
        "GET",
        "$_baseUrl/auth/profile-fishmen",
      );
      // final response = await http.get(
      //   Uri.parse("$_baseUrl/auth/profile-fishmen"),
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Authorization": "Bearer $token",
      //   },
      // );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(AdminLoaded(data));
      } else {
        emit(AuthError("Failed to load profile"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
