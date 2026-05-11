import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final String id;
  final String invoiceNo;
  final String customerName;
  final String shipmentId;
  final double amount;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final String status;
  final String dateTime;
  final String currency;
  final List<LineItem> lineItems;

  const Invoice({
    required this.id,
    required this.invoiceNo,
    required this.customerName,
    required this.shipmentId,
    required this.amount,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.status,
    required this.dateTime,
    required this.currency,
    required this.lineItems,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      customerName: json['customerName'] ?? 'N/A',
      shipmentId: json['shipmentId'] ?? 'N/A',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      dateTime: json['dateTime'] ?? '',
      currency: json['currency'] ?? 'USD',
      lineItems: (json['lineItems'] as List?)
              ?.map((e) => LineItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, invoiceNo, status];
}

class LineItem extends Equatable {
  final String id;
  final String description;
  final int quantity;
  final double rate;
  final double total;

  const LineItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.total,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, description];
}
