// lib/controllers/blocs/profile/profile_event.dart
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileImageUpdateRequested extends ProfileEvent {
  final String imageBase64;

  const ProfileImageUpdateRequested({required this.imageBase64});

  @override
  List<Object> get props => [imageBase64];
}

class ProfileImageRemoveRequested extends ProfileEvent {}
