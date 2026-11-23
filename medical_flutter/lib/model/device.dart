class DeviceModel {
  final int id;
  final String title;
  final String slug;
  final String alt;
  final String path;
  final String type;

  final String? content;
  final String? model;
  final String? warehouse;
  final String? risk;
  final String? process;
  final String? note;

  final String yearManufacture;
  final String code;
  final String serial;
  final String status;
  final String manufacturer;
  final String origin;
  final String yearUse;
  final String importPrice;

  final int amount;
  final int cateId;
  final int unitId;
  final int departmentId;
  final int image;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastInspection;
  final DateTime? nextInspection;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;

  DeviceModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.alt,
    required this.path,
    required this.type,
    required this.yearManufacture,
    required this.code,
    required this.serial,
    required this.status,
    required this.manufacturer,
    required this.origin,
    required this.yearUse,
    required this.importPrice,
    required this.amount,
    required this.cateId,
    required this.unitId,
    required this.departmentId,
    required this.image,
    this.content,
    this.model,
    this.warehouse,
    this.risk,
    this.process,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.lastInspection,
    this.nextInspection,
    this.lastMaintenance,
    this.nextMaintenance,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      alt: json['alt'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? '',
      content: json['content'],
      model: json['model'],
      warehouse: json['warehouse'],
      risk: json['risk'],
      process: json['process'],
      note: json['note'],
      yearManufacture: json['year_manufacture'] ?? '',
      code: json['code'] ?? '',
      serial: json['serial'] ?? '',
      status: json['status'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      origin: json['origin'] ?? '',
      yearUse: json['year_use'] ?? '',
      importPrice: json['import_price']?.toString() ?? '0',
      amount: json['amount'] ?? 0,
      cateId: json['cate_id'] ?? 0,
      unitId: json['unit_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      image: json['image'] ?? 0,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      lastInspection: _parseDate(json['last_inspection']),
      nextInspection: _parseDate(json['next_inspection']),
      lastMaintenance: _parseDate(json['last_maintenance']),
      nextMaintenance: _parseDate(json['next_maintenance']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}

class DeviceDetailModel {
  final int id;
  final String title;
  final String slug;
  final String code;
  final String serial;
  final String status;

  final String? model;
  final String? yearManufacture;
  final String? yearUse;
  final String? warehouse;
  final String? risk;
  final String? process;
  final String? note;
  final String? reason;
  final String? hashcode;
  final String? urlImg;

  final int amount;
  final int cateId;
  final int unitId;
  final int departmentId;
  final int image;

  final int? devicesId;
  final int? maintenanceId;
  final int? providerId;
  final int? repairId;
  final int? userId;
  final int? bidProjectId;
  final int? officerChargeId;
  final int? officersUseId;
  final int? officerDepartmentChargeId;
  final int? officersTrainingId;
  final int? supplieId;

  final String manufacturer;
  final String origin;

  final double? importPrice;

  final bool regularInspection;
  final bool regularMaintenance;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? firstInformation;
  final DateTime? dateFailure;
  final DateTime? lastInspection;
  final DateTime? nextInspection;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final DateTime? updateDay;

  DeviceDetailModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.code,
    required this.serial,
    required this.status,
    required this.amount,
    required this.cateId,
    required this.unitId,
    required this.departmentId,
    required this.image,
    required this.manufacturer,
    required this.origin,
    this.model,
    this.yearManufacture,
    this.yearUse,
    this.warehouse,
    this.risk,
    this.process,
    this.note,
    this.reason,
    this.hashcode,
    this.urlImg,
    this.devicesId,
    this.maintenanceId,
    this.providerId,
    this.repairId,
    this.userId,
    this.bidProjectId,
    this.officerChargeId,
    this.officersUseId,
    this.officerDepartmentChargeId,
    this.officersTrainingId,
    this.supplieId,
    this.importPrice,
    this.regularInspection = false,
    this.regularMaintenance = false,
    this.createdAt,
    this.updatedAt,
    this.firstInformation,
    this.dateFailure,
    this.lastInspection,
    this.nextInspection,
    this.lastMaintenance,
    this.nextMaintenance,
    this.updateDay,
  });

  factory DeviceDetailModel.fromJson(Map<String, dynamic> json) {
    return DeviceDetailModel(
      id: json['id'],
      title: json['title'] ?? '',
      model: json['model'],
      slug: json['slug'] ?? '',
      code: json['code'] ?? '',
      serial: json['serial'] ?? '',
      status: json['status'] ?? '',
      yearManufacture: json['year_manufacture'],
      yearUse: json['year_use'],
      warehouse: json['warehouse'],
      risk: json['risk'],
      process: json['process'],
      note: json['note'],
      reason: json['reason'],
      hashcode: json['hash_code'],
      urlImg: json['urlImg'],
      amount: json['amount'] ?? 0,
      cateId: json['cate_id'] ?? 0,
      unitId: json['unit_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      image: json['image'] ?? 0,
      devicesId: json['devices_id'],
      maintenanceId: json['maintenance_id'],
      providerId: json['provider_id'],
      repairId: json['repair_id'],
      userId: json['user_id'],
      bidProjectId: json['bid_project_id'],
      officerChargeId: json['officer_charge_id'],
      officersUseId: json['officers_use_id'],
      officerDepartmentChargeId: json['officer_department_charge_id'],
      officersTrainingId: json['officers_training_id'],
      supplieId: json['supplie_id'],
      manufacturer: json['manufacturer'] ?? '',
      origin: json['origin'] ?? '',
      importPrice: _parseDouble(json['import_price']),
      regularInspection: json['regular_inspection'] == 1,
      regularMaintenance: json['regular_maintenance'] == 1,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      firstInformation: _parseDate(json['first_information']),
      dateFailure: _parseDate(json['date_failure']),
      lastInspection: _parseDate(json['last_inspection']),
      nextInspection: _parseDate(json['next_inspection']),
      lastMaintenance: _parseDate(json['last_maintenance']),
      nextMaintenance: _parseDate(json['next_maintenance']),
      updateDay: _parseDate(json['update_day']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}



