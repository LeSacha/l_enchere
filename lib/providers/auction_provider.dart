import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/auction.dart';

class AuctionProvider extends ChangeNotifier {
  final List<Auction> _auctions = [];
  Timer? _ticker;

  AuctionProvider() {
    // Ticker pour mettre à jour les compte-à-rebours chaque seconde
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  List<Auction> get auctions => List.unmodifiable(_auctions);

  void loadSampleAuctions() {
    final now = DateTime.now();
    final u = const Uuid();
    _auctions.addAll([
      Auction(
        id: u.v4(),
        title: 'Vieux vélo vintage',
        description: 'Bon état — idéal pour balades urbaines',
        imageUrl: 'https://picsum.photos/seed/bike/800/600',
        endTime: now.add(const Duration(hours: 12)),
        startingPrice: 20.0,
      ),
      Auction(
        id: u.v4(),
        title: 'Lampe industrielle',
        description: 'Design rétro — ampoule fournie',
        imageUrl: 'https://picsum.photos/seed/lamp/800/600',
        endTime: now.add(const Duration(hours: 36)),
        startingPrice: 15.0,
      ),
    ]);
    notifyListeners();
  }

  void addAuction(Auction a) {
    _auctions.insert(0, a);
    notifyListeners();
  }

  String placeBid({
    required String auctionId,
    required double amount,
    required String bidder,
  }) {
    final idx = _auctions.indexWhere((a) => a.id == auctionId);
    if (idx == -1) return 'enchere_introuvable';
    final a = _auctions[idx];
    if (a.isExpired) return 'enchere_terminee';
    if (amount <= a.currentPrice) return 'prix_trop_bas';

    a.currentPrice = amount;
    a.bids.insert(0, Bid(bidder: bidder, amount: amount));
    notifyListeners();
    return 'ok';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
