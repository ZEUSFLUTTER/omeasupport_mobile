// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_event.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_state.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_bloc.dart';
import 'package:omeamobile/controllers/blocs/profile/profile_bloc.dart';
import 'package:omeamobile/controllers/blocs/technician_dashboard/technician_dashboard_bloc.dart';
import 'package:omeamobile/services/api_service.dart';
import 'package:omeamobile/services/ticket_service.dart';
import 'package:omeamobile/views/auth/login_screen.dart';
import 'package:omeamobile/views/dashboard/client_dashboard_screen.dart';
import 'package:omeamobile/views/dashboard/technician_dashboard_screen.dart';
import 'package:omeamobile/views/tickets/details_ticket.dart';
import 'package:omeamobile/views/tickets/intervention.dart';
import 'package:omeamobile/views/tickets/rapport.dart';
import 'package:omeamobile/views/tickets/ending_details.dart';
import 'package:omeamobile/models/ticket_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final ticketService = TicketService(apiService);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: ticketService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    AuthBloc(apiService: apiService)..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create:
                (context) => TicketBloc(
                  apiService: apiService,
                  ticketService: ticketService,
                ),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(apiService: apiService),
          ),
          BlocProvider(
            create:
                (context) => TechnicianDashboardBloc(apiService: apiService),
          ),
        ],
        child: MaterialApp(
          title: 'OmeaSupport',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFF1A73E8),
            hintColor: const Color(0xFF6B6B6B),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Theme.of(context).primaryColor),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/details_ticket') {
              final ticket = settings.arguments as Ticket;
              return MaterialPageRoute(
                builder: (context) => DetailsTicketScreen(ticket: ticket),
              );
<<<<<<< HEAD
            } else if (authController.isAuthenticated) {
              // Redirige vers le bon dashboard selon le rôle de l'utilisateur
              if (authController.currentUser?.role == UserRole.technician) {
                return const TechnicianDashboardScreen();
              } else if (authController.currentUser?.role == UserRole.client) {
                return const ClientDashboardScreen();
=======
            }
            if (settings.name == '/intervention') {
              final ticket = settings.arguments as Ticket;
              return MaterialPageRoute(
                builder: (context) => InterventionScreen(ticket: ticket),
              );
            }
            if (settings.name == '/rapport') {
              final args = settings.arguments;
              if (args is Map) {
                final ticket = args['ticket'] as Ticket;
                final heureDebut = args['heure_debut'] as String;
                final heureFin = args['heure_fin'] as String;
                return MaterialPageRoute(
                  builder:
                      (context) => RapportScreen(
                        ticket: ticket,
                        heureDebut: heureDebut,
                        heureFin: heureFin,
                      ),
                );
              } else if (args is Ticket) {
                // fallback: if only Ticket is passed
                return MaterialPageRoute(
                  builder:
                      (context) => RapportScreen(
                        ticket: args,
                        heureDebut: '',
                        heureFin: '',
                      ),
                );
              }
            }
            if (settings.name == '/ending_details') {
              final args = settings.arguments;
              if (args is Map) {
                final ticket = args['ticket'];
                final rapport = args['rapport'];
                return MaterialPageRoute(
                  builder:
                      (context) =>
                          EndingDetailsScreen(ticket: ticket, rapport: rapport),
                );
              }
            }
            // Default fallback: return null to use home
            return null;
          },
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state is AuthAuthenticated) {
                if (state.user.role == 'technician') {
                  return const TechnicianDashboardScreen();
                } else if (state.user.role == 'client') {
                  return const ClientDashboardScreen();
                } else {
                  return const LoginScreen();
                }
>>>>>>> divor
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
