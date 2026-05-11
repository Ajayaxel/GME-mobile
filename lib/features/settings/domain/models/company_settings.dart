class CompanySettings {
  final String id;
  final String name;
  final String address;
  final String rcNumber;
  final String tin;
  final String phone;
  final String email;
  final String logo;
  final double vatPercentage;
  final String defaultDiscountType;
  final double defaultDiscountValue;
  final List<String> vehicles;
  final List<String> materialTypes;
  final List<String> inspectionTypes;
  final List<String> inspectors;
  final List<String> laboratories;
  final List<String> machines;
  final List<String> destinations;
  final List<String> warehouses;

  CompanySettings({
    required this.id,
    required this.name,
    required this.address,
    required this.rcNumber,
    required this.tin,
    required this.phone,
    required this.email,
    required this.logo,
    required this.vatPercentage,
    required this.defaultDiscountType,
    required this.defaultDiscountValue,
    required this.vehicles,
    required this.materialTypes,
    required this.inspectionTypes,
    required this.inspectors,
    required this.laboratories,
    required this.machines,
    required this.destinations,
    required this.warehouses,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rcNumber: json['rcNumber'] ?? '',
      tin: json['tin'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      logo: json['logo'] ?? '',
      vatPercentage: (json['vatPercentage'] as num?)?.toDouble() ?? 0.0,
      defaultDiscountType: json['defaultDiscountType'] ?? 'Percentage',
      defaultDiscountValue: (json['defaultDiscountValue'] as num?)?.toDouble() ?? 0.0,
      vehicles: List<String>.from(json['vehicles'] ?? []),
      materialTypes: List<String>.from(json['materialTypes'] ?? []),
      inspectionTypes: List<String>.from(json['inspectionTypes'] ?? []),
      inspectors: List<String>.from(json['inspectors'] ?? []),
      laboratories: List<String>.from(json['laboratories'] ?? []),
      machines: List<String>.from(json['machines'] ?? []),
      destinations: List<String>.from(json['destinations'] ?? []),
      warehouses: List<String>.from(json['warehouses'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'rcNumber': rcNumber,
      'tin': tin,
      'phone': phone,
      'email': email,
      'vatPercentage': vatPercentage,
      'defaultDiscountType': defaultDiscountType,
      'defaultDiscountValue': defaultDiscountValue,
      'vehicles': vehicles,
      'materialTypes': materialTypes,
      'inspectionTypes': inspectionTypes,
      'inspectors': inspectors,
      'laboratories': laboratories,
      'machines': machines,
      'destinations': destinations,
      'warehouses': warehouses,
    };
  }

  CompanySettings copyWith({
    String? id,
    String? name,
    String? address,
    String? rcNumber,
    String? tin,
    String? phone,
    String? email,
    String? logo,
    double? vatPercentage,
    String? defaultDiscountType,
    double? defaultDiscountValue,
    List<String>? vehicles,
    List<String>? materialTypes,
    List<String>? inspectionTypes,
    List<String>? inspectors,
    List<String>? laboratories,
    List<String>? machines,
    List<String>? destinations,
    List<String>? warehouses,
  }) {
    return CompanySettings(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rcNumber: rcNumber ?? this.rcNumber,
      tin: tin ?? this.tin,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logo: logo ?? this.logo,
      vatPercentage: vatPercentage ?? this.vatPercentage,
      defaultDiscountType: defaultDiscountType ?? this.defaultDiscountType,
      defaultDiscountValue: defaultDiscountValue ?? this.defaultDiscountValue,
      vehicles: vehicles ?? this.vehicles,
      materialTypes: materialTypes ?? this.materialTypes,
      inspectionTypes: inspectionTypes ?? this.inspectionTypes,
      inspectors: inspectors ?? this.inspectors,
      laboratories: laboratories ?? this.laboratories,
      machines: machines ?? this.machines,
      destinations: destinations ?? this.destinations,
      warehouses: warehouses ?? this.warehouses,
    );
  }
}
