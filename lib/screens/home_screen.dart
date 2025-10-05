import 'dart:io';
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
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedCategory = "Toutes";

  // 🆕 Tri
  String _primarySort = "temps"; // "prix" ou "temps"
  bool _sortAsc = true;

  final List<String> _categories = const [
    "Toutes",
    "Électronique",
    "Maison",
    "Mode",
    "Loisirs",
    "Autre",
  ];

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
      body: Column(
        children: [
          // 🔎 Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Rechercher une annonce...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),

          // 🏷️ Catégorie + Tri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Dropdown Catégorie
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    decoration: const InputDecoration(
                      labelText: "Catégorie",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 🆕 Bouton tri prix
                Column(
                  children: [
                    const Text("Prix"),
                    IconButton(
                      icon: Icon(
                        _primarySort == "prix"
                            ? (_sortAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                            : Icons.swap_vert, // neutre si pas actif
                      ),
                      onPressed: () {
                        setState(() {
                          if (_primarySort == "prix") {
                            _sortAsc = !_sortAsc; // on inverse
                          } else {
                            _primarySort = "prix";
                            _sortAsc = true; // reset en ascendant
                          }
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                // 🆕 Bouton tri temps
                Column(
                  children: [
                    const Text("Temps"),
                    IconButton(
                      icon: Icon(
                        _primarySort == "temps"
                            ? (_sortAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                            : Icons.swap_vert,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_primarySort == "temps") {
                            _sortAsc = !_sortAsc;
                          } else {
                            _primarySort = "temps";
                            _sortAsc = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 🏠 Liste des annonces
          Expanded(
            child: Consumer<AuctionProvider>(
              builder: (context, prov, _) {
                var auctions = List.of(prov.auctions);

                // 🔎 Filtre recherche
                if (_searchCtrl.text.isNotEmpty) {
                  auctions = auctions
                      .where(
                        (a) => a.title.toLowerCase().contains(
                          _searchCtrl.text.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                // 🏷️ Filtre catégorie
                if (_selectedCategory != null &&
                    _selectedCategory != "Toutes") {
                  auctions = auctions
                      .where(
                        (a) =>
                            (a.category.isEmpty ? "Autre" : a.category) ==
                            _selectedCategory,
                      )
                      .toList();
                }

                // ↕️ Tri avec critère secondaire
                auctions.sort((a, b) {
                  int cmp;
                  if (_primarySort == "prix") {
                    cmp = _sortAsc
                        ? a.currentPrice.compareTo(b.currentPrice)
                        : b.currentPrice.compareTo(a.currentPrice);
                    if (cmp == 0) {
                      // critère secondaire = temps
                      cmp = a.remaining.compareTo(b.remaining);
                    }
                  } else {
                    cmp = _sortAsc
                        ? a.remaining.compareTo(b.remaining)
                        : b.remaining.compareTo(a.remaining);
                    if (cmp == 0) {
                      // critère secondaire = prix
                      cmp = a.currentPrice.compareTo(b.currentPrice);
                    }
                  }
                  return cmp;
                });

                if (auctions.isEmpty) {
                  return const Center(
                    child: Text('Aucune enchère ne correspond aux filtres'),
                  );
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
          ),
        ],
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
