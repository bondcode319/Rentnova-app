import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isInitializing = true;
  String? _error;

  AuthProvider() {
    checkAuthState();
  }

  User? get currentUser => _user;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> checkAuthState() async {
    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        _user = user;
        _isInitializing = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _error = null;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    _error = null;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _error = null;
    try {
      await _auth.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _error = null;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
