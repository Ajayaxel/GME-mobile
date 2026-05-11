import 'package:equatable/equatable.dart';

class ExportRecord extends Equatable {
  final String id;
  final String shipmentId;
  final String? dispatchId;
  final String customer;
  final String destination;
  final String status;
  final Map<String, String> documents;

  const ExportRecord({
    required this.id,
    required this.shipmentId,
    this.dispatchId,
    required this.customer,
    required this.destination,
    required this.status,
    required this.documents,
  });

  factory ExportRecord.fromJson(Map<String, dynamic> json) {
    return ExportRecord(
      id: json['_id'] ?? '',
      shipmentId: json['shipmentId'] ?? '',
      dispatchId: json['dispatchId'],
      customer: json['customer'] ?? 'N/A',
      destination: json['destination'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
      documents: Map<String, String>.from(json['documents'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, shipmentId, status];
}
