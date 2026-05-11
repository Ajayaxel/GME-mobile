class ProcessingBatch {
  final String id;
  final String batchId;
  final List<String> rawMaterial;
  final double inputQuantity;
  final String machineAssigned;
  final String outputGrade;
  final double outputQuantity;
  final DateTime processingDate;
  final String supplierName;
  final String customerName;
  final String grnReference;
  final String status;
  final String operator;
  final String supervisor;

  ProcessingBatch({
    required this.id,
    required this.batchId,
    required this.rawMaterial,
    required this.inputQuantity,
    required this.machineAssigned,
    required this.outputGrade,
    required this.outputQuantity,
    required this.processingDate,
    required this.supplierName,
    required this.customerName,
    required this.grnReference,
    required this.status,
    required this.operator,
    required this.supervisor,
  });

  factory ProcessingBatch.fromJson(Map<String, dynamic> json) {
    return ProcessingBatch(
      id: json['_id'] ?? '',
      batchId: json['batchId'] ?? '',
      rawMaterial: List<String>.from(json['rawMaterial'] ?? []),
      inputQuantity: (json['inputQuantity'] as num?)?.toDouble() ?? 0.0,
      machineAssigned: json['machineAssigned'] ?? '',
      outputGrade: json['outputGrade'] ?? '',
      outputQuantity: (json['outputQuantity'] as num?)?.toDouble() ?? 0.0,
      processingDate: DateTime.parse(json['processingDate'] ?? DateTime.now().toIso8601String()),
      supplierName: json['supplierName'] ?? 'N/A',
      customerName: json['customerName'] ?? 'N/A',
      grnReference: json['grnReference'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
      operator: json['operator'] ?? 'N/A',
      supervisor: json['supervisor'] ?? 'N/A',
    );
  }
}
