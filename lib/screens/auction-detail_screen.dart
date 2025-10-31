import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l_enchere/widgets/full_screen_gallery.dart';
import 'package:provider/provider.dart';
import '../models/auction.dart';
import '../providers/auction_provider.dart';
import '../providers/user_provider.dart';
import '../utils/time_utils.dart';
import '../services/bid_service.dart';
import 'dart:io';

class AuctionDetailScreen extends StatefulWidget {
  static const routeName = '/detail';
  final Auction auction;

  const AuctionDetailScreen({Key? key, required this.auction})
    : super(key: key);

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final _bidCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'Anonyme');

  @override
  void dispose() {
    _bidCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeBid(Auction a) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    final token = userProvider.token;

    if (a.isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cette enchère est terminée')),
      );
      return;
    }

    final amount = double.tryParse(_bidCtrl.text.replaceAll(',', '.')) ?? -1;
    if (amount <= a.currentPrice) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Montant trop bas')));
      return;
    }

    try {
      // Utilise le pseudo du compte connecté ou le nom saisi
      final bidderName = currentUser != null
          ? (currentUser["pseudo"] ?? currentUser["email"] ?? "Utilisateur")
          : _nameCtrl.text;

      await BidService.addOffer(
        auctionId: a.id.toString(),
        amount: amount,
        token: token ?? '',
      );

      // Ajoute l'offre localement (optionnel selon backend)
      Provider.of<AuctionProvider>(context, listen: false).refreshAuctions();

      _bidCtrl.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Offre placée par $bidderName !')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.simpleCurrency(locale: 'fr_FR');
    final currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail')),
      body: Consumer<AuctionProvider>(
        builder: (context, prov, _) {
          final a = prov.auctions.firstWhere(
            (e) => e.id == widget.auction.id,
            orElse: () => widget.auction,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Hero(
                tag: a.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220,
                    child: PageView.builder(
                      itemCount: a.imageUrls.isNotEmpty
                          ? a.imageUrls.length
                          : 1,
                      itemBuilder: (context, index) {
                        final url = a.imageUrls.isNotEmpty
                            ? a.imageUrls[index]
                            : null;
                        final imageWidget = url != null
                            ? (url.startsWith('http')
                                  ? Image.network(url, fit: BoxFit.cover)
                                  : Image.file(File(url), fit: BoxFit.cover))
                            : Image.network(
                                'https://picsum.photos/seed/${a.id}/800/400',
                                fit: BoxFit.cover,
                              );

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenGallery(
                                  images: a.imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: imageWidget,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(a.description),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    priceFmt.format(a.currentPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatRemaining(a.remaining),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (a.isExpired)
                const Center(
                  child: Text(
                    'Enchère terminée',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (!a.isExpired) ...[
                if (currentUser == null)
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Ton pseudo'),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bidCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        'Montant (EUR) — min: ${priceFmt.format(a.currentPrice + 0.01)}',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _placeBid(a),
                  child: const Text('Enchérir'),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Historique des offres',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (a.bids.isEmpty)
                const Text('Aucune offre pour le moment')
              else
                ...a.bids.map(
                  (b) => ListTile(
                    dense: true,
                    title: Text('${b.bidder} — ${priceFmt.format(b.amount)}'),
                    subtitle: Text('${b.time}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
