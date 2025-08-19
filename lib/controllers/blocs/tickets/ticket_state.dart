// lib/blocs/ticket/ticket_state.dart

import 'package:equatable/equatable.dart';
import 'package:omeamobile/models/ticket_model.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketActionLoading extends TicketState {
  final List<Ticket> allTickets;
  final List<Ticket> todaysTickets;
  final List<Ticket> pendingTickets;
  final List<Ticket> completedTickets;
  final Ticket? activeTicket;

  const TicketActionLoading({
    required this.allTickets,
    required this.todaysTickets,
    required this.pendingTickets,
    required this.completedTickets,
    this.activeTicket,
  });

  @override
  List<Object?> get props => [
        allTickets,
        todaysTickets,
        pendingTickets,
        completedTickets,
        activeTicket,
      ];
}

class TicketLoaded extends TicketState {
  final List<Ticket> allTickets;
  final List<Ticket> todaysTickets;
  final List<Ticket> pendingTickets;
  final List<Ticket> completedTickets;
  final Ticket? activeTicket;

  const TicketLoaded({
    required this.allTickets,
    required this.todaysTickets,
    required this.pendingTickets,
    required this.completedTickets,
    this.activeTicket,
  });

  @override
  List<Object?> get props => [
        allTickets,
        todaysTickets,
        pendingTickets,
        completedTickets,
        activeTicket,
      ];

  TicketLoaded copyWith({
    List<Ticket>? allTickets,
    List<Ticket>? todaysTickets,
    List<Ticket>? pendingTickets,
    List<Ticket>? completedTickets,
    Ticket? activeTicket,
  }) {
    return TicketLoaded(
      allTickets: allTickets ?? this.allTickets,
      todaysTickets: todaysTickets ?? this.todaysTickets,
      pendingTickets: pendingTickets ?? this.pendingTickets,
      completedTickets: completedTickets ?? this.completedTickets,
      activeTicket: activeTicket ?? this.activeTicket,
    );
  }
}

class TicketError extends TicketState {
  final String message;

  const TicketError({required this.message});

  @override
  List<Object> get props => [message];
}

class TicketActionSuccess extends TicketState {
  final String message;
  final List<Ticket> allTickets;
  final List<Ticket> todaysTickets;
  final List<Ticket> pendingTickets;
  final List<Ticket> completedTickets;
  final Ticket? activeTicket;

  const TicketActionSuccess({
    required this.message,
    required this.allTickets,
    required this.todaysTickets,
    required this.pendingTickets,
    required this.completedTickets,
    this.activeTicket,
  });

  @override
  List<Object?> get props => [
        message,
        allTickets,
        todaysTickets,
        pendingTickets,
        completedTickets,
        activeTicket,
      ];
}

class TicketCreated extends TicketState {
  final Ticket createdTicket;
  final List<Ticket> allTickets;
  final List<Ticket> todaysTickets;
  final List<Ticket> pendingTickets;
  final List<Ticket> completedTickets;
  final Ticket? activeTicket;

  const TicketCreated({
    required this.createdTicket,
    required this.allTickets,
    required this.todaysTickets,
    required this.pendingTickets,
    required this.completedTickets,
    this.activeTicket,
  });

  @override
  List<Object?> get props => [
        createdTicket,
        allTickets,
        todaysTickets,
        pendingTickets,
        completedTickets,
        activeTicket,
      ];
}