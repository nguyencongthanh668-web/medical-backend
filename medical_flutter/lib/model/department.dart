class DepartmentResponse {
  final int statusCode;
  final DepartmentModel data;
  final int dataLength;

  DepartmentResponse({
    required this.statusCode,
    required this.data,
    required this.dataLength,
  });

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentResponse(
      statusCode: json['status_code'],
      data: DepartmentModel.fromJson(json['data']),
      dataLength: json['dataLength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'data': data.toJson(),
      'dataLength': dataLength,
    };
  }
}


class DepartmentResponseX {
  final int statusCode;
  final List<DepartmentModel> data;

  DepartmentResponseX({
    required this.statusCode,
    required this.data,
  });

  factory DepartmentResponseX.fromJson(Map<String, dynamic> json) {
    return DepartmentResponseX(
      statusCode: json['status_code'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((e) => DepartmentModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}


class DepartmentModel {
  final int id;
  final String title;
  final String code;
  final String slug;
  final String phone;
  final String contact;
  final String email;
  final String address;
  final int userId;
  final int? authorId;
  final int? nursingId;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? browser;
  final String? browserDay;

  DepartmentModel({
    required this.id,
    required this.title,
    required this.code,
    required this.slug,
    required this.phone,
    required this.contact,
    required this.email,
    required this.address,
    required this.userId,
    this.authorId,
    this.nursingId,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.browser,
    this.browserDay,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      title: json['title'],
      code: json['code'],
      slug: json['slug'],
      phone: json['phone'],
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
      userId: json['user_id'],
      authorId: json['author_id'],
      nursingId: json['nursing_id'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      browser: json['browser'],
      browserDay: json['browser_day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'slug': slug,
      'phone': phone,
      'contact': contact,
      'email': email,
      'address': address,
      'user_id': userId,
      'author_id': authorId,
      'nursing_id': nursingId,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'browser': browser,
      'browser_day': browserDay,
    };
  }
}
