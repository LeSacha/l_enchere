import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/auction.dart';
import '../providers/auction_provider.dart';
import '../utils/time_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.simpleCurrency(locale: 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Détail')),
      body: Consumer<AuctionProvider>(
        builder: (context, prov, _) {
          // récupère l'objet récent (référence)
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
                  child: Image.network(
                    a.imageUrl ?? 'https://picsum.photos/seed/${a.id}/800/400',
                    height: 220,
                    fit: BoxFit.cover,
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
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ton pseudo'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bidCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText:
                        'Montant (EUR) — min: ${priceFmt.format(a.currentPrice + 0.01)}',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(_bidCtrl.text.replaceAll(',', '.')) ??
                        -1;
                    final pseudo = _nameCtrl.text.trim().isEmpty
                        ? 'Anonyme'
                        : _nameCtrl.text.trim();
                    final result = Provider.of<AuctionProvider>(
                      context,
                      listen: false,
                    ).placeBid(auctionId: a.id, amount: amount, bidder: pseudo);
                    if (result == 'ok') {
                      _bidCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enchère enregistrée')),
                      );
                    } else {
                      String msg = 'Erreur';
                      if (result == 'prix_trop_bas')
                        msg = 'Le montant doit être supérieur au prix courant';
                      if (result == 'enchere_terminee')
                        msg = 'Enchère déjà terminée';
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    }
                  },
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
                    title: Text(
                      '${b.bidder} — ${NumberFormat.simpleCurrency(locale: 'fr_FR').format(b.amount)}',
                    ),
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
