import 'package:flutter/material.dart';
import 'package:l_enchere/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auction_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LEnchereApp());
}

class LEnchereApp extends StatelessWidget {
  const LEnchereApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuctionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "L'Enchère",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
              useMaterial3: true,
            ),
            home: userProvider.currentUser == null
                ? const LoginScreen()
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}


