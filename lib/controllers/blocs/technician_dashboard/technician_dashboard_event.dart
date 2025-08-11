// lib/controllers/blocs/technician_dashboard/technician_dashboard_event.dart

import 'package:equatable/equatable.dart';

abstract class TechnicianDashboardEvent extends Equatable {
  const TechnicianDashboardEvent();

  @override
  List<Object?> get props => [];
}

class TechnicianDashboardDataRequested extends TechnicianDashboardEvent {}

class TechnicianStartInterventionRequested extends TechnicianDashboardEvent {
  final String ticketId;

  const TechnicianStartInterventionRequested({required this.ticketId});

  @override
  List<Object> get props => [ticketId];
}

class TechnicianEndInterventionRequested extends TechnicianDashboardEvent {
  final String ticketId;

  const TechnicianEndInterventionRequested({required this.ticketId});

  @override
  List<Object> get props => [ticketId];
}
