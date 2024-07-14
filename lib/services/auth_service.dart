import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/services/alert_service.dart';

class AuthService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late AlertService _alertService;

  User? _user;

  User? get user => _user;

  AuthService() {
    _alertService = _getIt.get<AlertService>();
    _firebaseAuth.authStateChanges().listen(authStateChangesStreamListener);
  }

  void authStateChangesStreamListener(User? user) async {
    _user = user;
  }

  Future<bool> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        _alertService.showToast(
          text: 'Login successful!',
          icon: Icons.check_circle,
        );
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _alertService.showToast(
        text: 'Exception: ${e.toString()}',
        icon: Icons.error,
      );
    }
    return false;
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        _alertService.showToast(
          text: 'Sign up successful!',
          icon: Icons.check_circle,
        );
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _alertService.showToast(
        text: 'Exception: ${e.toString()}',
        icon: Icons.error,
      );
    }
    return false;
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _alertService.showToast(
        text: 'Password reset email sent!',
        icon: Icons.email,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _alertService.showToast(
        text: 'Exception: ${e.toString()}',
        icon: Icons.error,
      );
    }
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      _alertService.showToast(
        text: 'Logout successful!',
        icon: Icons.check_circle,
      );
      return true;
    } catch (e) {
      _alertService.showToast(
        text: 'Exception: ${e.toString()}',
        icon: Icons.error,
      );
    }
    return false;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      User user = _user!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      UserCredential result = await user.reauthenticateWithCredential(credential);
      await result.user!.updatePassword(newPassword);
      _alertService.showToast(
        text: 'Password changed successfully!',
        icon: Icons.check_circle,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _alertService.showToast(
        text: 'Exception: ${e.toString()}',
        icon: Icons.error,
      );
    }
    return false;
  }

  void _handleAuthException(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password provided.';
        break;
      case 'weak-password':
        errorMessage = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        errorMessage = 'The account already exists for that email.';
        break;
      default:
        errorMessage = 'Error: ${e.message}';
        break;
    }
    _alertService.showToast(
      text: errorMessage,
      icon: Icons.error,
    );
  }
}
