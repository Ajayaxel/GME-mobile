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
      supplierName: json['supplierName'] ?? '',
      customerName: json['customerName'] ?? '',
      numberOfBags: json['numberOfBags'] ?? 0,
      weightPerBag: (json['weightPerBag'] ?? 0).toDouble(),
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
      warehouseLocation: json['warehouseLocation'] ?? '',
      baggingDate: json['baggingDate'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baggingId': baggingId,
      'batchId': batchId,
      'supplierName': supplierName,
      'customerName': customerName,
      'numberOfBags': numberOfBags,
      'weightPerBag': weightPerBag,
      'warehouseLocation': warehouseLocation,
      'baggingDate': baggingDate,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        baggingId,
        batchId,
        supplierName,
        customerName,
        numberOfBags,
        weightPerBag,
        totalWeight,
        warehouseLocation,
        baggingDate,
        status,
      ];
}
