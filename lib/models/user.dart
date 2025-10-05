class User {
  String id;
  String pseudo;
  String email;
  String? password; // 🔑 on ajoute le mot de passe
  String? avatarUrl;
  List<String> myAuctions;
  List<String> myOffers;

  User({
    required this.id,
    required this.pseudo,
    required this.email,
    this.password,
    this.avatarUrl,
    List<String>? myAuctions,
    List<String>? myOffers,
  })  : myAuctions = myAuctions ?? [],
        myOffers = myOffers ?? [];

  User copyWith({
    String? pseudo,
    String? email,
    String? password,
    String? avatarUrl,
    List<String>? myAuctions,
    List<String>? myOffers,
  }) {
    return User(
      id: id,
      pseudo: pseudo ?? this.pseudo,
      email: email ?? this.email,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      myAuctions: myAuctions ?? this.myAuctions,
      myOffers: myOffers ?? this.myOffers,
    );
  }
}
