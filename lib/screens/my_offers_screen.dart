import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_navbar.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Mes offres")),
      body: user == null
          ? const Center(child: Text("Veuillez vous connecter"))
          : user.myOffers.isEmpty
          ? const Center(child: Text("Aucune offre effectuée"))
          : ListView.builder(
              itemCount: user.myOffers.length,
              itemBuilder: (context, i) {
                final offerId = user.myOffers[i];
                return ListTile(
                  leading: const Icon(Icons.local_offer),
                  title: Text("Offre #${offerId.substring(0, 6)}"),
                  subtitle: const Text("En attente de résultat..."),
                );
              },
            ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
