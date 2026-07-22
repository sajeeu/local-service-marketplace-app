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

class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.status,
    required this.completion,
    this.avatarUrl,
    this.contactEmail,
    this.contactPhone,
    this.preferences,
    this.savedSettings,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? contactEmail;
  final String? contactPhone;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? savedSettings;
  final String status;
  final ProfileCompletion completion;
  final String? createdAt;
  final String? updatedAt;

  bool get isComplete => completion.status == 'COMPLETE';
  bool get isActive => status == 'ACTIVE';

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      preferences: json['preferences'] is Map<String, dynamic>
          ? json['preferences'] as Map<String, dynamic>
          : null,
      savedSettings: json['savedSettings'] is Map<String, dynamic>
          ? json['savedSettings'] as Map<String, dynamic>
          : null,
      status: json['status'] as String,
      completion: ProfileCompletion.fromJson(
        json['completion'] as Map<String, dynamic>,
      ),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class CreateCustomerProfileInput {
  const CreateCustomerProfileInput({
    required this.displayName,
    this.avatarUrl,
    this.contactEmail,
    this.contactPhone,
  });

  final String displayName;
  final String? avatarUrl;
  final String? contactEmail;
  final String? contactPhone;

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      if (avatarUrl != null && avatarUrl!.isNotEmpty) 'avatarUrl': avatarUrl,
      if (contactEmail != null && contactEmail!.isNotEmpty)
        'contactEmail': contactEmail,
      if (contactPhone != null && contactPhone!.isNotEmpty)
        'contactPhone': contactPhone,
    };
  }
}

class UpdateCustomerProfileInput {
  const UpdateCustomerProfileInput({
    this.displayName,
    this.avatarUrl,
    this.contactEmail,
    this.contactPhone,
  });

  final String? displayName;
  final String? avatarUrl;
  final String? contactEmail;
  final String? contactPhone;

  Map<String, dynamic> toJson() {
    return {
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (contactPhone != null) 'contactPhone': contactPhone,
    };
  }
}
