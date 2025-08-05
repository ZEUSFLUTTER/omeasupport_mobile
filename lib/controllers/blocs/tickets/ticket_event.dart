// lib/blocs/ticket/ticket_event.dart

import 'package:equatable/equatable.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class TicketFetchDashboardDataRequested extends TicketEvent {}

class TicketFetchAllRequested extends TicketEvent {}

class TicketStartInterventionRequested extends TicketEvent {
  final String ticketId;

  const TicketStartInterventionRequested({required this.ticketId});

  @override
  List<Object> get props => [ticketId];
}

class TicketCompleteInterventionRequested extends TicketEvent {
  final String ticketId;

  const TicketCompleteInterventionRequested({required this.ticketId});

  @override
  List<Object> get props => [ticketId];
}

class TicketTakeChargeRequested extends TicketEvent {
  final String ticketId;

  const TicketTakeChargeRequested({required this.ticketId});

  @override
  List<Object> get props => [ticketId];
}

class TicketCreateRequested extends TicketEvent {
  final String typeProbleme;
  final String description;
  final String adresse;
  final DateTime dateRdv;
  final List<String> photosBase64;

  const TicketCreateRequested({
    required this.typeProbleme,
    required this.description,
    required this.adresse,
    required this.dateRdv,
    required this.photosBase64,
  });

  @override
  List<Object> get props => [
        typeProbleme,
        description,
        adresse,
        dateRdv,
        photosBase64,
      ];
}