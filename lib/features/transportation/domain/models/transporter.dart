import 'package:equatable/equatable.dart';

class Transporter extends Equatable {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String email;
  final String vatNumber;

  const Transporter({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.vatNumber,
  });

  factory Transporter.fromJson(Map<String, dynamic> json) {
    return Transporter(
      id: json['_id'] ?? '',
      companyName: json['companyName'] ?? '',
      contactPerson: json['contactPerson'] ?? 'N/A',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      vatNumber: json['vatNumber'] ?? json['gstNumber'] ?? 'N/A',
    );
  }

  @override
  List<Object?> get props => [id, companyName];
}
