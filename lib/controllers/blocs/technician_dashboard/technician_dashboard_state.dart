// lib/controllers/blocs/technician_dashboard/technician_dashboard_state.dart

import 'package:equatable/equatable.dart';
import 'package:omeamobile/models/technician_dashboard_model.dart';

abstract class TechnicianDashboardState extends Equatable {
  const TechnicianDashboardState();

  @override
  List<Object?> get props => [];
}

class TechnicianDashboardInitial extends TechnicianDashboardState {}

class TechnicianDashboardLoading extends TechnicianDashboardState {}

class TechnicianDashboardLoaded extends TechnicianDashboardState {
  final TechnicianDashboardData dashboardData;

  const TechnicianDashboardLoaded({required this.dashboardData});

  @override
  List<Object> get props => [dashboardData];
}

class TechnicianDashboardActionLoading extends TechnicianDashboardState {
  final TechnicianDashboardData dashboardData;

  const TechnicianDashboardActionLoading({required this.dashboardData});

  @override
  List<Object> get props => [dashboardData];
}

class TechnicianDashboardError extends TechnicianDashboardState {
  final String message;

  const TechnicianDashboardError({required this.message});

  @override
  List<Object> get props => [message];
}

class TechnicianDashboardInterventionStarted extends TechnicianDashboardState {
  final dynamic ticket;
  const TechnicianDashboardInterventionStarted({required this.ticket});
  @override
  List<Object?> get props => [ticket];
}
