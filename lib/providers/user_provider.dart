import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Nouvelle méthode login qui crée un User à partir de pseudo + email
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
      _currentUser!.pseudo = newPseudo;
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
}
