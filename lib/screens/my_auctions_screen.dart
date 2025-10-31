import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auction_provider.dart';
import '../widgets/auction_card.dart';
import '../screens/auction-detail_screen.dart';
import '../widgets/custom_navbar.dart';

class MyAuctionsScreen extends StatelessWidget {
  const MyAuctionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final allAuctions = Provider.of<AuctionProvider>(context).auctions;

    // Si pas d'objet utilisateur ne contient pas "myAuctions", on gère le cas vide
    final myAuctionIds = (user?["myAuctions"] as List?) ?? [];

    final myAuctions = allAuctions
        .where((a) => myAuctionIds.contains(a.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Mes annonces")),
      body: myAuctions.isEmpty
          ? const Center(child: Text("Vous n'avez pas encore créé d'annonces"))
          : ListView.builder(
              itemCount: myAuctions.length,
              itemBuilder: (context, i) {
                final a = myAuctions[i];
                return AuctionCard(
                  auction: a,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AuctionDetailScreen(auction: a),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
