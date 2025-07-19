// lib/admin/models/admin_models.dart
enum AdminRole {
  superAdmin,
  kycOfficer,
  inventoryManager,
  customerService
}

enum Permission {
  userManagement,
  kycApproval,
  priceManagement,
  inventoryControl,
  transactionMonitoring,
  reporting,
  systemConfig,
  announcementManagement
}

enum ActivityType {
  userRegistration,
  goldPurchase,
  goldSale,
  kycSubmission,
  kycApproval,
  kycRejection,
  priceUpdate,
  inventoryUpdate,
  systemAlert,
  adminLogin,
  suspiciousActivity
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical
}

enum UserStatus {
  active,
  suspended,
  banned,
  pending
}

enum KYCStatus {
  pending,
  approved,
  rejected,
  incomplete
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<Permission> permissions;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: AdminRole.values.firstWhere(
        (e) => e.toString() == 'AdminRole.${json['role']}',
      ),
      permissions: (json['permissions'] as List)
          .map((p) => Permission.values.firstWhere(
                (e) => e.toString() == 'Permission.$p',
              ))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'permissions': permissions.map((p) => p.toString().split('.').last).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class DashboardData {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int pendingKYC;
  final double todayVolume;
  final int todayTransactions;
  final double goldInventory;
  final double currentGoldPrice;
  final List<double> priceHistory;
  final List<double> weeklyVolume;
  final List<RecentActivity> recentActivities;
  final List<SystemAlert> systemAlerts;
  final List<KYCUser> pendingKYCUsers;

  DashboardData({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.pendingKYC,
    required this.todayVolume,
    required this.todayTransactions,
    required this.goldInventory,
    required this.currentGoldPrice,
    required this.priceHistory,
    required this.weeklyVolume,
    required this.recentActivities,
    required this.systemAlerts,
    required this.pendingKYCUsers,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalUsers: json['totalUsers'],
      activeUsers: json['activeUsers'],
      newUsersToday: json['newUsersToday'],
      pendingKYC: json['pendingKYC'],
      todayVolume: json['todayVolume'].toDouble(),
      todayTransactions: json['todayTransactions'],
      goldInventory: json['goldInventory'].toDouble(),
      currentGoldPrice: json['currentGoldPrice'].toDouble(),
      priceHistory: List<double>.from(json['priceHistory']),
      weeklyVolume: List<double>.from(json['weeklyVolume']),
      recentActivities: (json['recentActivities'] as List)
          .map((a) => RecentActivity.fromJson(a))
          .toList(),
      systemAlerts: (json['systemAlerts'] as List)
          .map((a) => SystemAlert.fromJson(a))
          .toList(),
      pendingKYCUsers: (json['pendingKYCUsers'] as List)
          .map((u) => KYCUser.fromJson(u))
          .toList(),
    );
  }
}

class RecentActivity {
  final String id;
  final ActivityType type;
  final String description;
  final String user;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.user,
    required this.timestamp,
    this.metadata,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
      ),
      description: json['description'],
      user: json['user'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }
}

class SystemAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;

  SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
  });

  factory SystemAlert.fromJson(Map<String, dynamic> json) {
    return SystemAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString() == 'AlertSeverity.${json['severity']}',
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl'],
    );
  }
}

class KYCUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final KYCStatus status;
  final DateTime submittedAt;
  final KYCDocuments documents;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  KYCUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.submittedAt,
    required this.documents,
    this.rejectionReason,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory KYCUser.fromJson(Map<String, dynamic> json) {
    return KYCUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      status: KYCStatus.values.firstWhere(
        (e) => e.toString() == 'KYCStatus.${json['status']}',
      ),
      submittedAt: DateTime.parse(json['submittedAt']),
      documents: KYCDocuments.fromJson(json['documents']),
      rejectionReason: json['rejectionReason'],
      reviewedAt: json['reviewedAt'] != null 
          ? DateTime.parse(json['reviewedAt']) 
          : null,
      reviewedBy: json['reviewedBy'],
    );
  }
}

