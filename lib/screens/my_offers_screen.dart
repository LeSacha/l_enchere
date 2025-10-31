import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/auction_provider.dart';
import '../screens/auction-detail_screen.dart';
import '../widgets/custom_navbar.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final allAuctions = Provider.of<AuctionProvider>(context).auctions;
    final currency = NumberFormat.simpleCurrency(locale: 'fr_FR');

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mes offres")),
        body: const Center(child: Text("Veuillez vous connecter")),
        bottomNavigationBar: const CustomNavBar(),
      );
    }

    // Récupération sûre des IDs d’enchères sur lesquelles l’utilisateur a fait des offres
    final myOffersIds = (user["myOffers"] as List?) ?? [];

    // Filtrer les enchères correspondantes
    final myOfferAuctionList = allAuctions
        .where((a) => myOffersIds.contains(a.id))
        .toList();

    // Récupération du pseudo (ou fallback "Anonyme")
    final pseudo = user["pseudo"] ?? "Anonyme";

    return Scaffold(
      appBar: AppBar(title: const Text("Mes offres")),
      body: myOfferAuctionList.isEmpty
          ? const Center(child: Text("Aucune offre effectuée"))
          : ListView.builder(
              itemCount: myOfferAuctionList.length,
              itemBuilder: (context, i) {
                final a = myOfferAuctionList[i];

                // On cherche la dernière offre faite par l’utilisateur sur cette enchère
                final myBids = a.bids.where((b) => b.bidder == pseudo).toList();
                final myLastBid = myBids.isNotEmpty
                    ? myBids.first.amount
                    : null;

                return ListTile(
                  leading: a.imageUrls.isNotEmpty
                      ? Image.network(
                          a.imageUrls.first,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.local_offer, size: 40),
                  title: Text(a.title),
                  subtitle: Text(
                    myLastBid != null
                        ? 'Votre offre : ${currency.format(myLastBid)}'
                        : 'Vous avez fait une offre',
                  ),
                  trailing: Text(currency.format(a.currentPrice)),
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
