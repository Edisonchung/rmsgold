// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Create a simple User model to avoid conflict with Firebase User
class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final bool isKYCVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.isKYCVerified = false,
    required this.createdAt,
  });

  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'User',
      phoneNumber: firebaseUser.phoneNumber,
      isKYCVerified: true, // Demo default
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  factory User.demo() {
    return User(
      id: 'demo_user_id',
      email: 'demo@rmsgold.com',
      name: 'Demo User',
      phoneNumber: '+60123456789',
      isKYCVerified: true,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    );
  }
}

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  firebase_auth.User? _firebaseUser;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _firebaseAvailable;

  // Fixed getter - this was missing!
  User? get currentUser => _currentUser;
  firebase_auth.User? get user => _firebaseUser; // Keep existing for compatibility
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider({bool firebaseAvailable = true}) : _firebaseAvailable = firebaseAvailable {
    // Listen to auth state changes only if Firebase is available
    if (_firebaseAvailable) {
      try {
        _auth.authStateChanges().listen((firebase_auth.User? user) {
          _firebaseUser = user;
          if (user != null) {
            _currentUser = User.fromFirebaseUser(user);
          } else {
            _currentUser = null;
          }
          notifyListeners();
        });
      } catch (e) {
        print('Error setting up auth state listener: $e');
        _firebaseAvailable = false;
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Demo mode for specific emails
      if (email == 'demo@rmsgold.com' && password == 'demo123456') {
        // Simulate demo login
        await Future.delayed(Duration(seconds: 1));
        _currentUser = User.demo();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Try Firebase authentication if available
      if (_firebaseAvailable) {
        try {
          final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          _firebaseUser = credential.user;
          if (credential.user != null) {
            _currentUser = User.fromFirebaseUser(credential.user!);
          }
          _isLoading = false;
          notifyListeners();
          return true;
        } on firebase_auth.FirebaseAuthException catch (e) {
          // Handle Firebase errors
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = 'No user found with this email.';
              break;
            case 'wrong-password':
              _errorMessage = 'Incorrect password.';
              break;
            case 'invalid-email':
              _errorMessage = 'Invalid email format.';
              break;
            case 'too-many-requests':
              _errorMessage = 'Too many failed attempts. Try again later.';
              break;
            default:
              _errorMessage = 'Login failed: ${e.message}';
          }
        }
      } else {
        _errorMessage = 'Authentication service unavailable. Use demo credentials.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_firebaseAvailable) {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Update display name
        await credential.user?.updateDisplayName(name);
        
        _firebaseUser = credential.user;
        if (credential.user != null) {
          _currentUser = User.fromFirebaseUser(credential.user!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration service unavailable.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Password is too weak.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email format.';
          break;
        default:
          _errorMessage = 'Registration failed: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      if (_firebaseAvailable) {
        await _auth.signOut();
      }
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      _firebaseUser = null;
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
