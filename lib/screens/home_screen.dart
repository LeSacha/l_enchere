import 'package:flutter/material.dart';
import 'package:l_enchere/screens/auction-detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auction_provider.dart';
import '../widgets/auction_card.dart';
import 'create_auction_screen.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/notification_bell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _notificationCount =
      2; // exemple : récupère ça depuis un provider plus tard

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AuctionProvider>(context, listen: false);
    if (provider.auctions.isEmpty) provider.loadSampleAuctions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("L'Enchère"),
        actions: const [NotificationBell()],
      ),
      body: Consumer<AuctionProvider>(
        builder: (context, prov, _) {
          final auctions = prov.auctions;
          if (auctions.isEmpty) {
            return const Center(child: Text('Aucune enchère pour le moment'));
          }
          return ListView.builder(
            itemCount: auctions.length,
            itemBuilder: (context, i) {
              final a = auctions[i];
              return AuctionCard(
                auction: a,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AuctionDetailScreen(auction: a),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Créer'),
        icon: const Icon(Icons.add),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateAuctionScreen())),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
