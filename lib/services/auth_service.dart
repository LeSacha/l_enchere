import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.237:3000';
  
  static const String androidClientId =
      '223100115013-8hnja2nhelrkjcj4r8vbebgfs1t1o197.apps.googleusercontent.com';
  static const String iosClientId =
      '223100115013-3j8cehajlu8tfl420j2rt74aobqhj91v.apps.googleusercontent.com';
  static const String webClientId =
      '223100115013-sf30js8rarl97ddndkiq5icvj2rk0h31.apps.googleusercontent.com'; 

  /// ✅ Configuration Google Sign-In
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: webClientId, 
  );

  /// --- Connexion par email ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          "accessToken": data['accessToken'],
          "refreshToken": data['refreshToken'],
          "user": data['user'],
        };
      } else if (response.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur API login: $e');
      throw Exception('Impossible de se connecter au serveur');
    }
  }

  /// ✅ --- Connexion via Google Mobile ---
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Connexion annulée par l'utilisateur");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception("Impossible d'obtenir l'idToken Google");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      print('📡 Réponse Google mobile: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          "accessToken": data['accessToken'],
          "refreshToken": data['refreshToken'],
          "user": data['user'],
        };
      } else {
        throw Exception('Erreur serveur: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur loginWithGoogle: $e');
      rethrow;
    }
  }

  /// --- Inscription classique ---
  static Future<Map<String, dynamic>> register(
    String pseudo,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pseudo': pseudo,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          "accessToken": data['accessToken'],
          "refreshToken": data['refreshToken'],
          "user": data['user'],
        };
      } else {
        throw Exception('Erreur inscription: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur API register: $e');
      rethrow;
    }
  }

  /// --- Déconnexion ---
  static Future<void> logout(String userId, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('⚠️ Logout API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur logout: $e');
    }
  }

  /// --- Mise à jour du pseudo ---
  static Future<Map<String, dynamic>> updatePseudo({
    required String token,
    required String newPseudo,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/pseudo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'newPseudo': newPseudo}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la mise à jour du pseudo');
      }
    } catch (e) {
      print('❌ Erreur updatePseudo: $e');
      rethrow;
    }
  }

  /// --- Mise à jour du mot de passe ---
  static Future<void> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du changement de mot de passe');
      }
    } catch (e) {
      print('❌ Erreur updatePassword: $e');
      rethrow;
    }
  }
}
