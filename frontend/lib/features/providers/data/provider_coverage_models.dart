import 'package:frontend/features/geography/data/geography_models.dart';

class CoverageAtollSummary {
  const CoverageAtollSummary({
    required this.atollId,
    required this.atollName,
    required this.atollCode,
    required this.islandCount,
  });

  final String atollId;
  final String atollName;
  final String atollCode;
  final int islandCount;

  factory CoverageAtollSummary.fromJson(Map<String, dynamic> json) {
    return CoverageAtollSummary(
      atollId: json['atollId'] as String,
      atollName: json['atollName'] as String? ?? '',
      atollCode: json['atollCode'] as String? ?? '',
      islandCount: json['islandCount'] as int? ?? 0,
    );
  }
}

class ProviderCoverage {
  const ProviderCoverage({
    required this.providerProfileId,
    required this.islands,
    required this.atollSummaries,
  });

  final String providerProfileId;
  final List<Island> islands;
  final List<CoverageAtollSummary> atollSummaries;

  factory ProviderCoverage.fromJson(Map<String, dynamic> json) {
    final rawIslands = json['islands'];
    final rawSummaries = json['atollSummaries'];
    return ProviderCoverage(
      providerProfileId: json['providerProfileId'] as String,
      islands: rawIslands is List
          ? rawIslands
              .whereType<Map<String, dynamic>>()
              .map(Island.fromJson)
              .toList()
          : const [],
      atollSummaries: rawSummaries is List
          ? rawSummaries
              .whereType<Map<String, dynamic>>()
              .map(CoverageAtollSummary.fromJson)
              .toList()
          : const [],
    );
  }
}
