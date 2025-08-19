// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omeamobile/models/user_model.dart';
import 'package:omeamobile/models/ticket_model.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  // static const String _baseUrl = 'http://192.168.1.74:8000/api';
  // static const String _baseUrl = 'http://192.168.1.65:8000/api';
  // static const String _baseUrl = 'http://10.0.2.2:8000/api';

  static const String _authTokenKey = 'authToken';

  String? _authToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_authTokenKey);
  }

  Future<void> ensureTokenLoaded() async {
    if (_authToken == null) {
      await _loadAuthToken();
    }
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
      if (authorized) {
        await ensureTokenLoaded();
      }

      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = await _getHeaders(authorized: authorized);
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // CORRECTION: Mapper correctement selon la structure de réponse Laravel
        return {
          'success': true,
          'data': _extractDataFromResponse(responseData, endpoint),
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

  /// Extrait les données de la réponse selon l'endpoint
  dynamic _extractDataFromResponse(
    Map<String, dynamic> responseData,
    String endpoint,
  ) {
    // Pour les tickets, Laravel retourne directement le ticket
    if (endpoint == 'tickets') {
      return responseData['ticket'] ?? responseData['data'];
    }

    // Pour les autres endpoints, utiliser 'data' par défaut
    return responseData['data'];
  }

  Future<Map<String, dynamic>> _get(
    String endpoint, {
    bool authorized = false,
  }) async {
    try {
      if (authorized) {
        await ensureTokenLoaded();
      }

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

  // Login method remains the same
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
      return {
        'success': false,
        'message':
            'Réponse d\'authentification incomplète (token manquant dans la réponse de login).',
      };
    }
  }

  // Register method remains the same
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

  Future<Map<String, dynamic>> read(String ticketId) async {
    return await _post('read', {}, authorized: true);
  }

  Future<Map<String, dynamic>> startIntervention(String ticketId) async {
    return await _post('tickets/$ticketId/start', {}, authorized: true);
  }

  Future<Map<String, dynamic>> completeIntervention(String ticketId) async {
    return await _post('tickets/$ticketId/end', {}, authorized: true);
  }

  Future<Map<String, dynamic>> takeChargeOfTicket(String ticketId) async {
    return await _post('tickets/$ticketId/postuler', {}, authorized: true);
  }

  /// Creates a new ticket
  Future<Map<String, dynamic>> createTicket({
    required String typeProbleme,
    required String description,
    required String adresse,
    required String dateRdv,
    List<String>? photosBase64,
  }) async {
    final body = {
      'type_probleme': typeProbleme,
      'description': description,
      'adresse': adresse,
      'date_rdv': dateRdv,
      'photos': photosBase64 ?? [],
    };
    return await _post('tickets', body, authorized: true);
  }

  /// Supprime un ticket par son ID
  Future<Map<String, dynamic>> deleteTicket(String ticketId) async {
    try {
      await ensureTokenLoaded();
      final url = Uri.parse('$_baseUrl/tickets/$ticketId');
      final headers = await _getHeaders(authorized: true);
      final response = await http.delete(url, headers: headers);
      print(
        'ApiService: DELETE tickets/$ticketId (Status: \\${response.statusCode}): \\${response.body}',
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Ticket supprimé avec succès',
        };
      } else {
        String errorMessage =
            responseData['message'] ??
            'Erreur lors de la suppression du ticket.';
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print(
        'ApiService: Erreur réseau ClientException pour DELETE tickets/$ticketId: $e',
      );
      return {
        'success': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour DELETE tickets/$ticketId: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }

  /// Met à jour la photo de profil de l'utilisateur connecté
  Future<Map<String, dynamic>> updateProfileImage(String imageBase64) async {
    try {
      await ensureTokenLoaded();

      final url = Uri.parse('$_baseUrl/auth/update-profile-image');
      final headers = await _getHeaders(authorized: true);

      // Créer un body multipart pour l'upload de fichier
      final body = json.encode({'photo_profile': imageBase64});

      final response = await http.put(url, headers: headers, body: body);

      print(
        'ApiService: PUT update-profile-image (Status: ${response.statusCode}): ${response.body}',
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData['data'],
          'message':
              responseData['message'] ??
              'Photo de profil mise à jour avec succès',
        };
      } else {
        String errorMessage =
            responseData['message'] ??
            'Erreur lors de la mise à jour de la photo';
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
      print(
        'ApiService: Erreur réseau ClientException pour update-profile-image: $e',
      );
      return {
        'success': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour update-profile-image: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }

  /// Supprime la photo de profil de l'utilisateur connecté
  Future<Map<String, dynamic>> removeProfileImage() async {
    try {
      await ensureTokenLoaded();

      final url = Uri.parse('$_baseUrl/auth/remove-profile-image');
      final headers = await _getHeaders(authorized: true);

      final response = await http.delete(url, headers: headers);

      print(
        'ApiService: DELETE remove-profile-image (Status: ${response.statusCode}): ${response.body}',
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData['data'],
          'message':
              responseData['message'] ??
              'Photo de profil supprimée avec succès',
        };
      } else {
        String errorMessage =
            responseData['message'] ??
            'Erreur lors de la suppression de la photo';
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print(
        'ApiService: Erreur réseau ClientException pour remove-profile-image: $e',
      );
      return {
        'success': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour remove-profile-image: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }

  /// Generic PUT method for updating resources
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> data,
    bool authorized = true,
  }) async {
    try {
      if (authorized) {
        await ensureTokenLoaded();
      }
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = await _getHeaders(authorized: authorized);
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': true,
          'data': responseData['data'],
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
          'status': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('ApiService: Erreur réseau ClientException pour $endpoint: $e');
      return {
        'status': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour $endpoint: $e');
      return {
        'status': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }

  /// Récupère le lien de paiement pour un ticket donné
  Future<Map<String, dynamic>> getPaymentLink(String ticketId) async {
    try {
      await ensureTokenLoaded();
      final url = Uri.parse('$_baseUrl/tickets/$ticketId/payment-link');
      final headers = await _getHeaders(authorized: true);
      final response = await http.get(url, headers: headers);
      print(
        'ApiService: GET payment-link (Status: \\${response.statusCode}): \\${response.body}',
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'url': responseData['data']?['url'],
          'message': responseData['message'] ?? 'Lien de paiement généré',
        };
      } else {
        String errorMessage =
            responseData['message'] ??
            'Erreur lors de la génération du lien de paiement.';
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('ApiService: Erreur réseau ClientException pour payment-link: $e');
      return {
        'success': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour payment-link: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }

  Future<Map<String, dynamic>> getTechnicianDashboardData() async {
    try {
      await ensureTokenLoaded();
      final url = Uri.parse('$_baseUrl/read');
      final headers = await _getHeaders(authorized: true);
      final response = await http.get(url, headers: headers);

      print(
        'ApiService: GET read (Status: ${response.statusCode}): ${response.body}',
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
          'message':
              responseData['message'] ?? 'Données récupérées avec succès',
        };
      } else {
        String errorMessage =
            responseData['message'] ??
            'Erreur lors de la récupération des données.';
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('ApiService: Erreur réseau ClientException pour read: $e');
      return {
        'success': false,
        'message': 'Erreur réseau. Impossible de se connecter au serveur.',
      };
    } catch (e) {
      print('ApiService: Erreur inattendue pour read: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
    }
  }
}
