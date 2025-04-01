import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void update(auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await refreshUserData(firebaseUser);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData([auth.User? firebaseUser]) async {
    final user = firebaseUser ?? FirebaseAuth.instance.currentUser;

    if (user == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Create default user document if it doesn't exist
        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          phoneNumber: user.phoneNumber,
          role: UserRole.tenant, // Default role
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        _currentUser = newUser;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData({
    String? displayName,
    String? phoneNumber,
    UserRole? role,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_currentUser == null) {
      _error = 'No user is currently logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
        additionalData: additionalData,
      );

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updatedUser.toMap());
      _currentUser = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
