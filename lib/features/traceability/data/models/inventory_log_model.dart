class InventoryLogModel {
  final String id;
  final String batchId;
  final double inputQty;
  final double outputQty;
  final double lossWeight;
  final String reason;
  final String userId;
  final DateTime createdAt;

  InventoryLogModel({
    required this.id,
    required this.batchId,
    required this.inputQty,
    required this.outputQty,
    required this.lossWeight,
    required this.reason,
    required this.userId,
    required this.createdAt,
  });

  factory InventoryLogModel.fromJson(Map<String, dynamic> json) {
    return InventoryLogModel(
      id: json['_id'] ?? '',
      batchId: json['batchId'] ?? '',
      inputQty: (json['inputQty'] ?? 0).toDouble(),
      outputQty: (json['outputQty'] ?? 0).toDouble(),
      lossWeight: (json['lossWeight'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'inputQty': inputQty,
      'outputQty': outputQty,
      'reason': reason,
    };
  }
}
