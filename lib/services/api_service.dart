// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omeamobile/models/user_model.dart';
import 'package:omeamobile/models/ticket_model.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static const String _authTokenKey = 'authToken';

  String? _authToken;

  ApiService() {
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_authTokenKey);
    print('ApiService: Token chargé au démarrage: $_authToken');
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    _authToken = token;
    print('ApiService: Token sauvegardé: $_authToken');
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    _authToken = null;
    print('ApiService: Token supprimé.');
  }

  bool get hasAuthToken => _authToken != null;

  Future<Map<String, String>> _getHeaders({bool authorized = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authorized && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body, {
    bool authorized = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = await _getHeaders(authorized: authorized);
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print(
        'ApiService: POST $endpoint (Status: ${response.statusCode}): ${response.body}',
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data':
              responseData['data'], // <= C'EST LA CLEF ! On extrait le contenu de 'data' de la réponse Laravel ici.
          'message': responseData['message'] ?? 'Succès',
        };
      } else {
        String errorMessage = responseData['message'] ?? 'Erreur du serveur.';
        if (responseData['errors'] != null && responseData['errors'] is Map) {
          responseData['errors'].forEach((key, value) {
            if (value is List) {
              errorMessage += '\n- ${value.join(", ")}';
            }
          });
        }
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('ApiService: Erreur réseau ClientException pour $endpoint: $e');
      return {
        'success': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour $endpoint: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }

  Future<Map<String, dynamic>> _get(
    String endpoint, {
    bool authorized = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = await _getHeaders(authorized: authorized);
      final response = await http.get(url, headers: headers);

      print(
        'ApiService: GET $endpoint (Status: ${response.statusCode}): ${response.body}',
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData['data'], 
          'message': responseData['message'] ?? 'Succès',
        };
      } else {
        String errorMessage = responseData['message'] ?? 'Erreur du serveur.';
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('ApiService: Erreur réseau ClientException pour $endpoint: $e');
      return {
        'success': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour $endpoint: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('auth/login', {
      'email': email,
      'password': password,
    }, authorized: false);

    if (response['success'] == false) {
      return response;
    }


    final Map<String, dynamic>? loginResponseData =
        response['data'] as Map<String, dynamic>?;

    if (loginResponseData != null && loginResponseData['token'] != null) {
      final String token = loginResponseData['token'];
      await _saveAuthToken(token);

      final userProfileResponse = await getUserProfile();

      if (userProfileResponse['success'] == true &&
          userProfileResponse['data'] != null) {
        final Map<String, dynamic> userData = userProfileResponse['data'];
        try {
          final User user = User.fromJson(userData);
          return {
            'success': true,
            'message': response['message'],
            'user': user,
          };
        } catch (e) {
          print(
            'ApiService: Erreur de parsing du profil utilisateur après login: $e',
          );
          await clearAuthToken();
          return {
            'success': false,
            'message':
                'Connexion réussie, mais format du profil utilisateur invalide.',
          };
        }
      } else {
        print(
          'ApiService: Erreur de récupération du profil utilisateur après login réussi: ${userProfileResponse['message']}',
        );
        await clearAuthToken();
        return {
          'success': false,
          'message':
              'Connexion réussie, mais impossible de récupérer le profil utilisateur. Veuillez réessayer.',
        };
      }
    } else {
      // C'est ici que votre erreur "token manquant" se déclenche.
      // Cela ne devrait arriver QUE si 'token' n'est pas directement sous 'data'
      // ou si 'data' est null.
      return {
        'success': false,
        'message':
            'Réponse d\'authentification incomplète (token manquant dans la réponse de login).',
      };
    }
  }

  // La méthode register aura une logique similaire
  Future<Map<String, dynamic>> register(
    String nom,
    String prenom,
    String email,
    String password,
    String passwordConfirmation,
    String telephone,
    String pays,
    String ville,
    String role,
  ) async {
    final response = await _post('auth/register', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'telephone': telephone,
      'pays': pays,
      'ville': ville,
      'role': role,
    });

    if (response['success'] == false) {
      return response;
    }

    final Map<String, dynamic>? registerResponseData =
        response['data'] as Map<String, dynamic>?;

    if (registerResponseData != null && registerResponseData['token'] != null) {
      final String token = registerResponseData['token'];
      await _saveAuthToken(token);

      final userProfileResponse = await getUserProfile();

      if (userProfileResponse['success'] == true &&
          userProfileResponse['data'] != null) {
        final Map<String, dynamic> userData = userProfileResponse['data'];
        try {
          final User user = User.fromJson(userData);
          return {
            'success': true,
            'message': response['message'],
            'user': user,
          };
        } catch (e) {
          print(
            'ApiService: Erreur de parsing du profil utilisateur après enregistrement: $e',
          );
          await clearAuthToken();
          return {
            'success': false,
            'message':
                'Inscription réussie, mais format du profil utilisateur invalide.',
          };
        }
      } else {
        print(
          'ApiService: Erreur de récupération du profil utilisateur après inscription réussie: ${userProfileResponse['message']}',
        );
        await clearAuthToken();
        return {
          'success': false,
          'message':
              'Inscription réussie, mais impossible de récupérer le profil utilisateur. Veuillez vous connecter manuellement.',
        };
      }
    } else {
      return {
        'success': false,
        'message':
            'Inscription réussie, mais réponse API incomplète (token manquant).',
      };
    }
  }

  Future<bool> logout() async {
    try {
      await _post('auth/logout', {}, authorized: true);
      await clearAuthToken();
      print('ApiService: Déconnexion API réussie.');
      return true;
    } catch (e) {
      print('ApiService: Erreur lors de la déconnexion API: $e');
      await clearAuthToken();
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _get('auth/profile', authorized: true);
  }

  // ... (Autres méthodes pour les tickets, inchangées)
  Future<Map<String, dynamic>> getTickets({
    String? status,
    String? type,
  }) async {
    String endpoint = 'tickets';
    Map<String, dynamic> queryParams = {};
    if (status != null) {
      queryParams['status'] = status;
    }
    if (type != null) {
      queryParams['type'] = type;
    }

    Uri uri = Uri.parse('$_baseUrl/$endpoint').replace(
      queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
    );

    try {
      final headers = await _getHeaders(authorized: true);
      final response = await http.get(uri, headers: headers);
      print(
        'ApiService: GET $endpoint (Status: ${response.statusCode}): ${response.body}',
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<Ticket> tickets = [];
        if (responseData['data'] != null && responseData['data'] is List) {
          tickets =
              (responseData['data'] as List)
                  .map((item) => Ticket.fromJson(item as Map<String, dynamic>))
                  .toList();
        }
        return {
          'success': true,
          'tickets': tickets,
          'message': responseData['message'] ?? 'Succès',
        };
      } else {
        String errorMessage =
            responseData['message'] ??
            'Erreur lors de la récupération des tickets.';
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('ApiService: Erreur réseau ClientException pour $endpoint: $e');
      return {'success': false, 'message': 'Erreur réseau: ${e.message}'};
    } catch (e) {
      print('ApiService: Erreur inattendue pour $endpoint: $e');
      return {'success': false, 'message': 'Erreur inattendue: $e'};
    }
  }

  Future<Map<String, dynamic>> startIntervention(String ticketId) async {
    return await _post('tickets/$ticketId/start', {}, authorized: true);
  }

  Future<Map<String, dynamic>> completeIntervention(String ticketId) async {
    return await _post('tickets/$ticketId/complete', {}, authorized: true);
  }

  Future<Map<String, dynamic>> takeChargeOfTicket(String ticketId) async {
    return await _post('tickets/$ticketId/take_charge', {}, authorized: true);
  }
}
