class UserResponse {
  final List<UserData> data;
  final int dataLength;

  UserResponse({
    required this.data,
    required this.dataLength,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => UserData.fromJson(e))
          .toList() ??
          [],
      dataLength: json['dataLength'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'dataLength': dataLength,
    };
  }
}

class UserInfoResponse {
  final int statusCode;
  final UserData data;

  UserInfoResponse({required this.statusCode,
    required this.data
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      statusCode: json['status_code'],
      data: UserData.fromJson(json['data'])
    );
  }
}

class UserData {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final int? currentTeamId;
  final String displayName;
  final String? image;
  final String? address;
  final String? birthday;
  final String phone;
  final int departmentId;
  final String? gender;
  final int isDisabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String profilePhotoUrl;
  final String role;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.currentTeamId,
    required this.displayName,
    this.image,
    this.address,
    this.birthday,
    required this.phone,
    required this.departmentId,
    this.gender,
    required this.isDisabled,
    this.createdAt,
    this.updatedAt,
    required this.profilePhotoUrl,
    this.role = '',
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      currentTeamId: json['current_team_id'],
      displayName: json['displayname'] ?? json['displayName'] ?? '',
      image: json['image'],
      address: json['address'],
      birthday: json['birthday'],
      phone: json['phone'] ?? '',
      departmentId: json['department_id'] ?? 0,
      gender: json['gender'],
      isDisabled: json['is_disabled'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      profilePhotoUrl: json['profile_photo_url'] ?? json['profilePhotoUrl'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'current_team_id': currentTeamId,
      'displayname': displayName,
      'image': image,
      'address': address,
      'birthday': birthday,
      'phone': phone,
      'department_id': departmentId,
      'gender': gender,
      'is_disabled': isDisabled,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_photo_url': profilePhotoUrl,
      'role': role,
    };
  }
}