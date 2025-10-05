import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auction_provider.dart';
import '../screens/auction-detail_screen.dart';
import '../widgets/custom_navbar.dart';
import 'package:intl/intl.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    final allAuctions = Provider.of<AuctionProvider>(context).auctions;
    final currency = NumberFormat.simpleCurrency(locale: 'fr_FR');

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mes offres")),
        body: const Center(child: Text("Veuillez vous connecter")),
        bottomNavigationBar: const CustomNavBar(),
      );
    }

    final myOfferAuctionList = allAuctions
        .where((a) => user.myOffers.contains(a.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Mes offres")),
      body: myOfferAuctionList.isEmpty
          ? const Center(child: Text("Aucune offre effectuée"))
          : ListView.builder(
              itemCount: myOfferAuctionList.length,
              itemBuilder: (context, i) {
                final a = myOfferAuctionList[i];
                // Cherche la (ou les) offres du user sur cette enchère — on prend la première trouvée (la plus récente si la liste de bids est inversée)
                final myBids = a.bids
                    .where((b) => b.bidder == user.pseudo)
                    .toList();
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
                        ? 'Votre offre: ${currency.format(myLastBid)}'
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