class KYCDocuments {
  final String? icFront;
  final String? icBack;
  final String? passport;
  final String? proofOfAddress;
  final String? bankStatement;

  KYCDocuments({
    this.icFront,
    this.icBack,
    this.passport,
    this.proofOfAddress,
    this.bankStatement,
  });

  factory KYCDocuments.fromJson(Map<String, dynamic> json) {
    return KYCDocuments(
      icFront: json['icFront'],
      icBack: json['icBack'],
      passport: json['passport'],
      proofOfAddress: json['proofOfAddress'],
      bankStatement: json['bankStatement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icFront': icFront,
      'icBack': icBack,
      'passport': passport,
      'proofOfAddress': proofOfAddress,
      'bankStatement': bankStatement,
    };
  }
}

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? address;
  final String? bankAccount;
  final UserStatus status;
  final KYCStatus kycStatus;
  final DateTime registeredAt;
  final DateTime lastLogin;
  final double goldBalance;
  final double portfolioValue;
  final int totalTransactions;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    this.bankAccount,
    required this.status,
    required this.kycStatus,
    required this.registeredAt,
    required this.lastLogin,
    required this.goldBalance,
    required this.portfolioValue,
    required this.totalTransactions,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      bankAccount: json['bankAccount'],
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == 'UserStatus.${json['status']}',
      ),
      kycStatus: KYCStatus.values.firstWhere(
        (e) => e.toString() == 'KYCStatus.${json['kycStatus']}',
      ),
      registeredAt: DateTime.parse(json['registeredAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      goldBalance: json['goldBalance'].toDouble(),
      portfolioValue: json['portfolioValue'].toDouble(),
      totalTransactions: json['totalTransactions'],
    );
  }
}

class GoldInventory {
  final String id;
  final double totalGold;
  final double reservedGold;
  final double availableGold;
  final double lowStockThreshold;
  final DateTime lastUpdated;
  final List<InventoryTransaction> recentTransactions;

  GoldInventory({
    required this.id,
    required this.totalGold,
    required this.reservedGold,
    required this.availableGold,
    required this.lowStockThreshold,
    required this.lastUpdated,
    required this.recentTransactions,
  });

  bool get isLowStock => availableGold <= lowStockThreshold;

  factory GoldInventory.fromJson(Map<String, dynamic> json) {
    return GoldInventory(
      id: json['id'],
      totalGold: json['totalGold'].toDouble(),
      reservedGold: json['reservedGold'].toDouble(),
      availableGold: json['availableGold'].toDouble(),
      lowStockThreshold: json['lowStockThreshold'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      recentTransactions: (json['recentTransactions'] as List)
          .map((t) => InventoryTransaction.fromJson(t))
          .toList(),
    );
  }
}

class InventoryTransaction {
  final String id;
  final String type; // 'purchase', 'sale', 'adjustment'
  final double amount;
  final double pricePerGram;
  final DateTime timestamp;
  final String description;
  final String performedBy;

  InventoryTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.pricePerGram,
    required this.timestamp,
    required this.description,
    required this.performedBy,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      pricePerGram: json['pricePerGram'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      performedBy: json['performedBy'],
    );
  }
}

class PriceManagement {
  final double basePrice;
  final double buySpread;
  final double sellSpread;
  final DateTime lastUpdated;
  final String updatedBy;
  final bool isManualOverride;

  PriceManagement({
    required this.basePrice,
    required this.buySpread,
    required this.sellSpread,
    required this.lastUpdated,
    required this.updatedBy,
    this.isManualOverride = false,
  });

  double get buyPrice => basePrice * (1 + buySpread);
  double get sellPrice => basePrice * (1 - sellSpread);

  factory PriceManagement.fromJson(Map<String, dynamic> json) {
    return PriceManagement(
      basePrice: json['basePrice'].toDouble(),
      buySpread: json['buySpread'].toDouble(),
      sellSpread: json['sellSpread'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      updatedBy: json['updatedBy'],
      isManualOverride: json['isManualOverride'] ?? false,
    );
  }
}
