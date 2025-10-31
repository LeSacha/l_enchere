import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/auction.dart';
import '../providers/auction_provider.dart';
import '../providers/user_provider.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  DecimalTextInputFormatter({required this.decimalRange})
    : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^[0-9.,]+$').hasMatch(text)) return oldValue;
    if (text.contains('.') && text.contains(',')) return oldValue;

    String sep = text.contains('.') ? '.' : (text.contains(',') ? ',' : '');
    if (sep.isNotEmpty) {
      final parts = text.split(sep);
      if (parts.length > 2) return oldValue;
      if (decimalRange > 0 &&
          parts.length == 2 &&
          parts[1].length > decimalRange)
        return oldValue;
    }
    return newValue;
  }
}

class CreateAuctionScreen extends StatefulWidget {
  static const routeName = '/create';

  const CreateAuctionScreen({Key? key}) : super(key: key);

  @override
  State<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int _hours = 24;

  final List<String> _categories = [
    "Toutes",
    "Électronique",
    "Maison",
    "Mode",
    "Loisirs",
    "Autre",
  ];
  String? _selectedCategory;

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMultipleImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      imageQuality: 80,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une catégorie")),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    final id = const Uuid().v4();
    final starting =
        double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final end = DateTime.now().add(Duration(hours: _hours));

    final creatorName = currentUser != null
        ? (currentUser["pseudo"] ?? currentUser["email"] ?? "Utilisateur")
        : "Anonyme";

    final a = Auction(
      id: id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrls: _selectedImages.map((f) => f.path).toList(),
      endTime: end,
      startingPrice: starting,
      creator: creatorName,
      category: _selectedCategory!,
    );

    // Ajout local dans la liste
    Provider.of<AuctionProvider>(context, listen: false).addAuction(a);

    // Stockage de l'enchère côté utilisateur (ajoute la méthode dans UserProvider)
    if (currentUser != null) {
      userProvider.addUserAuction(id);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Créer une enchère')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (user == null)
                const Text(
                  "⚠ Vous n'êtes pas connecté, l'annonce sera publiée en tant qu'invité.",
                  style: TextStyle(color: Colors.red),
                ),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Titre requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Catégorie"),
                value: _selectedCategory,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedCategory = val);
                },
                validator: (val) =>
                    val == null ? 'Sélectionnez une catégorie' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prix de départ',
                  suffixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  DecimalTextInputFormatter(decimalRange: 2),
                ],
                validator: (v) {
                  final val = v?.replaceAll(',', '.');
                  if (val == null || val.isEmpty) return 'Prix requis';
                  if (double.tryParse(val) == null) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ✅ Boutons ajout photo
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickMultipleImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galerie"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Appareil photo"),
                  ),
                ],
              ),

              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 16),

                // ✅ CADRE D'APERÇU - Simulation de la carte
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aperçu dans la liste',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comment votre annonce apparaîtra :',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 12),

                      // ✅ Simulation de la carte d'enchère
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // ✅ Partie image - Cadre fixe comme dans l'app
                            Container(
                              width: 120,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                                child: Image.file(
                                  _selectedImages[0], // Première image = aperçu principal
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),

                            // ✅ Partie texte - Simulation du contenu
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _titleCtrl.text.isEmpty
                                          ? 'Titre de l\'enchère'
                                          : _titleCtrl.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    Text(
                                      _selectedCategory ?? 'Catégorie',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _priceCtrl.text.isEmpty
                                              ? '0,00 €'
                                              : '${_priceCtrl.text} €',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${_hours}h',
                                            style: TextStyle(
                                              color: Colors.orange[800],
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      // ✅ Instructions pour l'utilisateur
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'La première photo sera utilisée comme image principale dans les aperçus',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ GALLERIE DES IMAGES AVEC REORDER
                const Text(
                  'Vos photos (glissez pour réorganiser)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _selectedImages.removeAt(oldIndex);
                        _selectedImages.insert(newIndex, item);
                      });
                    },
                    children: List.generate(_selectedImages.length, (index) {
                      return Container(
                        key: Key('$index'),
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: index == 0 ? Colors.blue : Colors.grey[300]!,
                            width: index == 0 ? 3 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                _selectedImages[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Badge "Principale" pour la première image
                            if (index == 0)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Principale',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                            // Numéro de l'image
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Bouton de suppression
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  const Text('Durée :'),
                  Expanded(
                    child: Slider(
                      value: _hours.toDouble(),
                      min: 1,
                      max: 48,
                      divisions: 47,
                      label: '$_hours h',
                      onChanged: (v) => setState(() => _hours = v.round()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Créer l\'enchère'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
