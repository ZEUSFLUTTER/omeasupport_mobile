// lib/controllers/blocs/technician_dashboard/technician_dashboard_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_event.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_state.dart';
import 'package:omeamobile/models/technician_dashboard_model.dart';
import 'package:omeamobile/services/api_service.dart';

class TechnicianDashboardBloc
    extends Bloc<TechnicianDashboardEvent, TechnicianDashboardState> {
  final ApiService _apiService;

  TechnicianDashboardBloc({required ApiService apiService})
    : _apiService = apiService,
      super(TechnicianDashboardInitial()) {
    on<TechnicianDashboardDataRequested>(_onDashboardDataRequested);
    on<TechnicianStartInterventionRequested>(_onStartInterventionRequested);
    on<TechnicianEndInterventionRequested>(_onEndInterventionRequested);
    on<TechnicianTakeChargeRequested>(_onTakeChargeRequested);
  }

  Future<void> _onDashboardDataRequested(
    TechnicianDashboardDataRequested event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    emit(TechnicianDashboardLoading());

    try {
      final result = await _apiService.getTechnicianDashboardData();

      if (result['success'] == true) {
        try {
          final dashboardData = TechnicianDashboardData.fromJson(
            result['data'],
          );
          emit(TechnicianDashboardLoaded(dashboardData: dashboardData));
        } catch (parseError) {
          print(
            'TechnicianDashboardBloc: Erreur de parsing des données: $parseError',
          );
          print('Données reçues: ${result['data']}');
          emit(
            TechnicianDashboardError(
              message: 'Erreur de format des données reçues du serveur',
            ),
          );
        }
      } else {
        emit(
          TechnicianDashboardError(
            message:
                result['message'] ?? 'Erreur lors du chargement des données',
          ),
        );
      }
    } catch (e) {
      print('TechnicianDashboardBloc: Erreur réseau: $e');
      emit(
        TechnicianDashboardError(
          message: 'Erreur lors du chargement des données: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStartInterventionRequested(
    TechnicianStartInterventionRequested event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    if (state is TechnicianDashboardLoaded) {
      final currentState = state as TechnicianDashboardLoaded;
      emit(
        TechnicianDashboardActionLoading(
          dashboardData: currentState.dashboardData,
        ),
      );

      try {
        final result = await _apiService.startIntervention(event.ticketId);

        if (result['success'] == true) {
          // Find the ticket in the current dashboard data
          final ticket = currentState.dashboardData.allTickets.firstWhere(
            (t) => t.id == event.ticketId,
            orElse: () => throw Exception('Ticket not found'),
          );
          emit(TechnicianDashboardInterventionStarted(ticket: ticket));
        } else {
          emit(
            TechnicianDashboardError(
              message: result['message'] ?? 'Erreur lors du démarrage',
            ),
          );
        }
      } catch (e) {
        emit(TechnicianDashboardError(message: 'Erreur: ${e.toString()}'));
      }
    }
  }

  Future<void> _onEndInterventionRequested(
    TechnicianEndInterventionRequested event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    if (state is TechnicianDashboardLoaded) {
      final currentState = state as TechnicianDashboardLoaded;
      emit(
        TechnicianDashboardActionLoading(
          dashboardData: currentState.dashboardData,
        ),
      );

      try {
        final result = await _apiService.completeIntervention(event.ticketId);

        if (result['success'] == true) {
          // Recharger les données après l'action
          add(TechnicianDashboardDataRequested());
        } else {
          emit(
            TechnicianDashboardError(
              message: result['message'] ?? 'Erreur lors de la finalisation',
            ),
          );
        }
      } catch (e) {
        emit(TechnicianDashboardError(message: 'Erreur: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTakeChargeRequested(
    TechnicianTakeChargeRequested event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    if (state is TechnicianDashboardLoaded) {
      final currentState = state as TechnicianDashboardLoaded;
      emit(
        TechnicianDashboardActionLoading(
          dashboardData: currentState.dashboardData,
        ),
      );

      try {
        final result = await _apiService.takeChargeOfTicket(event.ticketId);

        if (result['success'] == true) {
          // Recharger les données après l'action
          add(TechnicianDashboardDataRequested());
        } else {
          emit(
            TechnicianDashboardError(
              message: result['message'] ?? 'Erreur lors de la prise en charge',
            ),
          );
        }
      } catch (e) {
        emit(TechnicianDashboardError(message: 'Erreur: ${e.toString()}'));
      }
    }
  }
}
