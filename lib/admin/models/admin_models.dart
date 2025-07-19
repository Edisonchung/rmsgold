// lib/admin/models/admin_models.dart
import 'package:flutter/foundation.dart';

// Enums
enum ActivityType {
  userRegistration,
  goldPurchase,
  goldSale,
  kycSubmission,
  systemAlert,
  priceUpdate,
  inventoryUpdate,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum KYCStatus {
  pending,
  approved,
  rejected,
  underReview,
  incomplete,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum UserStatus {
  active,
  inactive,
  blocked,
  suspended,
  banned,
  pending,
}

enum AdminRole { 
  superAdmin, 
  kycOfficer, 
  inventoryManager,
  support 
}

// Main Models
class DashboardData {
  final int totalUsers;
  final int newUsersToday;
  final int pendingKYC;
  final int todayTransactions;
  final double todayVolume;
  final double goldInventory;
  final List<double> priceHistory;
  final List<double> weeklyVolume;
  final List<ActivityData> recentActivities;
  final List<SystemAlert> systemAlerts;
  final List<KYCUser> pendingKYCUsers;

  DashboardData({
    required this.totalUsers,
    required this.newUsersToday,
    required this.pendingKYC,
    required this.todayTransactions,
    required this.todayVolume,
    required this.goldInventory,
    required this.priceHistory,
    required this.weeklyVolume,
    required this.recentActivities,
    required this.systemAlerts,
    required this.pendingKYCUsers,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalUsers: json['totalUsers'] ?? 0,
      newUsersToday: json['newUsersToday'] ?? 0,
      pendingKYC: json['pendingKYC'] ?? 0,
      todayTransactions: json['todayTransactions'] ?? 0,
      todayVolume: (json['todayVolume'] ?? 0.0).toDouble(),
      goldInventory: (json['goldInventory'] ?? 0.0).toDouble(),
      priceHistory: List<double>.from(json['priceHistory'] ?? []),
      weeklyVolume: List<double>.from(json['weeklyVolume'] ?? []),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((e) => ActivityData.fromJson(e))
          .toList(),
      systemAlerts: (json['systemAlerts'] as List? ?? [])
          .map((e) => SystemAlert.fromJson(e))
          .toList(),
      pendingKYCUsers: (json['pendingKYCUsers'] as List? ?? [])
          .map((e) => KYCUser.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'newUsersToday': newUsersToday,
      'pendingKYC': pendingKYC,
      'todayTransactions': todayTransactions,
      'todayVolume': todayVolume,
      'goldInventory': goldInventory,
      'priceHistory': priceHistory,
      'weeklyVolume': weeklyVolume,
      'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
      'systemAlerts': systemAlerts.map((e) => e.toJson()).toList(),
      'pendingKYCUsers': pendingKYCUsers.map((e) => e.toJson()).toList(),
    };
  }
}

class ActivityData {
  final String id;
  final ActivityType type;
  final String description;
  final String user;
  final DateTime timestamp;

  ActivityData({
    required this.id,
    required this.type,
    required this.description,
    required this.user,
    required this.timestamp,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      id: json['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
        orElse: () => ActivityType.userRegistration,
      ),
      description: json['description'] ?? '',
      user: json['user'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'description': description,
      'user': user,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SystemAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  factory SystemAlert.fromJson(Map<String, dynamic> json) {
    return SystemAlert(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString() == 'AlertSeverity.${json['severity']}',
        orElse: () => AlertSeverity.low,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}

class KYCUser {
  final String id;
  final String name;
  final String email;
  final DateTime submittedAt;
  final List<String> documents;
  final String? status;

  KYCUser({
    required this.id,
    required this.name,
    required this.email,
    required this.submittedAt,
    required this.documents,
    this.status,
  });

  factory KYCUser.fromJson(Map<String, dynamic> json) {
    return KYCUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
      documents: List<String>.from(json['documents'] ?? []),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'submittedAt': submittedAt.toIso8601String(),
      'documents': documents,
      'status': status,
    };
  }
}

class UserProfile {
  final String id;
  final String email;
  final String name;
  final UserStatus status;
  final KYCStatus kycStatus;
  final double goldHoldings;
  final int totalTransactions;
  final DateTime joinDate;
  final DateTime lastActive;
  final String? phoneNumber;
  final String? address;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.status,
    required this.kycStatus,
    required this.goldHoldings,
    required this.totalTransactions,
    required this.joinDate,
    required this.lastActive,
    this.phoneNumber,
    this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == 'UserStatus.${json['status']}',
        orElse: () => UserStatus.active,
      ),
      kycStatus: KYCStatus.values.firstWhere(
        (e) => e.toString() == 'KYCStatus.${json['kycStatus']}',
        orElse: () => KYCStatus.pending,
      ),
      goldHoldings: (json['goldHoldings'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      joinDate: DateTime.tryParse(json['joinDate'] ?? '') ?? DateTime.now(),
      lastActive: DateTime.tryParse(json['lastActive'] ?? '') ?? DateTime.now(),
      phoneNumber: json['phoneNumber'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'status': status.toString().split('.').last,
      'kycStatus': kycStatus.toString().split('.').last,
      'goldHoldings': goldHoldings,
      'totalTransactions': totalTransactions,
      'joinDate': joinDate.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}

class GoldInventory {
  final double totalGold;
  final double availableGold;
  final double reservedGold;
  final double reorderLevel;
  final DateTime lastUpdated;
  final List<InventoryMovement> recentMovements;

  GoldInventory({
    required this.totalGold,
    required this.availableGold,
    required this.reservedGold,
    required this.reorderLevel,
    required this.lastUpdated,
    required this.recentMovements,
  });

  factory GoldInventory.fromJson(Map<String, dynamic> json) {
    return GoldInventory(
      totalGold: (json['totalGold'] ?? 0.0).toDouble(),
      availableGold: (json['availableGold'] ?? 0.0).toDouble(),
      reservedGold: (json['reservedGold'] ?? 0.0).toDouble(),
      reorderLevel: (json['reorderLevel'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      recentMovements: (json['recentMovements'] as List? ?? [])
          .map((e) => InventoryMovement.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGold': totalGold,
      'availableGold': availableGold,
      'reservedGold': reservedGold,
      'reorderLevel': reorderLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
      'recentMovements': recentMovements.map((e) => e.toJson()).toList(),
    };
  }
}

class InventoryMovement {
  final String id;
  final String type; // 'IN', 'OUT', 'RESERVED', 'RELEASED'
  final double amount;
  final String description;
  final DateTime timestamp;
  final String? reference;

  InventoryMovement({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.reference,
  });

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'reference': reference,
    };
  }
}

class PriceManagement {
  final double currentPrice;
  final double buySpread;
  final double sellSpread;
  final double buyPrice;
  final double sellPrice;
  final DateTime lastUpdated;
  final bool isPriceOverridden;
  final String? overrideReason;
  final List<PriceHistory> priceHistory;

  PriceManagement({
    required this.currentPrice,
    required this.buySpread,
    required this.sellSpread,
    required this.buyPrice,
    required this.sellPrice,
    required this.lastUpdated,
    required this.isPriceOverridden,
    this.overrideReason,
    required this.priceHistory,
  });

  factory PriceManagement.fromJson(Map<String, dynamic> json) {
    return PriceManagement(
      currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
      buySpread: (json['buySpread'] ?? 0.0).toDouble(),
      sellSpread: (json['sellSpread'] ?? 0.0).toDouble(),
      buyPrice: (json['buyPrice'] ?? 0.0).toDouble(),
      sellPrice: (json['sellPrice'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      isPriceOverridden: json['isPriceOverridden'] ?? false,
      overrideReason: json['overrideReason'],
      priceHistory: (json['priceHistory'] as List? ?? [])
          .map((e) => PriceHistory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPrice': currentPrice,
      'buySpread': buySpread,
      'sellSpread': sellSpread,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isPriceOverridden': isPriceOverridden,
      'overrideReason': overrideReason,
      'priceHistory': priceHistory.map((e) => e.toJson()).toList(),
    };
  }
}

class PriceHistory {
  final String id;
  final double price;
  final DateTime timestamp;
  final String source; // 'market', 'override'
  final String? adminId;

  PriceHistory({
    required this.id,
    required this.price,
    required this.timestamp,
    required this.source,
    this.adminId,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      id: json['id'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      source: json['source'] ?? 'market',
      adminId: json['adminId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'adminId': adminId,
    };
  }
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<String> permissions;
  final bool mfaEnabled;
  final DateTime lastLogin;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.mfaEnabled,
    required this.lastLogin,
    this.isActive = true,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => AdminRole.support,
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
      mfaEnabled: json['mfaEnabled'] ?? false,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'permissions': permissions,
      'mfaEnabled': mfaEnabled,
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class TransactionData {
  final String id;
  final String userId;
  final String userName;
  final String type; // 'buy', 'sell'
  final double goldAmount;
  final double totalAmount;
  final double pricePerGram;
  final DateTime timestamp;
  final TransactionStatus status;
  final String paymentMethod;
  final bool isFlagged;
  final String? flagReason;

  TransactionData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.goldAmount,
    required this.totalAmount,
    required this.pricePerGram,
    required this.timestamp,
    required this.status,
    required this.paymentMethod,
    this.isFlagged = false,
    this.flagReason,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      type: json['type'] ?? '',
      goldAmount: (json['goldAmount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      pricePerGram: (json['pricePerGram'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] is DateTime 
          ? json['timestamp'] 
          : DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
        orElse: () => TransactionStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] ?? '',
      isFlagged: json['isFlagged'] ?? false,
      flagReason: json['flagReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type,
      'goldAmount': goldAmount,
      'totalAmount': totalAmount,
      'pricePerGram': pricePerGram,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'isFlagged': isFlagged,
      'flagReason': flagReason,
    };
  }
}
