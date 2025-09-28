import 'package:flutter/foundation.dart';

class Bid {
  final String bidder;
  final double amount;
  final DateTime time;

  Bid({required this.bidder, required this.amount, DateTime? time}) : time = time ?? DateTime.now();
}

class Auction {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime endTime;
  final double startingPrice;
  double currentPrice;
  final List<Bid> bids;

  Auction({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.endTime,
    required this.startingPrice,
    double? currentPrice,
    List<Bid>? bids,
  })  : currentPrice = currentPrice ?? startingPrice,
        bids = bids ?? [];

  bool get isExpired => DateTime.now().isAfter(endTime);

  Duration get remaining => endTime.difference(DateTime.now());
}