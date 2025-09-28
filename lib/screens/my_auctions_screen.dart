import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auction_provider.dart';
import '../widgets/auction_card.dart';
import '../widgets/custom_navbar.dart';

class MyAuctionsScreen extends StatelessWidget {
  const MyAuctionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuctionProvider>(context);
    final myAuctions = provider.auctions.where((a) => a.id.startsWith("user-")).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Mes annonces")),
      body: myAuctions.isEmpty
          ? const Center(child: Text("Vous n'avez pas encore créé d'annonces"))
          : ListView.builder(
              itemCount: myAuctions.length,
              itemBuilder: (context, i) => AuctionCard(auction: myAuctions[i], onTap: () {  },),
            ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
