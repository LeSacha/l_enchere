import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  String? token;
  String? refreshToken;
  Map<String, dynamic>? user;

  /// --- Connexion par email ---
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final data = await AuthService.login(email, password);

      token = data["accessToken"];
      refreshToken = data["refreshToken"];
      user = data["user"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);
      await prefs.setString("refreshToken", refreshToken!);
      await prefs.setString("user", jsonEncode(user));

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur de connexion : $e");
      rethrow;
    }
  }

  /// --- Déconnexion ---
  Future<void> logout() async {
    if (token != null && user != null && user!['id'] != null) {
      try {
        await AuthService.logout(user!['id'], token!);
      } catch (e) {
        debugPrint("⚠️ Erreur lors de la déconnexion API: $e");
      }
    }

    token = null;
    refreshToken = null;
    user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("refreshToken");
    await prefs.remove("user");

    notifyListeners();
  }

  /// --- Chargement du user depuis le stockage local ---
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString("token");
    final storedRefreshToken = prefs.getString("refreshToken");
    final storedUser = prefs.getString("user");

    if (storedToken != null && storedUser != null) {
      token = storedToken;
      refreshToken = storedRefreshToken;
      user = jsonDecode(storedUser);
      notifyListeners();
    }
  }

  bool get isLoggedIn => token != null && user != null;

  /// --- Ajout d'une enchère liée à l'utilisateur ---
  void addUserAuction(String auctionId) {
    if (user != null) {
      user!['myAuctions'] ??= [];
      user!['myAuctions'].add(auctionId);
      _saveUserToStorage();
      notifyListeners();
    }
  }

  /// --- Ajout d'une offre liée à l'utilisateur ---
  void addUserOffer(String offerId) {
    if (user != null) {
      user!['myOffers'] ??= [];
      user!['myOffers'].add(offerId);
      _saveUserToStorage();
      notifyListeners();
    }
  }

  Map<String, dynamic>? get currentUser => user;

  /// --- Mise à jour du pseudo ---
  Future<void> updatePseudo(String newPseudo) async {
    if (user != null && token != null) {
      try {
        final response = await AuthService.updatePseudo(
          token: token!,
          newPseudo: newPseudo,
        );

        if (response['user'] != null) {
          user = response['user'];
          await _saveUserToStorage();
          notifyListeners();
          debugPrint("✅ Pseudo mis à jour : $newPseudo");
        } else {
          throw Exception("Réponse invalide du serveur");
        }
      } catch (e) {
        debugPrint("❌ Erreur updatePseudo: $e");
        final msg = e.toString().contains('déjà utilisé')
            ? 'Ce pseudo est déjà utilisé'
            : 'Erreur lors de la mise à jour du pseudo';
        throw Exception(msg);
      }
    } else {
      throw Exception('Utilisateur non connecté');
    }
  }

  /// ✅ --- Mise à jour du mot de passe (avec ancien mot de passe) ---
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (token != null) {
      try {
        await AuthService.updatePassword(
          token: token!,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        debugPrint("✅ Mot de passe mis à jour avec succès");
      } catch (e) {
        debugPrint("❌ Erreur lors de la mise à jour du mot de passe : $e");
        rethrow;
      }
    } else {
      throw Exception('Utilisateur non connecté');
    }
  }

  Future<void> _saveUserToStorage() async {
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", jsonEncode(user));
    }
  }

  String? get authorizationToken => token;

  /// --- Connexion via Google (stub pour garder la compatibilité UI) ---
  Future<void> loginWithGoogle() async {
    try {
      final data = await AuthService.loginWithGoogle(); // activera plus tard
      token = data["accessToken"];
      refreshToken = data["refreshToken"];
      user = data["user"];

      final prefs = await SharedPreferences.getInstance();
      if (token != null) await prefs.setString("token", token!);
      if (refreshToken != null)
        await prefs.setString("refreshToken", refreshToken!);
      if (user != null) await prefs.setString("user", jsonEncode(user));

      notifyListeners();
    } catch (e) {
      // Pour l’instant, on remonte l’erreur (bouton Google désactivé côté UI ou try/catch côté écran)
      rethrow;
    }
  }

  /// --- Inscription ---
  Future<void> registerUser({
    required String pseudo,
    required String email,
    required String password,
  }) async {
    try {
      final data = await AuthService.register(pseudo, email, password);
      token = data["accessToken"];
      refreshToken = data["refreshToken"];
      user = data["user"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);
      await prefs.setString("refreshToken", refreshToken!);
      await prefs.setString("user", jsonEncode(user));

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur inscription : $e");
      rethrow;
    }
  }
}
