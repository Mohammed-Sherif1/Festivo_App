import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/features/owner/domain/owner_models.dart';
import 'package:festivo/features/owner/state/owner_store.dart';
import 'package:festivo/features/owner/theme/owner_colors.dart';

class OwnerEditVenueScreen extends ConsumerStatefulWidget {
  final OwnerVenue venue;

  const OwnerEditVenueScreen({super.key, required this.venue});

  @override
  ConsumerState<OwnerEditVenueScreen> createState() => _OwnerEditVenueScreenState();
}

class _OwnerEditVenueScreenState extends ConsumerState<OwnerEditVenueScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _capacityCtrl;
  late String _category;

  static const _categories = ['Wedding', 'Party', 'Corporate', 'Birthday'];

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    _nameCtrl = TextEditingController(text: v.name);
    _locationCtrl = TextEditingController(text: v.location);
    _priceCtrl = TextEditingController(text: v.price.toStringAsFixed(0));
    _capacityCtrl = TextEditingController(text: '${v.capacity}');
    _category = v.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.venue.copyWith(
      name: _nameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      category: _category,
      price: double.tryParse(_priceCtrl.text.trim()) ?? widget.venue.price,
      capacity: int.tryParse(_capacityCtrl.text.trim()) ?? widget.venue.capacity,
    );
    ref.read(ownerStoreProvider.notifier).updateVenue(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Venue'),
        backgroundColor: OwnerColors.pink,
        foregroundColor: Colors.white,
      ),
      backgroundColor: OwnerColors.pinkBg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', filled: true)),
          TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location', filled: true)),
          TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price', filled: true)),
          TextField(controller: _capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity', filled: true)),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: OwnerColors.pink, foregroundColor: Colors.white),
            onPressed: _save,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
