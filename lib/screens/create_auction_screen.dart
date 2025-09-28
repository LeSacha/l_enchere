import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _imgCtrl = TextEditingController();
  int _hours = 24;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = const Uuid().v4();
    final starting =
        double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final end = DateTime.now().add(Duration(hours: _hours));

    final newAuction = Auction(
      id: id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl: _imgCtrl.text.trim().isEmpty ? null : _imgCtrl.text.trim(),
      endTime: end,
      startingPrice: starting,
    );

    final auctionProvider = Provider.of<AuctionProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    auctionProvider.addAuction(newAuction);
    userProvider.addAuction(newAuction.id);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer une enchère')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prix de départ',
                  suffixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
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
              TextFormField(
                controller: _imgCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image (optionnel)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Durée :'),
                  const SizedBox(width: 12),
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    'Créer l\'enchère',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
