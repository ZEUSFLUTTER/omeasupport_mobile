// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_bloc.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_event.dart';
import 'package:omeamobile/controllers/blocs/auth/auth_state.dart';
import 'package:omeamobile/controllers/blocs/tickets/ticket_bloc.dart';
import 'package:omeamobile/controllers/blocs/profile/profile_bloc.dart';
import 'package:omeamobile/services/api_service.dart';
import 'package:omeamobile/services/ticket_service.dart';
import 'package:omeamobile/views/auth/login_screen.dart';
import 'package:omeamobile/views/dashboard/client_dashboard_screen.dart';
import 'package:omeamobile/views/dashboard/technician_dashboard_screen.dart';

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
