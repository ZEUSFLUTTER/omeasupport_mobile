// lib/views/dashboard/technician_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_state.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_bloc.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_event.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_state.dart';
import 'package:omeamobile/models/technician_dashboard_model.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/models/user_model.dart';
import 'package:omeamobile/utils/snackbar_helper.dart';
import 'package:omeamobile/views/profile/profile_screen.dart';
import 'package:omeamobile/views/tickets/ticket_screen.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechnicianDashboardBloc>().add(
        TechnicianDashboardDataRequested(),
      );
    });

    _widgetOptions = <Widget>[
      _DashboardContent(),
      const TicketsScreen(),
      const Center(child: Text('Historique')),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Erreur: Utilisateur non connecté.'));
        }

        final user = authState.user;

        return BlocConsumer<TechnicianDashboardBloc, TechnicianDashboardState>(
          listener: (context, state) {
            if (state is TechnicianDashboardError) {
              SnackBarHelper.showError(
                context: context,
                message: state.message,
                actionLabel: 'Réessayer',
                onActionPressed: () {
                  context.read<TechnicianDashboardBloc>().add(
                    TechnicianDashboardDataRequested(),
                  );
                },
              );
            }
          },
          builder: (context, state) {
            if (state is TechnicianDashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            TechnicianDashboardData? dashboardData;
            bool isActionLoading = false;

            if (state is TechnicianDashboardLoaded) {
              dashboardData = state.dashboardData;
            } else if (state is TechnicianDashboardActionLoading) {
              dashboardData = state.dashboardData;
              isActionLoading = true;
            } else if (state is TechnicianDashboardError) {
              return _buildErrorView(context, state.message);
            }

            if (dashboardData == null) {
              return _buildErrorView(context, 'Aucune donnée disponible');
            }

            final notificationCount =
                dashboardData.dashboardSummary.pendingTickets;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TechnicianDashboardBloc>().add(
                  TechnicianDashboardDataRequested(),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, user, notificationCount),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aperçu du jour',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDailyOverviewGrid(
                            context,
                            dashboardData.dashboardSummary,
                          ),
                          const SizedBox(height: 24),
                          _buildActiveTicketCard(
                            context,
                            dashboardData.activeTicket,
                            isActionLoading,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Tous les tickets',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildAllTicketsList(
                            context,
                            dashboardData.allTickets,
                            isActionLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TechnicianDashboardBloc>().add(
          TechnicianDashboardDataRequested(),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<TechnicianDashboardBloc>().add(
                      TechnicianDashboardDataRequested(),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user, int notificationCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    user.nom,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.ville,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_none_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          notificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDailyOverviewGrid(
    BuildContext context,
    DashboardSummary summary,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildOverviewCard(
                context,
                'Tickets aujourd\'hui',
                summary.ticketsToday.toString(),
                Icons.assignment,
                Colors.blue.shade100,
                Colors.blue.shade700,
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                context,
                'Terminés',
                summary.completedTickets.toString(),
                Icons.check_circle_outline,
                Colors.green.shade100,
                Colors.green.shade700,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildOverviewCard(
                context,
                'En attente',
                summary.pendingTickets.toString(),
                Icons.access_time_outlined,
                Colors.orange.shade100,
                Colors.orange.shade700,
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                context,
                'Distance',
                '${summary.distanceTraveled.toStringAsFixed(1)} km',
                Icons.directions_car_outlined,
                Colors.red.shade100,
                Colors.red.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTicketCard(
    BuildContext context,
    Ticket? activeTicket,
    bool isActionLoading,
  ) {
    if (activeTicket == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun ticket actif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tous vos tickets sont terminés ou aucune intervention en cours.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'TICKET ACTIF',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    activeTicket.status == TicketStatus.inProgress
                        ? 'IN_PROGRESS'
                        : 'PENDING',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activeTicket.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              activeTicket.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    activeTicket.location,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  activeTicket.clientName,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${activeTicket.scheduledTime.hour}:${activeTicket.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isActionLoading
                        ? null
                        : () {
                          if (activeTicket.status == TicketStatus.inProgress) {
                            // Terminer l'intervention
                            context.read<TechnicianDashboardBloc>().add(
                              TechnicianEndInterventionRequested(
                                ticketId: activeTicket.id,
                              ),
                            );
                          } else {
                            // Commencer l'intervention
                            context.read<TechnicianDashboardBloc>().add(
                              TechnicianStartInterventionRequested(
                                ticketId: activeTicket.id,
                              ),
                            );
                          }
                        },
                icon: Icon(
                  activeTicket.status == TicketStatus.inProgress
                      ? Icons.stop
                      : Icons.play_arrow,
                ),
                label: Text(
                  activeTicket.status == TicketStatus.inProgress
                      ? 'TERMINER INTERVENTION'
                      : 'COMMENCER INTERVENTION',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      activeTicket.status == TicketStatus.inProgress
                          ? Colors.red
                          : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTicketsList(
    BuildContext context,
    List<Ticket> allTickets,
    bool isActionLoading,
  ) {
    if (allTickets.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun ticket disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aucun ticket n\'est actuellement assigné.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          allTickets.map((ticket) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildTicketListItem(context, ticket, isActionLoading),
            );
          }).toList(),
    );
  }

  Widget _buildTicketListItem(
    BuildContext context,
    Ticket ticket,
    bool isActionLoading,
  ) {
    Color priorityColor;
    String statusText;
    Color statusBgColor;
    Color statusTextColor;
    String buttonText = '';
    Function()? onPressedButton;

    switch (ticket.priority) {
      case TicketPriority.low:
        priorityColor = Colors.green;
        break;
      case TicketPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TicketPriority.high:
        priorityColor = Colors.red;
        break;
      case TicketPriority.critical:
        priorityColor = Colors.red.shade900;
        break;
    }

    switch (ticket.status) {
      case TicketStatus.pending:
        statusText = 'PENDING';
        statusBgColor = Colors.blue.shade100;
        statusTextColor = Colors.blue.shade700;
        buttonText = 'Commencer';
        onPressedButton = () {
          context.read<TechnicianDashboardBloc>().add(
            TechnicianStartInterventionRequested(ticketId: ticket.id),
          );
        };
        break;
      case TicketStatus.inProgress:
        statusText = 'IN_PROGRESS';
        statusBgColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade700;
        buttonText = 'Terminer';
        onPressedButton = () {
          context.read<TechnicianDashboardBloc>().add(
            TechnicianEndInterventionRequested(ticketId: ticket.id),
          );
        };
        break;
      case TicketStatus.completed:
        statusText = 'COMPLETED';
        statusBgColor = Colors.green.shade100;
        statusTextColor = Colors.green.shade700;
        buttonText = 'Détails';
        onPressedButton = () {
          // Naviguer vers les détails du ticket
        };
        break;
      case TicketStatus.cancelled:
        statusText = 'CANCELLED';
        statusBgColor = Colors.grey.shade300;
        statusTextColor = Colors.grey.shade700;
        buttonText = 'Détails';
        onPressedButton = () {};
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        ticket.priority
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#${ticket.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  ticket.clientName,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ticket.location,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${ticket.scheduledTime.hour}:${ticket.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (buttonText.isNotEmpty)
                  Flexible(
                    // Ajouter Flexible ici
                    child: SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: isActionLoading ? null : onPressedButton,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusTextColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ), // Réduire padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                          ), // Réduire taille police
                        ),
                        child:
                            isActionLoading
                                ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  buttonText,
                                  overflow:
                                      TextOverflow.ellipsis, // Ajouter overflow
                                  maxLines: 1,
                                ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
