import 'package:equatable/equatable.dart';

class Client extends Equatable {
  final String id;
  final String name;
  final String address;
  final String tin;
  final String phone;
  final String email;
  final DateTime registrationDate;
  final String status;
  final String primaryContact;
  final String industry;
  final String type;
  final DateTime createdAt;

  const Client({
    required this.id,
    required this.name,
    required this.address,
    required this.tin,
    required this.phone,
    required this.email,
    required this.registrationDate,
    required this.status,
    required this.primaryContact,
    required this.industry,
    required this.type,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      tin: json['tin'] ?? json['vatNumber'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      registrationDate: json['registrationDate'] != null 
          ? DateTime.parse(json['registrationDate']) 
          : DateTime.now(),
      status: json['status'] ?? 'Onboarding',
      primaryContact: json['primaryContact'] ?? 'N/A',
      industry: json['industry'] ?? 'N/A',
      type: json['type'] ?? 'Supplier',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, status, type];
}
