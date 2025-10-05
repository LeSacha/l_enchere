import 'package:flutter/foundation.dart';

class Bid {
  final String bidder;
  final double amount;
  final DateTime time;

  Bid({
    required this.bidder,
    required this.amount,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class Auction {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls; // 🔥 plusieurs images possibles
  final DateTime endTime;
  final double startingPrice;
  double currentPrice;
  final List<Bid> bids;
  final String creator;
  final String category;

  Auction({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrls = const [], // par défaut vide
    required this.endTime,
    required this.startingPrice,
    this.creator = 'Anonyme',
    this.category = 'Autre',
    double? currentPrice,
    List<Bid>? bids,
  })  : currentPrice = currentPrice ?? startingPrice,
        bids = bids ?? [];

  bool get isExpired => DateTime.now().isAfter(endTime);

  Duration get remaining => endTime.difference(DateTime.now());
}
