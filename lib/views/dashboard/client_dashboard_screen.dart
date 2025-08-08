// lib/views/dashboard/client_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:omeamobile/controllers/blocs/auth/auth_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_state.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_bloc.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_event.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_state.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/models/user_model.dart';
import 'package:omeamobile/views/profile/profile_screen.dart';
import 'package:omeamobile/views/tickets/new_ticket.dart';
import 'package:omeamobile/views/tickets/ticket_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketBloc>().add(TicketFetchDashboardDataRequested());
    });

    _widgetOptions = <Widget>[
      _DashboardContent(),
      _DashboardContent(showSearchBar: false, showFilterTabs: false),
      _HistoriqueTicketsList(),
      ProfileScreen(),
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
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewTicketScreen(),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final bool showSearchBar;
  final bool showFilterTabs;
  const _DashboardContent({this.showSearchBar = true, this.showFilterTabs = true, Key? key}) : super(key: key);
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Erreur: Utilisateur non connecté.'));
        }

        final user = authState.user;

        return BlocConsumer<TicketBloc, TicketState>(
          listener: (context, state) {
            if (state is TicketCreated) {
              // Ticket créé avec succès, les données sont automatiquement rafraîchies
            }
          },
          builder: (context, state) {
            List<Ticket> allTickets = [];
            if (state is TicketLoaded || state is TicketCreated) {
              if (state is TicketLoaded) {
                allTickets = state.allTickets;
              } else if (state is TicketCreated) {
                allTickets = state.allTickets;
              }
            }

            // Filter tickets based on the current tab
            List<Ticket> filteredTickets = [];
            switch (_tabController.index) {
              case 0: // Tous
                filteredTickets = allTickets;
                break;
              case 1: // En cours (In Progress)
                filteredTickets =
                    allTickets
                        .where(
                          (ticket) => ticket.status == TicketStatus.inProgress,
                        )
                        .toList();
                break;
              case 2: // En attente (Pending or other pending states)
                filteredTickets =
                    allTickets
                        .where(
                          (ticket) =>
                              ticket.status == TicketStatus.pending ||
                              ticket.status == TicketStatus.completed ||
                              ticket.status == TicketStatus.inProgress,
                        )
                        .toList();
                break;
              case 3: // Terminé (Completed)
                filteredTickets =
                    allTickets
                        .where(
                          (ticket) => ticket.status == TicketStatus.completed,
                        )
                        .toList();
                break;
            }

            // Calculate notification count
            final int notificationCount =
                allTickets
                    .where(
                      (ticket) =>
                          ticket.status == TicketStatus.inProgress ||
                          ticket.status == TicketStatus.pending ||
                          ticket.status == TicketStatus.completed,
                    )
                    .length;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TicketBloc>().add(
                  TicketFetchDashboardDataRequested(),
                );
              },
              child: Column(
                children: [
                  _buildHeader(context, user, notificationCount),
                  if (widget.showSearchBar) _buildSearchBar(context),
                  if (widget.showFilterTabs) _buildTicketFilterTabs(context),
                  Expanded(
                    child: widget.showFilterTabs
                        ? TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTicketListView(context, filteredTickets),
                              _buildTicketListView(context, filteredTickets),
                              _buildTicketListView(context, filteredTickets),
                              _buildTicketListView(context, filteredTickets),
                            ],
                          )
                        : _buildTicketListView(context, allTickets),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, User user, int notificationCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour ${user.nom.split(' ')[0]}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const Text(
                    'Client',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 28,
                    ),
                    onPressed: () {
                      // Handle notification tap
                    },
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
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
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 28,
                ),
                onPressed: () {
                  // Handle settings tap
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un ticket',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketFilterTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).primaryColor,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[700],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            tabs: const [
              Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Tous'))),
              Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('En cours'))),
              Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('En attente'))),
              Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Terminé'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketListView(BuildContext context, List<Ticket> tickets) {
    if (tickets.isEmpty) {
      return const Center(child: Text('Aucun ticket dans cette catégorie.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildClientTicketListItem(context, ticket);
      },
    );
  }

  Widget _buildClientTicketListItem(BuildContext context, Ticket ticket) {
    String statusText;
    Color statusBgColor;
    Color statusTextColor;
    IconData icon;

    switch (ticket.status) {
      case TicketStatus.inProgress:
        statusText = 'En cours';
        statusBgColor = Colors.red.shade100;
        statusTextColor = Colors.red.shade700;
        icon = Icons.print_outlined;
        break;
      case TicketStatus.completed:
        statusText = 'Planifié';
        statusBgColor = Colors.blue.shade100;
        statusTextColor = Colors.blue.shade700;
        icon = Icons.wifi_outlined;
        break;
      case TicketStatus.pending:
      case TicketStatus.cancelled:
        statusText = 'En attente';
        statusBgColor = Colors.grey.shade100;
        statusTextColor = Colors.grey.shade700;
        icon = Icons.help_outline;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#${ticket.id}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ticket.scheduledTime.day} ${_getMonthName(ticket.scheduledTime.month)} ${ticket.scheduledTime.year}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Technicien : ${ticket.technicianName ?? 'Non assigné'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (ticket.status == TicketStatus.completed)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                const SizedBox(height: 12),
                Container(
                  child:
                      ticket.photoBase64 != null &&
                              ticket.photoBase64!.isNotEmpty
                          ? Image.memory(
                            base64Decode(ticket.photoBase64!),
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.photo_camera,
                            size: 24,
                            color: Colors.grey[600],
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int? month) {
    if (month == null) return '';
    const List<String> monthNames = [
      '',
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return monthNames[month];
  }
}

class _HistoriqueTicketsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Erreur: Utilisateur non connecté.'));
        }
        return BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            List<Ticket> completedTickets = [];
            if (state is TicketLoaded || state is TicketCreated) {
              final allTickets = state is TicketLoaded ? state.allTickets : (state as TicketCreated).allTickets;
              completedTickets = allTickets.where((ticket) => ticket.status == TicketStatus.completed).toList();
            }
            if (completedTickets.isEmpty) {
              return const Center(child: Text('Aucun ticket terminé.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: completedTickets.length,
              itemBuilder: (context, index) {
                final ticket = completedTickets[index];
                return _DashboardContentState()._buildClientTicketListItem(context, ticket);
              },
            );
          },
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
