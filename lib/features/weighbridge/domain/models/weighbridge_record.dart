import 'package:equatable/equatable.dart';

class WeighbridgeRecord extends Equatable {
  final String id;
  final String vehicleNo;
  final String type;
  final String status;
  final String supplierName;
  final double grossWeight;
  final double tareWeight;
  final double netWeight;
  final DateTime dateTime;

  const WeighbridgeRecord({
    required this.id,
    required this.vehicleNo,
    required this.type,
    required this.status,
    required this.supplierName,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.dateTime,
  });

  factory WeighbridgeRecord.fromJson(Map<String, dynamic> json) {
    return WeighbridgeRecord(
      id: json['_id'] ?? '',
      vehicleNo: json['vehicleNo'] ?? 'N/A',
      type: json['type'] ?? 'Inbound',
      status: json['status'] ?? 'Pending',
      supplierName: json['supplierName'] ?? 'N/A',
      grossWeight: (json['grossWeight'] as num?)?.toDouble() ?? 0.0,
      tareWeight: (json['tareWeight'] as num?)?.toDouble() ?? 0.0,
      netWeight: (json['netWeight'] as num?)?.toDouble() ?? 0.0,
      dateTime: json['dateTime'] != null 
          ? (DateTime.tryParse(json['dateTime']) ?? DateTime.now()) 
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, vehicleNo, status, dateTime];
}
