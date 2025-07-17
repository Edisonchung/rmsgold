// ===== lib/models/user_model.dart =====
class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String icNumber;
  final String address;
  final String? bankAccount;
  final bool kycApproved;
  final bool mfaEnabled;
  final DateTime joinDate;
  final String? profileImageUrl;
  final KYCStatus kycStatus;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.icNumber,
    required this.address,
    this.bankAccount,
    required this.kycApproved,
    required this.mfaEnabled,
    required this.joinDate,
    this.profileImageUrl,
    required this.kycStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      icNumber: json['icNumber'],
      address: json['address'],
      bankAccount: json['bankAccount'],
      kycApproved: json['kycApproved'] ?? false,
      mfaEnabled: json['mfaEnabled'] ?? false,
      joinDate: DateTime.parse(json['joinDate']),
      profileImageUrl: json['profileImageUrl'],
      kycStatus: KYCStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['kycStatus'],
        orElse: () => KYCStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'icNumber': icNumber,
      'address': address,
      'bankAccount': bankAccount,
      'kycApproved': kycApproved,
      'mfaEnabled': mfaEnabled,
      'joinDate': joinDate.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'kycStatus': kycStatus.toString().split('.').last,
    };
  }
}

enum KYCStatus { pending, inReview, approved, rejected, incomplete }
