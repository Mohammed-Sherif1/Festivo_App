import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/features/owner/domain/owner_models.dart';
import 'package:festivo/features/owner/state/owner_store.dart';
import 'package:festivo/features/owner/theme/owner_colors.dart';

class OwnerAddVenueScreen extends ConsumerStatefulWidget {
  final VoidCallback? onDone;

  const OwnerAddVenueScreen({super.key, this.onDone});

  @override
  ConsumerState<OwnerAddVenueScreen> createState() => _OwnerAddVenueScreenState();
}

class _OwnerAddVenueScreenState extends ConsumerState<OwnerAddVenueScreen> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String _category = 'Wedding';

  static const _categories = ['Wedding', 'Party', 'Corporate', 'Birthday'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final capacity = int.tryParse(_capacityCtrl.text.trim()) ?? 0;
    if (name.isEmpty || location.isEmpty || price <= 0 || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    final store = ref.read(ownerStoreProvider);
    final nextId = store.venues.isEmpty
        ? 1
        : store.venues.map((v) => v.id).reduce((a, b) => a > b ? a : b) + 1;

    ref.read(ownerStoreProvider.notifier).addVenue(
          OwnerVenue(
            id: nextId,
            name: name,
            location: location,
            category: _category,
            price: price,
            capacity: capacity,
          ),
        );

    _nameCtrl.clear();
    _locationCtrl.clear();
    _priceCtrl.clear();
    _capacityCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venue added successfully!')),
    );
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.pinkBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: OwnerColors.grad),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
            child: const Text(
              'Add Venue',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _field(_nameCtrl, 'Venue Name'),
                _field(_locationCtrl, 'Location'),
                _field(_priceCtrl, 'Price (EGP)', keyboard: TextInputType.number),
                _field(_capacityCtrl, 'Capacity', keyboard: TextInputType.number),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: OwnerColors.white,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OwnerColors.pink,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submit,
                    child: const Text('Save Venue', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: OwnerColors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
