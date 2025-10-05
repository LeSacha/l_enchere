import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/nav_provider.dart';
import '../screens/my_auctions_screen.dart';
import '../screens/my_offers_screen.dart';
import '../widgets/custom_navbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _editPseudo(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final TextEditingController pseudoCtrl = TextEditingController(
      text: userProvider.currentUser?.pseudo ?? "",
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
            onPressed: () {
              if (pseudoCtrl.text.trim().isNotEmpty) {
                userProvider.updatePseudo(pseudoCtrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _editPassword(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final TextEditingController passCtrl = TextEditingController();
    final TextEditingController confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Changer le mot de passe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passCtrl,
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
            onPressed: () {
              if (passCtrl.text == confirmCtrl.text &&
                  passCtrl.text.trim().isNotEmpty) {
                userProvider.updatePassword(passCtrl.text.trim());
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Les mots de passe ne correspondent pas"),
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
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.pseudo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
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
                    title: Text("Mes annonces (${user.myAuctions.length})"),
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
                    title: Text("Mes offres (${user.myOffers.length})"),
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
                    onPressed: () => userProvider.logout(),
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
