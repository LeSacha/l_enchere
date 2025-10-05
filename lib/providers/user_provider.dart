import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void login(String pseudo, String email) {
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pseudo: pseudo,
      email: email,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updatePseudo(String newPseudo) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(pseudo: newPseudo);
      notifyListeners();
    }
  }

  void updatePassword(String newPassword) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(password: newPassword);
      notifyListeners();
    }
  }

  void addAuction(String auctionId) {
    _currentUser?.myAuctions.add(auctionId);
    notifyListeners();
  }

  void addOffer(String offerId) {
    _currentUser?.myOffers.add(offerId);
    notifyListeners();
  }

  void loginWithEmail({required String email, required String password}) {
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      password: password,
      pseudo: email.split('@')[0],
      myAuctions: [],
      myOffers: [],
    );
    notifyListeners();
  }

  void loginWithGoogle() {
    _currentUser = User(
      id: "google_${DateTime.now().millisecondsSinceEpoch}",
      email: "user@gmail.com",
      pseudo: "GoogleUser",
      myAuctions: [],
      myOffers: [],
    );
    notifyListeners();
  }
}
