// lib/admin/services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // If Firebase is available, get real data
      // For now, return mock data
      return _generateMockDashboardData();
    } catch (e) {
      print('Error getting dashboard data: $e');
      return _generateMockDashboardData();
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      return {
        'totalUsers': 1250,
        'activeUsers': 980,
        'pendingKYC': 45,
        'blockedUsers': 12,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'pendingKYC': 0,
        'blockedUsers': 0,
      };
    }
  }

  // Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats() async {
    try {
      return {
        'totalTransactions': 5890,
        'todayTransactions': 127,
        'totalVolume': 2456.75,
        'totalRevenue': 125420.50,
      };
    } catch (e) {
      print('Error getting transaction stats: $e');
      return {
        'totalTransactions': 0,
        'todayTransactions': 0,
        'totalVolume': 0.0,
        'totalRevenue': 0.0,
      };
    }
  }

  // Get gold inventory
  Future<Map<String, dynamic>> getGoldInventory() async {
    try {
      return {
        'totalGold': 1250.75,
        'availableGold': 890.25,
        'reservedGold': 360.50,
        'lowStockAlert': false,
        'reorderLevel': 500.0,
      };
    } catch (e) {
      print('Error getting gold inventory: $e');
      return {
        'totalGold': 0.0,
        'availableGold': 0.0,
        'reservedGold': 0.0,
        'lowStockAlert': true,
        'reorderLevel': 500.0,
      };
    }
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      return [
        {
          'id': '1',
          'type': 'transaction',
          'description': 'User purchased 2.5g gold',
          'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
          'user': 'user123@email.com',
          'amount': 1187.50,
        },
        {
          'id': '2',
          'type': 'kyc',
          'description': 'KYC application submitted',
          'timestamp': DateTime.now().subtract(Duration(hours: 1)),
          'user': 'newuser@email.com',
          'amount': null,
        },
        {
          'id': '3',
          'type': 'transaction',
          'description': 'User sold 1.0g gold',
          'timestamp': DateTime.now().subtract(Duration(hours: 2)),
          'user': 'user456@email.com',
          'amount': 475.50,
        },
        {
          'id': '4',
          'type': 'system',
          'description': 'Gold price updated',
          'timestamp': DateTime.now().subtract(Duration(hours: 3)),
          'user': 'system',
          'amount': null,
        },
        {
          'id': '5',
          'type': 'kyc',
          'description': 'KYC application approved',
          'timestamp': DateTime.now().subtract(Duration(hours: 4)),
          'user': 'approved@email.com',
          'amount': null,
        },
      ];
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // Return mock user data
      return List.generate(50, (index) => {
        'id': 'user_$index',
        'email': 'user$index@example.com',
        'name': 'User ${index + 1}',
        'kycStatus': ['pending', 'approved', 'rejected'][index % 3],
        'goldHoldings': (index * 0.5) + 1.0,
        'totalTransactions': index * 3 + 5,
        'joinDate': DateTime.now().subtract(Duration(days: index * 7)),
        'lastActive': DateTime.now().subtract(Duration(hours: index % 24)),
        'status': ['active', 'inactive'][index % 2],
      });
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Get pending KYC applications
  Future<List<Map<String, dynamic>>> getPendingKYC() async {
    try {
      return List.generate(10, (index) => {
        'id': 'kyc_$index',
        'userId': 'user_$index',
        'email': 'pending$index@example.com',
        'name': 'Pending User ${index + 1}',
        'submittedDate': DateTime.now().subtract(Duration(days: index)),
        'documents': ['ic_front.jpg', 'ic_back.jpg', 'selfie.jpg'],
        'status': 'pending',
        'reviewedBy': null,
      });
    } catch (e) {
      print('Error getting pending KYC: $e');
      return [];
    }
  }

  // Get all transactions
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      return List.generate(100, (index) => {
        'id': 'txn_$index',
        'userId': 'user_${index % 20}',
        'type': ['buy', 'sell'][index % 2],
        'amount': (index * 0.1) + 0.5,
        'price': 475.50 + (index % 10),
        'total': ((index * 0.1) + 0.5) * (475.50 + (index % 10)),
        'status': ['completed', 'pending', 'failed'][index % 3],
        'timestamp': DateTime.now().subtract(Duration(hours: index)),
        'paymentMethod': ['fpx', 'card', 'bank_transfer'][index % 3],
      });
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Update gold price
  Future<bool> updateGoldPrice(double newPrice) async {
    try {
      // In a real app, this would update the database
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      await _logAdminAction('price_update', 'Updated gold price to RM$newPrice');
      return true;
    } catch (e) {
      print('Error updating gold price: $e');
      return false;
    }
  }

  // Approve KYC application
  Future<bool> approveKYC(String kycId, String userId) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      await _logAdminAction('kyc_approval', 'Approved KYC for user $userId');
      return true;
    } catch (e) {
      print('Error approving KYC: $e');
      return false;
    }
  }

  // Reject KYC application
  Future<bool> rejectKYC(String kycId, String userId, String reason) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      await _logAdminAction('kyc_rejection', 'Rejected KYC for user $userId: $reason');
      return true;
    } catch (e) {
      print('Error rejecting KYC: $e');
      return false;
    }
  }

  // Block/Unblock user
  Future<bool> toggleUserStatus(String userId, bool block) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      final action = block ? 'blocked' : 'unblocked';
      await _logAdminAction('user_status_change', 'User $userId $action');
      return true;
    } catch (e) {
      print('Error toggling user status: $e');
      return false;
    }
  }

  // Create announcement
  Future<bool> createAnnouncement(String title, String content, String type) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      await _logAdminAction('announcement_created', 'Created announcement: $title');
      return true;
    } catch (e) {
      print('Error creating announcement: $e');
      return false;
    }
  }

  // Get announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      return List.generate(5, (index) => {
        'id': 'announcement_$index',
        'title': 'Important Update ${index + 1}',
        'content': 'This is the content of announcement ${index + 1}. Please read carefully.',
        'type': ['info', 'warning', 'success'][index % 3],
        'createdDate': DateTime.now().subtract(Duration(days: index)),
        'createdBy': 'admin@rmsgold.com',
        'active': index < 3,
      });
    } catch (e) {
      print('Error getting announcements: $e');
      return [];
    }
  }

  // Generate reports
  Future<Map<String, dynamic>> generateReport(String reportType, DateTime startDate, DateTime endDate) async {
    try {
      await Future.delayed(Duration(seconds: 2)); // Simulate generation
      await _logAdminAction('report_generated', 'Generated $reportType report');
      return _generateMockReport(reportType, startDate, endDate);
    } catch (e) {
      print('Error generating report: $e');
      return {};
    }
  }

  // Update inventory levels
  Future<bool> updateInventory(double newAmount, String reason) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      await _logAdminAction('inventory_update', 'Updated inventory: +${newAmount}g - $reason');
      return true;
    } catch (e) {
      print('Error updating inventory: $e');
      return false;
    }
  }

  // Private helper methods
  Map<String, dynamic> _generateMockDashboardData() {
    return {
      'userStats': {
        'totalUsers': 1250,
        'activeUsers': 980,
        'newUsersToday': 15,
        'pendingKYC': 45,
      },
      'transactionStats': {
        'totalTransactions': 5890,
        'todayTransactions': 127,
        'totalVolume': 2456.75,
        'todayVolume': 125.50,
        'totalRevenue': 125420.50,
        'todayRevenue': 5240.75,
      },
      'goldStats': {
        'currentPrice': 475.50,
        'priceChange': 2.75,
        'priceChangePercent': 0.58,
        'totalInventory': 1250.75,
        'availableInventory': 890.25,
        'lowStockAlert': false,
      },
      'systemHealth': {
        'serverStatus': 'healthy',
        'dbConnections': 98,
        'apiResponseTime': 145,
        'errorRate': 0.02,
      }
    };
  }

  Map<String, dynamic> _generateMockReport(String reportType, DateTime startDate, DateTime endDate) {
    return {
      'reportType': reportType,
      'period': {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
      'summary': {
        'totalTransactions': 1250,
        'totalVolume': 567.25,
        'totalRevenue': 268542.50,
        'averageTransaction': 214.83,
      },
      'charts': {
        'dailyVolume': List.generate(30, (index) => {
          'date': startDate.add(Duration(days: index)).toIso8601String(),
          'volume': 15.0 + (index * 2.5) + (index % 7) * 5,
        }),
        'transactionTypes': {
          'buy': 780,
          'sell': 470,
        },
      },
      'generatedAt': DateTime.now().toIso8601String(),
      'generatedBy': _auth.currentUser?.email ?? 'system',
    };
  }

  Future<void> _logAdminAction(String action, String description) async {
    try {
      await _firestore.collection('admin_actions').add({
        'action': action,
        'description': description,
        'adminId': _auth.currentUser?.uid ?? 'demo_admin',
        'adminEmail': _auth.currentUser?.email ?? 'admin@rmsgold.com',
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': 'demo_ip',
      });
    } catch (e) {
      print('Error logging admin action: $e');
      // Don't throw error if logging fails
    }
  }
}
