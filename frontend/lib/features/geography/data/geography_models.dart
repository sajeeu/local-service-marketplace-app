class Atoll {
  const Atoll({
    required this.id,
    required this.name,
    required this.code,
    required this.displayOrder,
    required this.status,
    this.description,
  });

  final String id;
  final String name;
  final String code;
  final String? description;
  final int displayOrder;
  final String status;

  factory Atoll.fromJson(Map<String, dynamic> json) {
    return Atoll(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}

class Island {
  const Island({
    required this.id,
    required this.atollId,
    required this.name,
    required this.slug,
    required this.type,
    required this.displayOrder,
    required this.status,
    this.atollName,
    this.atollCode,
  });

  final String id;
  final String atollId;
  final String name;
  final String slug;
  final String type;
  final int displayOrder;
  final String status;
  final String? atollName;
  final String? atollCode;

  factory Island.fromJson(Map<String, dynamic> json) {
    final atoll = json['atoll'];
    return Island(
      id: json['id'] as String,
      atollId: json['atollId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      type: json['type'] as String? ?? 'INHABITED',
      displayOrder: json['displayOrder'] as int? ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
      atollName: json['atollName'] as String? ??
          (atoll is Map<String, dynamic> ? atoll['name'] as String? : null),
      atollCode: json['atollCode'] as String? ??
          (atoll is Map<String, dynamic> ? atoll['code'] as String? : null),
    );
  }
}
