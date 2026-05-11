import 'package:equatable/equatable.dart';

class BaggingRecord extends Equatable {
  final String id;
  final String baggingId;
  final String batchId;
  final String supplierName;
  final String customerName;
  final int numberOfBags;
  final double weightPerBag;
  final double totalWeight;
  final String warehouseLocation;
  final String baggingDate;
  final String status;

  const BaggingRecord({
    required this.id,
    required this.baggingId,
    required this.batchId,
    required this.supplierName,
    required this.customerName,
    required this.numberOfBags,
    required this.weightPerBag,
    required this.totalWeight,
    required this.warehouseLocation,
    required this.baggingDate,
    required this.status,
  });

  factory BaggingRecord.fromJson(Map<String, dynamic> json) {
    return BaggingRecord(
      id: json['_id'] ?? '',
      baggingId: json['baggingId'] ?? '',
      batchId: json['batchId'] ?? '',
      supplierName: json['supplierName'] ?? 'N/A',
      customerName: json['customerName'] ?? 'N/A',
      numberOfBags: (json['numberOfBags'] as num?)?.toInt() ?? 0,
      weightPerBag: (json['weightPerBag'] as num?)?.toDouble() ?? 0.0,
      totalWeight: (json['totalWeight'] as num?)?.toDouble() ?? 0.0,
      warehouseLocation: json['warehouseLocation'] ?? 'N/A',
      baggingDate: json['baggingDate'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  @override
  List<Object?> get props => [id, baggingId, batchId, status];
}
