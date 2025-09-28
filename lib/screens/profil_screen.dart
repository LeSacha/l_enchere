import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_navbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon profil")),
      body: user == null
          ? const Center(
              child: Text("Vous n'êtes pas connecté"),
            )
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
                  Text(user.pseudo,
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: Text("Mes annonces (${user.myAuctions.length})"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_offer),
                    title: Text("Mes offres (${user.myOffers.length})"),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      userProvider.logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),
                  )
                ],
              ),
            ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
