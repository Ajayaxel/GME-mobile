import 'dart:convert';

class YardIntakeModel {
  final String id;
  final String supplierName;
  final String customerName;
  final String vehicleNumber;
  final List<MaterialType> materialTypes;
  final double grossWeight;
  final double tareWeight;
  final double netWeight;
  final String grnNumber;
  final String status;
  final String userId;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  YardIntakeModel({
    required this.id,
    required this.supplierName,
    required this.customerName,
    required this.vehicleNumber,
    required this.materialTypes,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.grnNumber,
    required this.status,
    required this.userId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YardIntakeModel.fromJson(Map<String, dynamic> json) {
    return YardIntakeModel(
      id: json['_id'] ?? '',
      supplierName: json['supplierName'] ?? '',
      customerName: json['customerName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      materialTypes: (json['materialType'] as List?)
              ?.map((e) => MaterialType.fromJson(e))
              .toList() ??
          [],
      grossWeight: (json['grossWeight'] ?? 0).toDouble(),
      tareWeight: (json['tareWeight'] ?? 0).toDouble(),
      netWeight: (json['netWeight'] ?? 0).toDouble(),
      grnNumber: json['grnNumber'] ?? '',
      status: json['status'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }
}

class MaterialType {
  final String name;
  final double grossWeight;
  final double tareWeight;
  final double netWeight;
  final String id;

  MaterialType({
    required this.name,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.id,
  });

  factory MaterialType.fromJson(Map<String, dynamic> json) {
    return MaterialType(
      name: json['name'] ?? '',
      grossWeight: (json['grossWeight'] ?? 0).toDouble(),
      tareWeight: (json['tareWeight'] ?? 0).toDouble(),
      netWeight: (json['netWeight'] ?? 0).toDouble(),
      id: json['_id'] ?? '',
    );
  }
}
