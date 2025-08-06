// lib/controllers/blocs/profile/profile_state.dart
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileImageUpdating extends ProfileState {}

class ProfileImageUpdated extends ProfileState {
  final String? photoProfileUrl;

  const ProfileImageUpdated({this.photoProfileUrl});

  @override
  List<Object?> get props => [photoProfileUrl];
}

class ProfileImageRemoved extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

