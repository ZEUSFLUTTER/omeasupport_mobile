// lib/blocs/ticket/ticket_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_event.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_state.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/services/api_service.dart';
import 'package:omeamobile/services/ticket_service.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final ApiService _apiService;
  final TicketService _ticketService;

  TicketBloc({
    required ApiService apiService,
    required TicketService ticketService,
  }) : _apiService = apiService,
       _ticketService = ticketService,
       super(TicketInitial()) {
    on<TicketFetchDashboardDataRequested>(_onTicketFetchDashboardDataRequested);
    on<TicketFetchAllRequested>(_onTicketFetchAllRequested);
    on<TicketStartInterventionRequested>(_onTicketStartInterventionRequested);
    on<TicketCompleteInterventionRequested>(
      _onTicketCompleteInterventionRequested,
    );
    on<TicketTakeChargeRequested>(_onTicketTakeChargeRequested);
    on<TicketCreateRequested>(_onTicketCreateRequested);
  }

  List<Ticket> _processTicketsData(List<Ticket> allTickets) {
    return allTickets;
  }

  Ticket? _findActiveTicket(List<Ticket> allTickets) {
    try {
      return allTickets.firstWhere((t) => t.status == TicketStatus.inProgress);
    } catch (e) {
      return null;
    }
  }

  List<Ticket> _getTodaysTickets(List<Ticket> allTickets) {
    return allTickets
        .where(
          (t) =>
              t.scheduledTime.day == DateTime.now().day &&
              t.status != TicketStatus.completed,
        )
        .toList();
  }

  List<Ticket> _getPendingTickets(List<Ticket> allTickets) {
    return allTickets.where((t) => t.status == TicketStatus.pending).toList();
  }

  List<Ticket> _getCompletedTickets(List<Ticket> allTickets) {
    return allTickets
        .where(
          (t) =>
              t.status == TicketStatus.completed &&
              t.scheduledTime.day == DateTime.now().day,
        )
        .toList();
  }

  Future<void> _onTicketFetchDashboardDataRequested(
    TicketFetchDashboardDataRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());

    try {
      final result = await _apiService.getTickets();

      if (result['success'] == true) {
        final allTickets = result['tickets'] as List<Ticket>;
        final processedTickets = _processTicketsData(allTickets);

        final todaysTickets = _getTodaysTickets(processedTickets);
        final pendingTickets = _getPendingTickets(processedTickets);
        final completedTickets = _getCompletedTickets(processedTickets);
        final activeTicket = _findActiveTicket(processedTickets);

        emit(
          TicketLoaded(
            allTickets: processedTickets,
            todaysTickets: todaysTickets,
            pendingTickets: pendingTickets,
            completedTickets: completedTickets,
            activeTicket: activeTicket,
          ),
        );
      } else {
        emit(
          TicketError(
            message:
                result['message'] ?? 'Erreur lors du chargement des données',
          ),
        );
      }
    } catch (e) {
      emit(
        TicketError(
          message: 'Erreur lors du chargement des données: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onTicketFetchAllRequested(
    TicketFetchAllRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());

    try {
      final result = await _apiService.getTickets();

      if (result['success'] == true) {
        final allTickets = result['tickets'] as List<Ticket>;
        final processedTickets = _processTicketsData(allTickets);

        final todaysTickets = _getTodaysTickets(processedTickets);
        final pendingTickets = _getPendingTickets(processedTickets);
        final completedTickets = _getCompletedTickets(processedTickets);
        final activeTicket = _findActiveTicket(processedTickets);

        emit(
          TicketLoaded(
            allTickets: processedTickets,
            todaysTickets: todaysTickets,
            pendingTickets: pendingTickets,
            completedTickets: completedTickets,
            activeTicket: activeTicket,
          ),
        );
      } else {
        emit(
          TicketError(
            message:
                result['message'] ?? 'Erreur lors du chargement des tickets',
          ),
        );
      }
    } catch (e) {
      emit(
        TicketError(
          message: 'Erreur lors du chargement des tickets: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onTicketStartInterventionRequested(
    TicketStartInterventionRequested event,
    Emitter<TicketState> emit,
  ) async {
    if (state is TicketLoaded) {
      final currentState = state as TicketLoaded;
      emit(
        TicketActionLoading(
          allTickets: currentState.allTickets,
          todaysTickets: currentState.todaysTickets,
          pendingTickets: currentState.pendingTickets,
          completedTickets: currentState.completedTickets,
          activeTicket: currentState.activeTicket,
        ),
      );

      try {
        final result = await _apiService.startIntervention(event.ticketId);

        if (result['success'] == true) {
          // Refresh les données après l'action
          add(TicketFetchDashboardDataRequested());
        } else {
          emit(
            TicketError(
              message: result['message'] ?? 'Erreur lors du démarrage',
            ),
          );
        }
      } catch (e) {
        emit(TicketError(message: 'Erreur: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTicketCompleteInterventionRequested(
    TicketCompleteInterventionRequested event,
    Emitter<TicketState> emit,
  ) async {
    if (state is TicketLoaded) {
      final currentState = state as TicketLoaded;
      emit(
        TicketActionLoading(
          allTickets: currentState.allTickets,
          todaysTickets: currentState.todaysTickets,
          pendingTickets: currentState.pendingTickets,
          completedTickets: currentState.completedTickets,
          activeTicket: currentState.activeTicket,
        ),
      );

      try {
        final result = await _apiService.completeIntervention(event.ticketId);

        if (result['success'] == true) {
          // Refresh les données après l'action
          add(TicketFetchDashboardDataRequested());
        } else {
          emit(
            TicketError(
              message: result['message'] ?? 'Erreur lors de la finalisation',
            ),
          );
        }
      } catch (e) {
        emit(TicketError(message: 'Erreur: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTicketTakeChargeRequested(
    TicketTakeChargeRequested event,
    Emitter<TicketState> emit,
  ) async {
    if (state is TicketLoaded) {
      final currentState = state as TicketLoaded;
      emit(
        TicketActionLoading(
          allTickets: currentState.allTickets,
          todaysTickets: currentState.todaysTickets,
          pendingTickets: currentState.pendingTickets,
          completedTickets: currentState.completedTickets,
          activeTicket: currentState.activeTicket,
        ),
      );

      try {
        final result = await _apiService.takeChargeOfTicket(event.ticketId);

        if (result['success'] == true) {
          // Refresh les données après l'action
          add(TicketFetchAllRequested());
        } else {
          emit(
            TicketError(
              message: result['message'] ?? 'Erreur lors de la prise en charge',
            ),
          );
        }
      } catch (e) {
        emit(TicketError(message: 'Erreur: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTicketCreateRequested(
    TicketCreateRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());

    try {
      final createdTicket = await _ticketService.createTicket(
        typeProbleme: event.typeProbleme,
        description: event.description,
        adresse: event.adresse,
        dateRdv: event.dateRdv,
        photosBase64: event.photosBase64,
      );

      // Recharger toutes les données pour avoir l'état le plus récent
      final result = await _apiService.getTickets();

      if (result['success'] == true) {
        final allTickets = result['tickets'] as List<Ticket>;
        final processedTickets = _processTicketsData(allTickets);

        final todaysTickets = _getTodaysTickets(processedTickets);
        final pendingTickets = _getPendingTickets(processedTickets);
        final completedTickets = _getCompletedTickets(processedTickets);
        final activeTicket = _findActiveTicket(processedTickets);

        emit(
          TicketCreated(
            createdTicket: createdTicket,
            allTickets: processedTickets,
            todaysTickets: todaysTickets,
            pendingTickets: pendingTickets,
            completedTickets: completedTickets,
            activeTicket: activeTicket,
          ),
        );
      } else {
        emit(
          TicketError(
            message: 'Ticket créé mais erreur lors du rechargement des données',
          ),
        );
      }
    } catch (e) {
      emit(
        TicketError(message: 'Erreur lors de la création : ${e.toString()}'),
      );
    }
  }
}
