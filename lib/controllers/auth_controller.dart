// lib/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:omeamobile/models/user_model.dart';
import 'package:omeamobile/services/api_service.dart';

enum UserRole { client, technician }

class AuthController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthController() {
    checkAuthStatus();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email: email, password: password);

      if (result['success'] == true) {
        _currentUser = result['user'] as User?;
        _errorMessage = null;
        print(
          'AuthController: Login successful. User: ${_currentUser?.email}, Role: ${_currentUser?.role}',
        );
        return true;
      } else {
        _errorMessage = result['message'];
        _currentUser = null;
        print('AuthController: Login failed. Message: ${result['message']}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur inattendue lors de la connexion: ${e.toString()}';
      _currentUser = null;
      print('AuthController: Unexpected error during login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String nom,
    String prenom,
    String email,
    String password,
    String passwordConfirmation,
    String telephone,
    String pays,
    String ville,
    UserRole role,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (password != passwordConfirmation) {
      _errorMessage = 'Les mots de passe ne correspondent pas.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final roleString = role.toString().split('.').last;

      final result = await _apiService.register(
        nom,
        prenom,
        email,
        password,
        passwordConfirmation,
        telephone,
        pays,
        ville,
        roleString,
      );

      if (result['success'] == true) {
        _currentUser = result['user'] as User?;
        _errorMessage = null;
        print(
          'AuthController: Register successful. User: ${_currentUser?.email}, Role: ${_currentUser?.role}',
        );
        return true;
      } else {
        _errorMessage = result['message'];
        _currentUser = null;
        print('AuthController: Register failed. Message: ${result['message']}');
        return false;
      }
    } catch (e) {
      _errorMessage =
          'Erreur inattendue lors de l\'enregistrement: ${e.toString()}';
      _currentUser = null;
      print('AuthController: Unexpected error during registration: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    print('AuthController: Attempting logout...');
    await _apiService.logout();
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    print('AuthController: User logged out successfully.');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('AuthController: Checking auth status...');

    if (_apiService.hasAuthToken) {
      try {
        final profileResult = await _apiService.getUserProfile();
        if (profileResult['success'] == true && profileResult['data'] != null) {
          _currentUser = User.fromJson(profileResult['data']);
          print(
            'AuthController: Auth status confirmed. User: ${_currentUser?.email}, Role: ${_currentUser?.role}',
          );
        } else {
          print(
            'AuthController: Failed to get user profile: ${profileResult['message']}',
          );
          await _apiService.clearAuthToken();
          _currentUser = null;
          _errorMessage =
              profileResult['message'] ??
              'Session expirée, veuillez vous reconnecter.';
        }
      } catch (e) {
        print(
          'AuthController: Erreur lors de la vérification du statut d\'authentification: $e',
        );
        await _apiService.clearAuthToken();
        _currentUser = null;
        _errorMessage =
            'Erreur de connexion automatique. Veuillez vous reconnecter.';
      }
    } else {
      _currentUser = null;
      print('AuthController: No auth token found. User not authenticated.');
    }
    _isLoading = false;
    notifyListeners();
  }
}
