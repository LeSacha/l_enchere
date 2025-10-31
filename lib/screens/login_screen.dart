import 'package:flutter/material.dart';
import 'package:l_enchere/screens/register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false).loginWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Échec de la connexion")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _googleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false).loginWithGoogle();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de la connexion Google")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Google : ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ évite le dépassement au clavier
      appBar: AppBar(title: const Text("Connexion")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
              ), // petit espace pour centrer visuellement
              const Text(
                "Bienvenue sur L'Enchère",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email requis';
                  if (!v.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Mot de passe requis';
                  if (v.length < 6) return 'Minimum 6 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Se connecter"),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              if (!_isLoading)
                ElevatedButton.icon(
                  onPressed: _googleLogin,
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                    height: 20,
                    width: 20,
                  ),
                  label: const Text("Connexion avec Google"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Créer un compte"),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
