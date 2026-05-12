class DashboardStats {
  final double intakeVolume;
  final double processingVolume;
  final int activeShipments;
  final double pendingReceivables;
  final int pendingCount;
  final double totalRevenue;
  final double inventoryStock;

  DashboardStats({
    required this.intakeVolume,
    required this.processingVolume,
    required this.activeShipments,
    required this.pendingReceivables,
    required this.pendingCount,
    required this.totalRevenue,
    required this.inventoryStock,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      intakeVolume: (json['intakeVolume'] as num).toDouble(),
      processingVolume: (json['processingVolume'] as num).toDouble(),
      activeShipments: (json['activeShipments'] as num).toInt(),
      pendingReceivables: (json['pendingReceivables'] as num).toDouble(),
      pendingCount: (json['pendingCount'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      inventoryStock: (json['inventoryStock'] as num).toDouble(),
    );
  }
}

class DashboardActivity {
  final String type;
  final String reference;
  final String description;
  final String timestamp;
  final String status;

  DashboardActivity({
    required this.type,
    required this.reference,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    return DashboardActivity(
      type: json['type'] ?? '',
      reference: json['reference'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class DashboardTrend {
  final List<String> months;
  final Map<String, List<double>> throughput;
  final Map<String, List<double>> revenueVsCost;

  DashboardTrend({
    required this.months,
    required this.throughput,
    required this.revenueVsCost,
  });

  factory DashboardTrend.fromJson(Map<String, dynamic> json) {
    return DashboardTrend(
      months: List<String>.from(json['months']),
      throughput: (json['throughput'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<double>.from((v as List).map((x) => (x as num).toDouble()))),
      ),
      revenueVsCost: (json['revenueVsCost'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<double>.from((v as List).map((x) => (x as num).toDouble()))),
      ),
    );
  }
}

class DashboardData {
  final DashboardStats stats;
  final List<DashboardActivity> activities;
  final DashboardTrend trends;

  DashboardData({
    required this.stats,
    required this.activities,
    required this.trends,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: DashboardStats.fromJson(json['stats']),
      activities: (json['activities'] as List).map((i) => DashboardActivity.fromJson(i)).toList(),
      trends: DashboardTrend.fromJson(json['trends']),
    );
  }
}
