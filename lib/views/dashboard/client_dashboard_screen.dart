// lib/views/dashboard/technician_dashboard_screen.dart (This file will now serve as the Client Dashboard)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:omeamobile/controllers/auth_controller.dart';
import 'package:omeamobile/controllers/ticket_controller.dart';
import 'package:omeamobile/models/ticket_model.dart';
import 'package:omeamobile/models/user_model.dart';
import 'package:omeamobile/views/tickets/ticket_screen.dart'; // Assuming this can show client tickets too
import 'package:omeamobile/views/profile/profile_screen.dart';
import 'package:omeamobile/views/tickets/new_ticket.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _selectedIndex = 0; // For the BottomNavigationBar
  late List<Widget> _widgetOptions; // List of screens

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketController>(
        context,
        listen: false,
      ).fetchDashboardData(); // This should fetch client-specific tickets
    });

    _widgetOptions = <Widget>[
      _DashboardContent(), // Main dashboard content for client
      TicketsScreen(), // Tickets screen (might need to be client-specific)
      const Center(child: Text('Historique')), // History screen
      ProfileScreen(), // Profile screen
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
                  // Correction ici : Utilisation standard de Navigator.push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const NewTicketScreen(), // Remplacez NewTicketScreen par le nom de votre écran de création de ticket
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
      // Potentially filter tickets based on the selected tab
      // In a real app, you might trigger a new fetch or filter from the already fetched list
      setState(() {}); // Rebuild to apply filter
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final ticketController = Provider.of<TicketController>(context);
    final user = authController.currentUser;

    if (user == null) {
      return const Center(child: Text('Erreur: Utilisateur non connecté.'));
    }

    // Filter tickets based on the current tab
    List<Ticket> filteredTickets = [];
    switch (_tabController.index) {
      case 0: // Tous
        filteredTickets = ticketController.allTickets;
        break;
      case 1: // En cours (In Progress)
        filteredTickets =
            ticketController.allTickets
                .where((ticket) => ticket.status == TicketStatus.inProgress)
                .toList();
        break;
      case 2: // En attente (Pending or inProgress/completed)
        filteredTickets =
            ticketController.allTickets
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
            ticketController.allTickets
                .where((ticket) => ticket.status == TicketStatus.completed)
                .toList();
        break;
    }

    // Calculate notification count (e.g., tickets 'En cours' + 'En attente')
    final int notificationCount =
        ticketController.allTickets
            .where(
              (ticket) =>
                  ticket.status == TicketStatus.inProgress ||
                  ticket.status == TicketStatus.pending ||
                  ticket.status == TicketStatus.completed ||
                  ticket.status == TicketStatus.inProgress,
            )
            .length;

    return RefreshIndicator(
      onRefresh: () => ticketController.fetchDashboardData(),
      child: Column(
        children: [
          _buildHeader(context, user, notificationCount),
          _buildSearchBar(context),
          _buildTicketFilterTabs(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTicketListView(context, filteredTickets),
                _buildTicketListView(context, filteredTickets),
                _buildTicketListView(context, filteredTickets),
                _buildTicketListView(context, filteredTickets),
              ],
            ),
          ),
        ],
      ),
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
              // User avatar
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
                    'Bonjour ${user.nom.split(' ')[0]}', // Assuming nom contains first name
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const Text(
                    'Client', // As seen in the image
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          // Notification and Settings Icons
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 40, // Adjust height as needed
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[700],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'En cours'),
            Tab(text: 'En attente'),
            Tab(text: 'Terminé'),
          ],
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
    String dateLabel;
    String formattedDate;

    // Determine status text, colors, and icon based on ticket status
    switch (ticket.status) {
      case TicketStatus.inProgress:
        statusText = 'En cours';
        statusBgColor = Colors.red.shade100;
        statusTextColor = Colors.red.shade700;
        icon =
            Icons
                .print_outlined; // Example icon, adjust based on ticket type if available
        // Assuming createdAt exists
        break;
      case TicketStatus.completed: // 'Planifié' in the image
      case TicketStatus.inProgress:
        statusText = 'Planifié';
        statusBgColor = Colors.blue.shade100;
        statusTextColor = Colors.blue.shade700;
        icon = Icons.wifi_outlined; // Example icon
        break;
      case TicketStatus.completed:
        statusText = 'Terminé';
        statusBgColor = Colors.green.shade100;
        statusTextColor = Colors.green.shade700;
        icon =
            Icons
                .star_border; // Example icon for completed, or specific service icon

        break;
      case TicketStatus.pending: // Default for others not explicitly styled
      case TicketStatus.cancelled:
      default:
        statusText = 'En attente'; // Or 'Annulé' etc.
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
                        'Technicien : ${ticket.technicianName ?? 'Non assigné'}', // Assuming technicianName field exists
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (ticket.status ==
                      TicketStatus.completed) // If you have a rating field
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
                // Icon for the ticket type as seen in the image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 30, color: Colors.grey[600]),
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
