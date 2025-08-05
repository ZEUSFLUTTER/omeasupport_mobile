// lib/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_event.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_state.dart';
import 'package:omeamobile/models/user_model.dart';
import 'package:omeamobile/services/api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc({required ApiService apiService})
      : _apiService = apiService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      if (_apiService.hasAuthToken) {
        final profileResult = await _apiService.getUserProfile();
        if (profileResult['success'] == true && profileResult['data'] != null) {
          final user = User.fromJson(profileResult['data']);
          emit(AuthAuthenticated(user: user));
        } else {
          await _apiService.clearAuthToken();
          emit(const AuthUnauthenticated(
            message: 'Session expirée, veuillez vous reconnecter.',
          ));
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      await _apiService.clearAuthToken();
      emit(AuthError(
        message: 'Erreur de connexion automatique. Veuillez vous reconnecter.',
      ));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _apiService.login(
        email: event.email,
        password: event.password,
      );

      if (result['success'] == true) {
        final user = result['user'] as User;
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: result['message'] ?? 'Erreur de connexion'));
      }
    } catch (e) {
      emit(AuthError(
        message: 'Erreur inattendue lors de la connexion: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final roleString = event.role.toString().split('.').last;

      final result = await _apiService.register(
        event.nom,
        event.prenom,
        event.email,
        event.password,
        event.passwordConfirmation,
        event.telephone,
        event.pays,
        event.ville,
        roleString,
      );

      if (result['success'] == true) {
        final user = result['user'] as User;
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: result['message'] ?? 'Erreur d\'inscription'));
      }
    } catch (e) {
      emit(AuthError(
        message: 'Erreur inattendue lors de l\'enregistrement: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _apiService.logout();
    emit(const AuthUnauthenticated());
  }
}