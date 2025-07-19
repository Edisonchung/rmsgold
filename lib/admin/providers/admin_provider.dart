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
      final data = await _adminService.getDashboardData();
      _dashboardData = DashboardData.fromJson(data);
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
    KYCStatus? kycStatusFilter,
  }) async {
    try {
      final usersData = await _adminService.getUsers(
        searchQuery: searchQuery,
        statusFilter: statusFilter?.toString().split('.').last,
        kycStatusFilter: kycStatusFilter?.toString().split('.').last,
      );
      
      _users = usersData.map((userData) => UserProfile.fromJson(userData)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> suspendUser(String userId, String reason) async {
    try {
      await _adminService.suspendUser(userId, reason);
      await _adminService.logAdminAction('user_suspended', userId, 'User suspended: $reason');
      await loadUsers(); // Reload users
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _adminService.activateUser(userId);
      await _adminService.logAdminAction('user_activated', userId, 'User activated');
      await loadUsers(); // Reload users
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // KYC management methods
  Future<void> loadPendingKYC() async {
    try {
      final kycData = await _adminService.getPendingKYCUsers();
      _pendingKYCUsers = kycData.map((data) => KYCUser.fromJson(data)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> approveKYC(String userId) async {
    try {
      await _adminService.approveKYC(userId, 'KYC approved by admin');
      
      // Log admin action
      await _adminService.logAdminAction('kyc_approved', userId, 'KYC application approved');
      
      await loadPendingKYC(); // Reload pending KYC
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectKYC(String userId, String reason) async {
    try {
      await _adminService.rejectKYC(userId, reason, _currentAdmin?.id ?? 'unknown');
      
      // Log admin action
      await _adminService.logAdminAction('kyc_rejected', userId, 'KYC application rejected: $reason');
      
      await loadPendingKYC(); // Reload pending KYC
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Inventory management methods
  Future<void> loadGoldInventory() async {
    try {
      final inventoryData = await _adminService.getGoldInventory();
      _goldInventory = GoldInventory.fromJson(inventoryData);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateInventory(double amount, String type, String description) async {
    try {
      await _adminService.updateGoldInventory(amount, type, description);
      
      // Log admin action
      await _adminService.logAdminAction('inventory_updated', 'inventory', 'Inventory updated: $type ${amount}g - $description');
      
      await loadGoldInventory(); // Reload inventory
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Price management methods
  Future<void> loadPriceManagement() async {
    try {
      final priceData = await _adminService.getPriceManagement();
      _priceManagement = PriceManagement.fromJson(priceData);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePriceSpread(double buySpread, double sellSpread) async {
    try {
      await _adminService.updatePriceSpread(buySpread, sellSpread);
      
      // Log admin action
      await _adminService.logAdminAction('price_spread_updated', 'pricing', 'Price spreads updated: buy $buySpread%, sell $sellSpread%');
      
      await loadPriceManagement(); // Reload price management
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> overrideGoldPrice(double newPrice, String reason) async {
    try {
      await _adminService.overrideGoldPrice(newPrice, reason);
      
      // Log admin action
      await _adminService.logAdminAction('price_overridden', 'pricing', 'Gold price overridden to RM$newPrice: $reason');
      
      await loadPriceManagement(); // Reload price management
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Transaction monitoring methods
  Future<List<TransactionData>> getTransactions({
    String? searchQuery,
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactionsData = await _adminService.getTransactions(
        searchQuery: searchQuery,
        statusFilter: statusFilter,
        startDate: startDate,
        endDate: endDate,
      );
      
      return transactionsData.map((data) => TransactionData.fromJson(data)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> flagSuspiciousTransaction(String transactionId, String reason) async {
    try {
      await _adminService.flagSuspiciousTransaction(transactionId, reason);
      await _adminService.logAdminAction('transaction_flagged', transactionId, 'Transaction flagged: $reason');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reports and analytics methods
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
      await _adminService.logAdminAction('report_exported', 'reports', '$reportType report exported as $format');
      
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
      await _adminService.logAdminAction('announcement_created', 'announcements', 'Created announcement: $title');
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
