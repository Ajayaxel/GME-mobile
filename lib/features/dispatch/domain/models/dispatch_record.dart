import 'package:equatable/equatable.dart';

class DispatchRecord extends Equatable {
  final String id;
  final String dispatchId;
  final String batchId;
  final String supplierName;
  final String customerName;
  final String containerNumber;
  final double loadingWeight;
  final String destination;
  final String dispatchDate;
  final String deliveryDate;
  final String driverName;
  final String contactNumber;
  final String status;

  const DispatchRecord({
    required this.id,
    required this.dispatchId,
    required this.batchId,
    required this.supplierName,
    required this.customerName,
    required this.containerNumber,
    required this.loadingWeight,
    required this.destination,
    required this.dispatchDate,
    required this.deliveryDate,
    required this.driverName,
    required this.contactNumber,
    required this.status,
  });

  factory DispatchRecord.fromJson(Map<String, dynamic> json) {
    return DispatchRecord(
      id: json['_id'] ?? '',
      dispatchId: json['dispatchId'] ?? '',
      batchId: json['batchId'] ?? '',
      supplierName: json['supplierName'] ?? 'N/A',
      customerName: json['customerName'] ?? 'N/A',
      containerNumber: json['containerNumber'] ?? 'N/A',
      loadingWeight: (json['loadingWeight'] as num?)?.toDouble() ?? 0.0,
      destination: json['destination'] ?? 'N/A',
      dispatchDate: json['dispatchDate'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '-',
      driverName: json['driverName'] ?? 'N/A',
      contactNumber: json['contactNumber'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
    );
  }

  @override
  List<Object?> get props => [id, dispatchId, batchId, status];
}
