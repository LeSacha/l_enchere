class User {
  final String id;
  String pseudo;
  String email;
  String? avatarUrl;
  List<String> myAuctions; // ids des annonces créées
  List<String> myOffers;   // ids des offres faites

  User({
    required this.id,
    required this.pseudo,
    required this.email,
    this.avatarUrl,
    List<String>? myAuctions,
    List<String>? myOffers,
  })  : myAuctions = myAuctions ?? [],
        myOffers = myOffers ?? [];

  // Exemple de méthode pour convertir en JSON si plus tard API
  Map<String, dynamic> toJson() => {
        'id': id,
        'pseudo': pseudo,
        'email': email,
        'avatarUrl': avatarUrl,
        'myAuctions': myAuctions,
        'myOffers': myOffers,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        pseudo: json['pseudo'],
        email: json['email'],
        avatarUrl: json['avatarUrl'],
        myAuctions: List<String>.from(json['myAuctions'] ?? []),
        myOffers: List<String>.from(json['myOffers'] ?? []),
      );
}
