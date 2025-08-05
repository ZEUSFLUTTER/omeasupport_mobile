// lib/blocs/auth/auth_event.dart

import 'package:equatable/equatable.dart';
import 'package:omeamobile/controllers/auth_controller.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String telephone;
  final String pays;
  final String ville;
  final UserRole role;

  const AuthRegisterRequested({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.telephone,
    required this.pays,
    required this.ville,
    required this.role,
  });

  @override
  List<Object> get props => [
        nom,
        prenom,
        email,
        password,
        passwordConfirmation,
        telephone,
        pays,
        ville,
        role,
      ];
}

class AuthLogoutRequested extends AuthEvent {}