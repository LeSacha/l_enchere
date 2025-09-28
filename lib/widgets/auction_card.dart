import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/auction.dart';
import '../utils/time_utils.dart';

class AuctionCard extends StatelessWidget {
  final Auction auction;
  final VoidCallback onTap;

  const AuctionCard({Key? key, required this.auction, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.simpleCurrency(locale: 'fr_FR');
    final remaining = auction.remaining;
    final isEndingSoon = !auction.isExpired && remaining.inMinutes <= 10;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // léger glow si bientôt fini
            boxShadow: isEndingSoon
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.08),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Hero(
                tag: auction.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    auction.imageUrl ??
                        'https://picsum.photos/seed/${auction.id}/200/140',
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      auction.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          priceFmt.format(auction.currentPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: auction.isExpired ? 0.6 : 1.0,
                          child: Text(
                            formatRemaining(auction.remaining),
                            style: TextStyle(
                              color: auction.isExpired
                                  ? Colors.grey
                                  : (isEndingSoon
                                        ? Colors.red
                                        : Colors.black87),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
