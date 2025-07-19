// lib/admin/services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_models.dart';
import '../providers/admin_provider.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Dashboard data
  Future<DashboardData> getDashboardData() async {
    try {
      // In demo mode, return mock data
      // In production, this would fetch real data from Firestore
      return _generateMockDashboardData();
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  // User management
  Future<List<UserProfile>> getUsers({
    String? searchQuery,
    UserStatus? statusFilter,
    KYCStatus? kycFilter,
  }) async {
    try {
      Query query = _firestore.collection('users');
      
      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter.toString().split('.').last);
      }
      
      if (kycFilter != null) {
        query = query.where('kycStatus', isEqualTo: kycFilter.toString().split('.').last);
      }
      
      final snapshot = await query.get();
      List<UserProfile> users = snapshot.docs
          .map((doc) => UserProfile.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      
      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        users = users.where((user) =>
          user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      }
      
      return users;
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> suspendUser(String userId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'suspended',
        'suspensionReason': reason,
        'suspendedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to suspend user: $e');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'active',
        'suspensionReason': FieldValue.delete(),
        'suspendedAt': FieldValue.delete(),
        'reactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  // KYC management
  Future<List<KYCUser>> getPendingKYCUsers() async {
    try {
      final snapshot = await _firestore
          .collection('kyc_submissions')
          .where('status', isEqualTo: 'pending')
          .orderBy('submittedAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => KYCUser.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load pending KYC users: $e');
    }
  }

  Future<void> approveKYC(String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Update KYC submission
      batch.update(_firestore.collection('kyc_submissions').doc(userId), {
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': _auth.currentUser?.uid,
      });
      
      // Update user status
      batch.update(_firestore.collection('users').doc(userId), {
        'kycStatus': 'approved',
        'kycApprovedAt': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to approve KYC: $e');
    }
  }

  Future<void> rejectKYC(String userId, String reason) async {
    try {
      final batch = _firestore.batch();
      
      // Update KYC submission
      batch.update(_firestore.collection('kyc_submissions').doc(userId), {
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': _auth.currentUser?.uid,
      });
      
      // Update user status
      batch.update(_firestore.collection('users').doc(userId), {
        'kycStatus': 'rejected',
        'kycRejectedAt': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reject KYC: $e');
    }
  }

  // Inventory management
  Future<GoldInventory> getGoldInventory() async {
    try {
      final doc = await _firestore.collection('gold_inventory').doc('main').get();
      
      if (doc.exists) {
        return GoldInventory.fromJson({...doc.data()!, 'id': doc.id});
      } else {
        // Create initial inventory record
        final initialInventory = {
          'totalGold': 1000.0,
          'reservedGold': 0.0,
          'availableGold': 1000.0,
          'lowStockThreshold': 100.0,
          'lastUpdated': FieldValue.serverTimestamp(),
          'recentTransactions': [],
        };
        
        await _firestore.collection('gold_inventory').doc('main').set(initialInventory);
        return GoldInventory.fromJson({...initialInventory, 'id': 'main'});
      }
    } catch (e) {
      throw Exception('Failed to load gold inventory: $e');
    }
  }

  Future<void> updateGoldInventory(double amount, String type, String description) async {
    try {
      final inventoryRef = _firestore.collection('gold_inventory').doc('main');
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(inventoryRef);
        
        if (!snapshot.exists) {
          throw Exception('Inventory record not found');
        }
        
        final currentData = snapshot.data()!;
        double currentTotal = currentData['totalGold'].toDouble();
        double currentAvailable = currentData['availableGold'].toDouble();
        
        double newTotal = currentTotal;
        double newAvailable = currentAvailable;
        
        switch (type) {
          case 'purchase':
            newTotal += amount;
            newAvailable += amount;
            break;
          case 'sale':
            newTotal -= amount;
            newAvailable -= amount;
            break;
          case 'adjustment':
            newTotal = amount;
            newAvailable = amount - currentData['reservedGold'].toDouble();
            break;
        }
        
        // Create transaction record
        final transactionRecord = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': type,
          'amount': amount,
          'pricePerGram': 475.50, // Current gold price
          'timestamp': DateTime.now().toIso8601String(),
          'description': description,
          'performedBy': _auth.currentUser?.uid ?? 'system',
        };
        
        List<dynamic> recentTransactions = List.from(currentData['recentTransactions'] ?? []);
        recentTransactions.insert(0, transactionRecord);
        
        // Keep only last 10 transactions
        if (recentTransactions.length > 10) {
          recentTransactions = recentTransactions.take(10).toList();
        }
        
        transaction.update(inventoryRef, {
          'totalGold': newTotal,
          'availableGold': newAvailable,
          'lastUpdated': FieldValue.serverTimestamp(),
          'recentTransactions': recentTransactions,
        });
      });
    } catch (e) {
      throw Exception('Failed to update gold inventory: $e');
    }
  }

  // Price management
  Future<PriceManagement> getPriceManagement() async {
    try {
      final doc = await _firestore.collection('price_management').doc('current').get();
      
      if (doc.exists) {
        return PriceManagement.fromJson(doc.data()!);
      } else {
        // Create initial price management record
        final initialPrice = {
          'basePrice': 475.50,
          'buySpread': 0.036, // 3.6%
          'sellSpread': 0.036, // 3.6%
          'lastUpdated': DateTime.now().toIso8601String(),
          'updatedBy': _auth.currentUser?.uid ?? 'system',
          'isManualOverride': false,
        };
        
        await _firestore.collection('price_management').doc('current').set(initialPrice);
        return PriceManagement.fromJson(initialPrice);
      }
    } catch (e) {
      throw Exception('Failed to load price management: $e');
    }
  }

  Future<void> updatePriceSpread(double buySpread, double sellSpread) async {
    try {
      await _firestore.collection('price_management').doc('current').update({
        'buySpread': buySpread,
        'sellSpread': sellSpread,
        'lastUpdated': DateTime.now().toIso8601String(),
        'updatedBy': _auth.currentUser?.uid,
      });
    } catch (e) {
      throw Exception('Failed to update price spread: $e');
    }
  }

  Future<void> overrideGoldPrice(double newPrice, String reason) async {
    try {
      await _firestore.collection('price_management').doc('current').update({
        'basePrice': newPrice,
        'lastUpdated': DateTime.now().toIso8601String(),
        'updatedBy': _auth.currentUser?.uid,
        'isManualOverride': true,
        'overrideReason': reason,
      });
    } catch (e) {
      throw Exception('Failed to override gold price: $e');
    }
  }

  // Transaction monitoring
  Future<List<TransactionData>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? type,
    double? minAmount,
    double? maxAmount,
  }) async {
    try {
      Query query = _firestore.collection('transactions');
      
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      
      query = query.orderBy('timestamp', descending: true);
      
      final snapshot = await query.get();
      List<TransactionData> transactions = snapshot.docs
          .map((doc) => TransactionData.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      
      // Apply amount filters
      if (minAmount != null) {
        transactions = transactions.where((t) => t.totalAmount >= minAmount).toList();
      }
      
      if (maxAmount != null) {
        transactions = transactions.where((t) => t.totalAmount <= maxAmount).toList();
      }
      
      return transactions;
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<void> flagSuspiciousTransaction(String transactionId, String reason) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'isFlagged': true,
        'flagReason': reason,
        'flaggedAt': FieldValue.serverTimestamp(),
        'flaggedBy': _auth.currentUser?.uid,
      });
    } catch (e) {
      throw Exception('Failed to flag transaction: $e');
    }
  }

  // Reporting
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // This would typically generate reports from Firestore data
      // For demo purposes, return mock data
      return _generateMockReport(reportType, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  Future<String> exportReport({
    required String reportType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // This would typically export data to PDF/Excel/CSV
      // For demo purposes, return a mock download URL
      return 'https://example.com/reports/${reportType}_${format}_${DateTime.now().millisecondsSinceEpoch}.$format';
    } catch (e) {
      throw Exception('Failed to export report: $e');
    }
  }

  // Announcements
  Future<void> createAnnouncement({
    required String title,
    required String content,
    required DateTime startDate,
    DateTime? endDate,
    bool isUrgent = false,
    List<String>? targetUserIds,
  }) async {
    try {
      await _firestore.collection('announcements').add({
        'title': title,
        'content': content,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'isUrgent': isUrgent,
        'targetUserIds': targetUserIds,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
        'isActive': true,
      });
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  // System health
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      // This would check various system metrics
      return {
        'status': 'healthy',
        'uptime': '99.9%',
        'response_time': '150ms',
        'error_rate': '0.1%',
        'critical_issues': 0,
        'warnings': 1,
      };
    } catch (e) {
      throw Exception('Failed to check system health: $e');
    }
  }

  // Admin actions logging
  Future<void> logAdminAction({
    required String action,
    required String targetId,
    required String details,
  }) async {
    try {
      await _firestore.collection('admin_actions').ad
