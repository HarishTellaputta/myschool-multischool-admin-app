
class SchoolResponse {
  final int? id;
  final String? name;
  final String? code;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? website;
  final String? logoUrl;
  final String? principalMessage;
  final String? principalName;
  final String? facilities;
  final String? facultyInfo;
  final String? establishmentYear;
  final String? affiliationNumber;
  final String? schoolType;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SchoolResponse({
    this.id,
    this.name,
    this.code,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.website,
    this.logoUrl,
    this.principalMessage,
    this.principalName,
    this.facilities,
    this.facultyInfo,
    this.establishmentYear,
    this.affiliationNumber,
    this.schoolType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory SchoolResponse.fromJson(Map<String, dynamic> json) {
    return SchoolResponse(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postalCode']?.toString(),
      country: json['country']?.toString(),
      website: json['website']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      principalMessage: json['principalMessage']?.toString(),
      principalName: json['principalName']?.toString(),
      facilities: json['facilities']?.toString(),
      facultyInfo: json['facultyInfo']?.toString(),
      establishmentYear: json['establishmentYear']?.toString(),
      affiliationNumber: json['affiliationNumber']?.toString(),
      schoolType: json['schoolType']?.toString(),
      status: json['status']?.toString(),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'website': website,
      'logoUrl': logoUrl,
      'principalMessage': principalMessage,
      'principalName': principalName,
      'facilities': facilities,
      'facultyInfo': facultyInfo,
      'establishmentYear': establishmentYear,
      'affiliationNumber': affiliationNumber,
      'schoolType': schoolType,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
