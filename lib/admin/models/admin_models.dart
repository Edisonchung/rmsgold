// lib/admin/models/admin_models.dart
import 'package:flutter/foundation.dart';

// Dashboard Data Model
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

  // Factory method to create mock data
  factory DashboardData.mock() {
    return DashboardData(
      totalUsers: 1250,
      newUsersToday: 15,
      pendingKYC: 8,
      todayTransactions: 127,
      todayVolume: 5240.75,
      goldInventory: 890.25,
      priceHistory: [470.0, 471.5, 473.0, 475.5, 474.0, 476.0, 475.5],
      weeklyVolume: [12000, 15000, 18000, 14000, 16000, 20000, 17000],
      recentActivities: [
        ActivityData(
          id: '1',
          type: ActivityType.goldPurchase,
          description: 'User purchased 2.5g gold',
          user: 'user123@email.com',
          timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        ),
        ActivityData(
          id: '2',
          type: ActivityType.kycSubmission,
          description: 'KYC application submitted',
          user: 'newuser@email.com',
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
        ),
        ActivityData(
          id: '3',
          type: ActivityType.goldSale,
          description: 'User sold 1.0g gold',
          user: 'user456@email.com',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
        ),
        ActivityData(
          id: '4',
          type: ActivityType.systemAlert,
          description: 'Gold price updated',
          user: 'system',
          timestamp: DateTime.now().subtract(Duration(hours: 3)),
        ),
        ActivityData(
          id: '5',
          type: ActivityType.userRegistration,
          description: 'New user registered',
          user: 'newbie@email.com',
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
        ),
      ],
      systemAlerts: [
        SystemAlert(
          id: 'alert_1',
          title: 'Low Gold Inventory',
          message: 'Gold inventory is below 100g threshold',
          severity: AlertSeverity.high,
          timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        ),
      ],
      pendingKYCUsers: [
        KYCUser(
          id: 'kyc_1',
          name: 'John Doe',
          email: 'john.doe@email.com',
          submittedAt: DateTime.now().subtract(Duration(days: 1)),
          documents: ['ic_front.jpg', 'ic_back.jpg', 'selfie.jpg'],
        ),
        KYCUser(
          id: 'kyc_2',
          name: 'Jane Smith',
          email: 'jane.smith@email.com',
          submittedAt: DateTime.now().subtract(Duration(days: 2)),
          documents: ['ic_front.jpg', 'ic_back.jpg', 'selfie.jpg'],
        ),
      ],
    );
  }
}

// Activity Data Model
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

// System Alert Model
class SystemAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// KYC User Model
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

// Transaction Data Model
class TransactionData {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final double price;
  final double total;
  final String status;
  final DateTime timestamp;
  final String paymentMethod;

  TransactionData({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.price,
    required this.total,
    required this.status,
    required this.timestamp,
    required this.paymentMethod,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      timestamp: json['timestamp'] is DateTime 
          ? json['timestamp'] 
          : DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'price': price,
      'total': total,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }
}

// User Model
class UserData {
  final String id;
  final String email;
  final String name;
  final String kycStatus;
  final double goldHoldings;
  final int totalTransactions;
  final DateTime joinDate;
  final DateTime lastActive;
  final String status;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    required this.kycStatus,
    required this.goldHoldings,
    required this.totalTransactions,
    required this.joinDate,
    required this.lastActive,
    required this.status,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      kycStatus: json['kycStatus'] ?? '',
      goldHoldings: (json['goldHoldings'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      joinDate: DateTime.tryParse(json['joinDate'] ?? '') ?? DateTime.now(),
      lastActive: DateTime.tryParse(json['lastActive'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'kycStatus': kycStatus,
      'goldHoldings': goldHoldings,
      'totalTransactions': totalTransactions,
      'joinDate': joinDate.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'status': status,
    };
  }
}

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
}
