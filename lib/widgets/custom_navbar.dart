import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:l_enchere/screens/my_offers_screen.dart';
import 'package:l_enchere/screens/profil_screen.dart';
import '../screens/home_screen.dart';
import '../screens/my_auctions_screen.dart';
import '../providers/nav_provider.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({Key? key}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    final navProvider = Provider.of<NavProvider>(context, listen: false);
    navProvider.setIndex(index);

    // 🔄 Navigation en fonction de l'onglet choisi
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyAuctionsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyOffersScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = Provider.of<NavProvider>(context).currentIndex;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _onItemTapped(context, i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Mes annonces'),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Mes offres',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
