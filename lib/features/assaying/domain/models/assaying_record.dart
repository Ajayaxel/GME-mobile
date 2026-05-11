import 'package:equatable/equatable.dart';

class AssayingRecord extends Equatable {
  final String id;
  final String sampleId;
  final String batchId;
  final String supplierName;
  final String customerName;
  final String testType;
  final String labName;
  final String purity;
  final List<String> mineralType;
  final String submittedDate;
  final String resultDate;
  final String status;
  final List<Map<String, dynamic>> qualityParameters;

  const AssayingRecord({
    required this.id,
    required this.sampleId,
    required this.batchId,
    required this.supplierName,
    required this.customerName,
    required this.testType,
    required this.labName,
    required this.purity,
    required this.mineralType,
    required this.submittedDate,
    required this.resultDate,
    required this.status,
    required this.qualityParameters,
  });

  factory AssayingRecord.fromJson(Map<String, dynamic> json) {
    return AssayingRecord(
      id: json['_id'] ?? '',
      sampleId: json['sampleId'] ?? '',
      batchId: json['batchId'] ?? '',
      supplierName: json['supplierName'] ?? 'N/A',
      customerName: json['customerName'] ?? 'N/A',
      testType: json['testType'] ?? '',
      labName: json['labName'] ?? '',
      purity: json['purity'] ?? '-',
      mineralType: List<String>.from(json['mineralType'] ?? []),
      submittedDate: json['submittedDate'] ?? '',
      resultDate: json['resultDate'] ?? '-',
      status: json['status'] ?? 'Pending',
      qualityParameters: List<Map<String, dynamic>>.from(json['qualityParameters'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, sampleId, batchId, status];
}
