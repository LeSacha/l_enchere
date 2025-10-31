import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/nav_provider.dart';
import '../screens/my_auctions_screen.dart';
import '../screens/my_offers_screen.dart';
import '../widgets/custom_navbar.dart';
import 'login_screen.dart'; // Importez votre écran de login

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _editPseudo(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    final TextEditingController pseudoCtrl = TextEditingController(
      text: user?['pseudo'] ?? "",
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Modifier le pseudo"),
        content: TextField(
          controller: pseudoCtrl,
          decoration: const InputDecoration(
            labelText: "Nouveau pseudo",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pseudoCtrl.text.trim().isNotEmpty) {
                try {
                  await userProvider.updatePseudo(pseudoCtrl.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Pseudo mis à jour avec succès"),
                    ),
                  );
                  Navigator.pop(ctx); // Ferme la fenêtre après succès
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erreur: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Ne pas fermer la fenêtre en cas d'erreur
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Le pseudo ne peut pas être vide"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _editPassword(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final TextEditingController oldPassCtrl = TextEditingController();
    final TextEditingController newPassCtrl = TextEditingController();
    final TextEditingController confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Changer le mot de passe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Ancien mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmer le mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPass = oldPassCtrl.text.trim();
              final newPass = newPassCtrl.text.trim();
              final confirmPass = confirmCtrl.text.trim();

              if (newPass.isEmpty || oldPass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Veuillez remplir tous les champs"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Les mots de passe ne correspondent pas"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await userProvider.updatePassword(oldPass, newPass);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Mot de passe mis à jour avec succès"),
                  ),
                );
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erreur : ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Changer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final navProvider = Provider.of<NavProvider>(context, listen: false);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon profil")),
      body: user == null
          ? const Center(child: Text("Vous n'êtes pas connecté"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user['avatarUrl'] != null
                        ? NetworkImage(user['avatarUrl']!)
                        : null,
                    child: user['avatarUrl'] == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['pseudo'] ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user['email'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () => _editPseudo(context),
                    icon: const Icon(Icons.edit),
                    label: const Text("Modifier le pseudo"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _editPassword(context),
                    icon: const Icon(Icons.lock),
                    label: const Text("Changer le mot de passe"),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: Text(
                      "Mes annonces (${(user['myAuctions'] as List?)?.length ?? 0})",
                    ),
                    onTap: () {
                      navProvider.setIndex(1);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MyAuctionsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_offer),
                    title: Text(
                      "Mes offres (${(user['myOffers'] as List?)?.length ?? 0})",
                    ),
                    onTap: () {
                      navProvider.setIndex(2);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MyOffersScreen(),
                        ),
                      );
                    },
                  ),

                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await userProvider.logout();
                        // Navigation directe vers l'écran de login
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Erreur lors de la déconnexion: ${e.toString()}",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
