class ProfileCompletion {
  const ProfileCompletion({
    required this.status,
    required this.percent,
  });

  final String status;
  final int percent;

  factory ProfileCompletion.fromJson(Map<String, dynamic> json) {
    return ProfileCompletion(
      status: json['status'] as String,
      percent: (json['percent'] as num).toInt(),
    );
  }
}

class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.languages,
    required this.visibility,
    required this.status,
    required this.completion,
    this.businessName,
    this.description,
    this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
    this.logoUrl,
    this.coverImageUrl,
    this.businessSettings,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? businessName;
  final String? description;
  final String? contactEmail;
  final String? contactPhone;
  final String? websiteUrl;
  final String? logoUrl;
  final String? coverImageUrl;
  final List<String> languages;
  final Map<String, dynamic>? businessSettings;
  final String visibility;
  final String status;
  final ProfileCompletion completion;
  final String? createdAt;
  final String? updatedAt;

  bool get isComplete => completion.status == 'COMPLETE';
  bool get isActive => status == 'ACTIVE';

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      businessName: json['businessName'] as String?,
      description: json['description'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      languages: (json['languages'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      businessSettings: json['businessSettings'] is Map<String, dynamic>
          ? json['businessSettings'] as Map<String, dynamic>
          : null,
      visibility: json['visibility'] as String,
      status: json['status'] as String,
      completion: ProfileCompletion.fromJson(
        json['completion'] as Map<String, dynamic>,
      ),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class CreateProviderProfileInput {
  const CreateProviderProfileInput({
    required this.displayName,
    this.businessName,
    this.description,
    this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
    this.logoUrl,
    this.coverImageUrl,
    this.languages = const [],
    this.visibility = 'PRIVATE',
  });

  final String displayName;
  final String? businessName;
  final String? description;
  final String? contactEmail;
  final String? contactPhone;
  final String? websiteUrl;
  final String? logoUrl;
  final String? coverImageUrl;
  final List<String> languages;
  final String visibility;

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      if (businessName != null && businessName!.isNotEmpty)
        'businessName': businessName,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (contactEmail != null && contactEmail!.isNotEmpty)
        'contactEmail': contactEmail,
      if (contactPhone != null && contactPhone!.isNotEmpty)
        'contactPhone': contactPhone,
      if (websiteUrl != null && websiteUrl!.isNotEmpty) 'websiteUrl': websiteUrl,
      if (logoUrl != null && logoUrl!.isNotEmpty) 'logoUrl': logoUrl,
      if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
        'coverImageUrl': coverImageUrl,
      if (languages.isNotEmpty) 'languages': languages,
      'visibility': visibility,
    };
  }
}

class UpdateProviderProfileInput {
  const UpdateProviderProfileInput({
    this.displayName,
    this.businessName,
    this.description,
    this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
    this.logoUrl,
    this.coverImageUrl,
    this.languages,
    this.visibility,
  });

  final String? displayName;
  final String? businessName;
  final String? description;
  final String? contactEmail;
  final String? contactPhone;
  final String? websiteUrl;
  final String? logoUrl;
  final String? coverImageUrl;
  final List<String>? languages;
  final String? visibility;

  Map<String, dynamic> toJson() {
    return {
      if (displayName != null) 'displayName': displayName,
      if (businessName != null) 'businessName': businessName,
      if (description != null) 'description': description,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (websiteUrl != null) 'websiteUrl': websiteUrl,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (languages != null) 'languages': languages,
      if (visibility != null) 'visibility': visibility,
    };
  }
}
