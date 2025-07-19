// lib/admin/providers/admin_provider.dart
import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  // Dashboard data
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  // User management
  List<UserProfile> _users = [];
  List<KYCUser> _pendingKYCUsers = [];
  
  // Inventory management
  GoldInventory? _goldInventory;
  
  // Price management
  PriceManagement? _priceManagement;
  
  // Admin user
  AdminUser? _currentAdmin;

  // Getters
  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserProfile> get users => _users;
  List<KYCUser> get pendingKYCUsers => _pendingKYCUsers;
  GoldInventory? get goldInventory => _goldInventory;
  PriceManagement? get priceManagement => _priceManagement;
  AdminUser? get currentAdmin => _currentAdmin;

  final AdminService _adminService = AdminService();

  // Dashboard methods
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _adminService.getDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // User management methods
  Future<void> loadUsers({
    String? searchQuery,
    UserStatus? statusFilter,
    KYCStatus? kycFilter,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _adminService.getUsers(
        searchQuery: searchQuery,
        statusFilter: statusFilter,
        kycFilter: kycFilter,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> suspendUser(String userId, String reason) async {
    try {
      await _adminService.suspendUser(userId, reason);
      await loadUsers(); // Refresh the list
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'suspend_user',
        targetId: userId,
        details: 'User suspended: $reason',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _adminService.activateUser(userId);
      await loadUsers(); // Refresh the list
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'activate_user',
        targetId: userId,
        details: 'User activated',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // KYC management methods
  Future<void> loadPendingKYC() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pendingKYCUsers = await _adminService.getPendingKYCUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveKYC(String userId) async {
    try {
      await _adminService.approveKYC(userId);
      await loadPendingKYC(); // Refresh the list
      await loadDashboardData(); // Update dashboard
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'approve_kyc',
        targetId: userId,
        details: 'KYC approved',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectKYC(String userId, String reason) async {
    try {
      await _adminService.rejectKYC(userId, reason);
      await loadPendingKYC(); // Refresh the list
      await loadDashboardData(); // Update dashboard
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'reject_kyc',
        targetId: userId,
        details: 'KYC rejected: $reason',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Inventory management methods
  Future<void> loadGoldInventory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goldInventory = await _adminService.getGoldInventory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoldInventory(double amount, String type, String description) async {
    try {
      await _adminService.updateGoldInventory(amount, type, description);
      await loadGoldInventory(); // Refresh inventory
      await loadDashboardData(); // Update dashboard
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'update_inventory',
        targetId: 'inventory',
        details: '$type: ${amount}g - $description',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Price management methods
  Future<void> loadPriceManagement() async {
    _isLoading = true;
    notifyListeners();

    try {
      _priceManagement = await _adminService.getPriceManagement();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePriceSpread(double buySpread, double sellSpread) async {
    try {
      await _adminService.updatePriceSpread(buySpread, sellSpread);
      await loadPriceManagement(); // Refresh price data
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'update_price_spread',
        targetId: 'price_management',
        details: 'Buy: ${(buySpread * 100).toStringAsFixed(2)}%, Sell: ${(sellSpread * 100).toStringAsFixed(2)}%',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> overrideGoldPrice(double newPrice, String reason) async {
    try {
      await _adminService.overrideGoldPrice(newPrice, reason);
      await loadPriceManagement(); // Refresh price data
      await loadDashboardData(); // Update dashboard
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'override_gold_price',
        targetId: 'price_management',
        details: 'Price override: RM$newPrice - $reason',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Transaction monitoring methods
  Future<List<TransactionData>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? type,
    double? minAmount,
    double? maxAmount,
  }) async {
    try {
      return await _adminService.getTransactions(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        type: type,
        minAmount: minAmount,
        maxAmount: maxAmount,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> flagSuspiciousTransaction(String transactionId, String reason) async {
    try {
      await _adminService.flagSuspiciousTransaction(transactionId, reason);
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'flag_transaction',
        targetId: transactionId,
        details: 'Flagged as suspicious: $reason',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reporting methods
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      return await _adminService.generateReport(
        reportType: reportType,
        startDate: startDate,
        endDate: endDate,
        filters: filters,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {};
    }
  }

  Future<String> exportReport({
    required String reportType,
    required String format, // 'pdf', 'excel', 'csv'
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final reportUrl = await _adminService.exportReport(
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        filters: filters,
      );
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'export_report',
        targetId: 'reports',
        details: '$reportType report exported as $format',
      );
      
      return reportUrl;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Announcement methods
  Future<void> createAnnouncement({
    required String title,
    required String content,
    required DateTime startDate,
    DateTime? endDate,
    bool isUrgent = false,
    List<String>? targetUserIds,
  }) async {
    try {
      await _adminService.createAnnouncement(
        title: title,
        content: content,
        startDate: startDate,
        endDate: endDate,
        isUrgent: isUrgent,
        targetUserIds: targetUserIds,
      );
      
      // Log admin action
      await _adminService.logAdminAction(
        action: 'create_announcement',
        targetId: 'announcements',
        details: 'Created announcement: $title',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // System monitoring methods
  Future<void> checkSystemHealth() async {
    try {
      final healthStatus = await _adminService.getSystemHealth();
      
      // Update dashboard if there are critical issues
      if (healthStatus['critical_issues'] > 0) {
        await loadDashboardData();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Utility methods
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setCurrentAdmin(AdminUser admin) {
    _currentAdmin = admin;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Additional models for transaction data
class TransactionData {
  final String id;
  final String userId;
  final String userName;
  final String type; // 'buy', 'sell'
  final double goldAmount;
  final double totalAmount;
  final double pricePerGram;
  final DateTime timestamp;
  final String status;
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
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      type: json['type'],
      goldAmount: json['goldAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      pricePerGram: json['pricePerGram'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      isFlagged: json['isFlagged'] ?? false,
      flagReason: json['flagReason'],
    );
  }
}
