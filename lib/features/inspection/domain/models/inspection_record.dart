import 'package:equatable/equatable.dart';

class InspectionRecord extends Equatable {
  final String id;
  final String inspectionId;
  final String batchId;
  final String supplierName;
  final String customerName;
  final String inspectorName;
  final String inspectionType;
  final String scheduledDate;
  final String completedDate;
  final String observations;
  final String status;

  const InspectionRecord({
    required this.id,
    required this.inspectionId,
    required this.batchId,
    required this.supplierName,
    required this.customerName,
    required this.inspectorName,
    required this.inspectionType,
    required this.scheduledDate,
    required this.completedDate,
    required this.observations,
    required this.status,
  });

  factory InspectionRecord.fromJson(Map<String, dynamic> json) {
    return InspectionRecord(
      id: json['_id'] ?? '',
      inspectionId: json['inspectionId'] ?? '',
      batchId: json['batchId'] ?? '',
      supplierName: json['supplierName'] ?? 'N/A',
      customerName: json['customerName'] ?? 'N/A',
      inspectorName: json['inspectorName'] ?? '',
      inspectionType: json['inspectionType'] ?? '',
      scheduledDate: json['scheduledDate'] ?? '',
      completedDate: json['completedDate'] ?? '-',
      observations: json['observations'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  @override
  List<Object?> get props => [id, inspectionId, batchId, status];
}
