import 'dart:convert';
import 'package:http/http.dart' as http;

class BidService {
  static const String baseUrl = "http://10.0.2.2:3000"; // adapte à ton IP

  static Future<void> addOffer({
    required String auctionId,
    required double amount,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bids"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "auctionId": auctionId,
        "amount": amount,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Échec de l'ajout de l'offre : ${response.body}");
    }
  }
}
