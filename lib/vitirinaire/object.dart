import 'package:flutter/material.dart';
import 'dart:convert';

class FishBatchWithFisherman {
  final int? id;
  final int? fishermanId;
  final String? category;
  final String? fishName;
  final String? catchMethod;
  final double? quantityKg;
  final double? remainingQuantityKg;
  final double? pricePerKg;
  final List<String>? photo;
  final double? latitude;
  final double? longitude;
  final String? additionalNotes;
  final String? status;
  final DateTime? createdAt;
  final String? fishermanName;
  final String? boatName;

  FishBatchWithFisherman({
    this.id,
    this.fishermanId,
    this.category,
    this.fishName,
    this.catchMethod,
    this.quantityKg,
    this.remainingQuantityKg,
    this.pricePerKg,
    this.photo,
    this.latitude,
    this.longitude,
    this.additionalNotes,
    this.status,
    this.createdAt,
    this.fishermanName,
    this.boatName,
  });

  factory FishBatchWithFisherman.fromJson(Map<String, dynamic> json) {
    // ✅ معالجة حقل photo - تحويل Map أو أي نوع إلى List
    List<String> photoList = [];

    if (json['photo'] != null) {
      if (json['photo'] is List) {
        photoList = List<String>.from(json['photo']);
      } else if (json['photo'] is Map) {
        // ✅ استخراج القيم من Map وتحويلها إلى List
        photoList = (json['photo'] as Map).values
            .map((e) => e.toString())
            .toList();
      } else if (json['photo'] is String) {
        String photoStr = json['photo'].toString().trim();
        if (photoStr.startsWith('[')) {
          try {
            List<dynamic> parsed = jsonDecode(photoStr);
            photoList = parsed
                .where((e) => e != null && e.toString().isNotEmpty)
                .map((e) => e.toString())
                .toList();
          } catch (e) {
            print('Error parsing photo JSON: $e');
            if (photoStr.isNotEmpty) photoList = [photoStr];
          }
        } else if (photoStr.isNotEmpty) {
          photoList = [photoStr];
        }
      }
      photoList.removeWhere((e) => e.isEmpty);
    }

    return FishBatchWithFisherman(
      id: json['id'] as int?,
      fishermanId: json['fisherman_id'] as int?,
      category: json['category'] as String?,
      fishName: json['fish_name'] as String?,
      catchMethod: json['catch_method'] as String?,
      quantityKg: (json['quantity_kg'] as num?)?.toDouble(),
      remainingQuantityKg:
          (json['remaining_quantities_kg'] ?? json['remaining_quantity_kg'])
              ?.toDouble(),
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      photo: photoList,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      additionalNotes: json['additional_notes'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      fishermanName: json['fisherman_name'] as String?,
      boatName: json['boat_name'] as String?,
    );
  }

  static List<FishBatchWithFisherman> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => FishBatchWithFisherman.fromJson(json))
        .toList();
  }
}

class Inspection {
  final int? id;
  final int? batchId;
  final int? veterinarianId;
  final String? smell;
  final String? gillColor;
  final String? fleshFirmness;
  final String? eyeClarity;
  final double? internalTemperature;
  final bool? parasitesPresent;
  final int? freshnessScore;
  final String? notes;
  final String? decision;
  final DateTime? inspectedAt;
  final String? fishName;
  final String? category;
  final String? fishermanName;

  Inspection({
    this.id,
    this.batchId,
    this.veterinarianId,
    this.smell,
    this.gillColor,
    this.fleshFirmness,
    this.eyeClarity,
    this.internalTemperature,
    this.parasitesPresent,
    this.freshnessScore,
    this.notes,
    this.decision,
    this.inspectedAt,
    this.fishName,
    this.category,
    this.fishermanName,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    // ✅ معالجة parasites_present
    bool? parasitesPresentValue;
    if (json['parasites_present'] != null) {
      if (json['parasites_present'] is bool) {
        parasitesPresentValue = json['parasites_present'];
      } else if (json['parasites_present'] is int) {
        parasitesPresentValue = json['parasites_present'] == 1;
      }
    }

    return Inspection(
      id: json['id'] as int?,
      batchId: json['batch_id'] as int?,
      veterinarianId: json['veterinarian_id'] as int?,
      smell: json['smell'] as String?,
      gillColor: json['gill_color'] as String?,
      fleshFirmness: json['flesh_firmness'] as String?,
      eyeClarity: json['eye_clarity'] as String?,
      internalTemperature: (json['internal_temperature'] as num?)?.toDouble(),
      parasitesPresent: parasitesPresentValue,
      freshnessScore: json['freshness_score'] as int?,
      notes: json['notes'] as String?,
      decision: json['decision'] as String?,
      inspectedAt: json['inspected_at'] != null
          ? DateTime.tryParse(json['inspected_at'])
          : null,
      fishName: json['fish_name'] as String?,
      category: json['category'] as String?,
      fishermanName: json['fisherman_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (veterinarianId != null) 'veterinarian_id': veterinarianId,
      if (smell != null) 'smell': smell,
      if (gillColor != null) 'gill_color': gillColor,
      if (fleshFirmness != null) 'flesh_firmness': fleshFirmness,
      if (eyeClarity != null) 'eye_clarity': eyeClarity,
      if (internalTemperature != null)
        'internal_temperature': internalTemperature,
      if (parasitesPresent != null)
        'parasites_present': parasitesPresent == true ? 1 : 0,
      if (freshnessScore != null) 'freshness_score': freshnessScore,
      if (notes != null) 'notes': notes,
      if (decision != null) 'decision': decision,
      if (inspectedAt != null) 'inspected_at': inspectedAt?.toIso8601String(),
      if (fishName != null) 'fish_name': fishName,
      if (category != null) 'category': category,
      if (fishermanName != null) 'fisherman_name': fishermanName,
    };
  }

  static List<Inspection> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Inspection.fromJson(json)).toList();
  }
}

/////////////////////////////
// ✅ نموذج لمعلومات الدفعة
// ✅ نموذج لمعلومات الدفعة
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
