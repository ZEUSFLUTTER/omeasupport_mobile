// lib/controllers/blocs/profile/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/profile/profile_event.dart';
import 'package:omeamobile/controllers/blocs/profile/profile_state.dart';
import 'package:omeamobile/services/api_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService;

  ProfileBloc({required ApiService apiService})
      : _apiService = apiService,
        super(ProfileInitial()) {
    on<ProfileImageUpdateRequested>(_onProfileImageUpdateRequested);
    on<ProfileImageRemoveRequested>(_onProfileImageRemoveRequested);
  }

  Future<void> _onProfileImageUpdateRequested(
    ProfileImageUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileImageUpdating());

    try {
      final result = await _apiService.updateProfileImage(event.imageBase64);

      if (result['success'] == true) {
        final photoProfileUrl = result['data']?['photo_profile_url'] as String?;
        emit(ProfileImageUpdated(photoProfileUrl: photoProfileUrl));
      } else {
        emit(ProfileError(
          message: result['message'] ?? 'Erreur lors de la mise à jour de la photo',
        ));
      }
    } catch (e) {
      emit(ProfileError(
        message: 'Erreur inattendue: ${e.toString()}',
      ));
    }
  }

  Future<void> _onProfileImageRemoveRequested(
    ProfileImageRemoveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileImageUpdating());

    try {
      final result = await _apiService.removeProfileImage();

      if (result['success'] == true) {
        emit(ProfileImageRemoved());
      } else {
        emit(ProfileError(
          message: result['message'] ?? 'Erreur lors de la suppression de la photo',
        ));
      }
    } catch (e) {
      emit(ProfileError(
        message: 'Erreur inattendue: ${e.toString()}',
      ));
    }
  }
}