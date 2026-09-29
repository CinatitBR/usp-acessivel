import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';

class MapReport {
  final String id;
  final String? userId;
  final String? poiId;
  final String? buildingId;
  final String reportType;
  final String? severity;
  final double lat;
  final double lon;
  final String? description;
  final String? imageUrl;
  final String? detailsJson;
  final String? status;
  final int? rejectionsCount;
  final String? createdAt;

  const MapReport({
    required this.id,
    this.userId,
    this.poiId,
    this.buildingId,
    required this.reportType,
    this.severity,
    required this.lat,
    required this.lon,
    this.description,
    this.imageUrl,
    this.detailsJson,
    this.status,
    this.rejectionsCount,
    this.createdAt,
  });

  factory MapReport.fromJson(Map<String, dynamic> json) {
    return MapReport(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      poiId: json['poiId'] as String?,
      buildingId: json['buildingId'] as String?,
      reportType: json['reportType'] as String? ?? 'other',
      severity: json['severity'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      detailsJson: json['detailsJson'] as String?,
      status: json['status'] as String?,
      rejectionsCount: json['rejectionsCount'] as int?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'poiId': poiId,
      'buildingId': buildingId,
      'reportType': reportType,
      'severity': severity,
      'lat': lat,
      'lon': lon,
      'description': description,
      'imageUrl': imageUrl,
      'detailsJson': detailsJson,
      'status': status,
      'rejectionsCount': rejectionsCount,
      'createdAt': createdAt,
    };
  }

  /// Label in Portuguese for the report type
  String get title {
    switch (reportType) {
      case 'pothole':
        return 'Buraco na via';
      case 'irregular_surface':
        return 'Superfície irregular';
      case 'narrow_sidewalk':
        return 'Calçada estreita';
      case 'inaccessible_entrance':
        return 'Entrada inacessível';
      case 'inaccessible_floor':
        return 'Andar inacessível';
      case 'broken_elevator':
        return 'Elevador com problema';
      case 'inaccessible_bathroom':
        return 'Banheiro inacessível';
      case 'other':
      default:
        return 'Relato no mapa';
    }
  }

  /// Conceptual category of this report
  String get categoryLabel {
    switch (reportType) {
      case 'pothole':
      case 'irregular_surface':
      case 'narrow_sidewalk':
        return 'Imperfeição na via';
      case 'inaccessible_entrance':
      case 'inaccessible_floor':
      case 'broken_elevator':
      case 'inaccessible_bathroom':
        return 'Problema de acessibilidade';
      case 'other':
      default:
        return 'Relato comunitário';
    }
  }

  /// Whether this report is a path imperfection with severity
  bool get isPathImperfection {
    return reportType == 'pothole' ||
        reportType == 'irregular_surface' ||
        reportType == 'narrow_sidewalk';
  }

  /// IconData matching the specific report type
  IconData get iconData {
    switch (reportType) {
      case 'pothole':
        return Icons.radio_button_checked_rounded;
      case 'irregular_surface':
        return Icons.terrain_rounded;
      case 'narrow_sidewalk':
        return Icons.compare_arrows_rounded;
      case 'inaccessible_entrance':
        return Icons.no_meeting_room_rounded;
      case 'inaccessible_floor':
        return Icons.layers_clear_rounded;
      case 'broken_elevator':
        return Icons.elevator_rounded;
      case 'inaccessible_bathroom':
        return Icons.wc_rounded;
      case 'other':
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// Color representing severity or default category color
  Color get color {
    if (severity == 'severe') {
      return AppColors.error; // Red
    }
    if (severity == 'moderate') {
      return AppColors.warning; // Yellow
    }
    if (!isPathImperfection) {
      return AppColors.primary; // Blue for accessibility issues
    }
    return AppColors.neutral[600]!;
  }

  /// Severity label in Portuguese
  String? get severityLabel {
    if (severity == 'severe') return 'Severo';
    if (severity == 'moderate') return 'Moderado';
    return null;
  }

  /// Identifier used to link the GeoJSON feature to the registered map image
  String get iconId {
    if (severity == 'severe') {
      return 'report-$reportType-severe';
    }
    if (severity == 'moderate') {
      return 'report-$reportType-moderate';
    }
    return 'report-$reportType';
  }
}
