import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/app/providers/app_providers.dart';
import 'package:festivo/core/constants/app_colors.dart';
import 'package:festivo/features/customer/domain/customer_models.dart';
import 'package:festivo/features/customer/screens/payment_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Venue venue;

  const BookingScreen({super.key, required this.venue});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  String _selectedTime = '6:00 PM';
  int _guests = 50;
  String _selectedPkg = 'Standard';
  bool _isLoading = false;
  int _step = 0;

  static const _minGuests = 10;
  static const _maxGuests = 300;
  static const _times = [
    '10:00 AM', '12:00 PM', '2:00 PM',
    '4:00 PM', '6:00 PM', '8:00 PM',
  ];
  static const _packages = ['Standard', 'Premium', 'Luxury'];
  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  int get _pkgMultiplier =>
      _selectedPkg == 'Luxury' ? 2 : _selectedPkg == 'Premium' ? 1 : 0;

  int get _totalPrice =>
      widget.venue.price + (_pkgMultiplier * (widget.venue.price ~/ 2));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _changeGuests(int delta) {
    setState(() {
      _guests = (_guests + delta).clamp(_minGuests, _maxGuests);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Please select an event date.');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          venueName: widget.venue.name,
          totalAmount: _totalPrice,
          bookingDate: _selectedDate!,
          bookingTime: _selectedTime,
        ),
      ),
    );
  }

  int _daysInMonth(DateTime m) => DateTime(m.year, m.month + 1, 0).day;

  int _firstWeekday(DateTime m) => DateTime(m.year, m.month, 1).weekday % 7;

  bool _isSelectable(int day) {
    final d = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final today = DateTime.now();
    return d.isAfter(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(isDarkProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(dark),
      appBar: AppBar(
        backgroundColor: AppColors.bg(dark),
        elevation: 0,
        title: Text('Book ${widget.venue.name}', style: TextStyle(color: AppColors.textD(dark), fontSize: 16)),
        iconTheme: IconThemeData(color: AppColors.textD(dark)),
      ),
      body: Column(
        children: [
          _StepIndicator(step: _step, dark: dark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _step == 0
                  ? _buildStepOne(dark)
                  : _buildStepTwo(dark),
            ),
          ),
          _BottomBar(
            dark: dark,
            step: _step,
            total: _totalPrice,
            fmt: _fmt,
            loading: _isLoading,
            onBack: () => setState(() => _step = 0),
            onNext: () {
              if (_selectedDate == null) {
                _showError('Please select an event date.');
                return;
              }
              setState(() => _step = 1);
            },
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildStepOne(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
        const SizedBox(height: 12),
        _CalendarCard(
          dark: dark,
          focusedMonth: _focusedMonth,
          selectedDate: _selectedDate,
          weekdays: _weekdays,
          daysInMonth: _daysInMonth(_focusedMonth),
          firstWeekday: _firstWeekday(_focusedMonth),
          isSelectable: _isSelectable,
          onPrev: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
          }),
          onNext: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
          }),
          onSelectDay: (day) => setState(() {
            _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
          }),
        ),
        const SizedBox(height: 20),
        Text('Time Slot', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _times.map((t) {
            final sel = t == _selectedTime;
            return ChoiceChip(
              label: Text(t),
              selected: sel,
              onSelected: (_) => setState(() => _selectedTime = t),
              selectedColor: AppColors.accent(dark),
              labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textD(dark)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('Guests', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _changeGuests(-10),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_guests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
            IconButton(
              onPressed: () => _changeGuests(10),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Package', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
        const SizedBox(height: 10),
        ..._packages.map((p) {
          return RadioListTile<String>(
            title: Text(p, style: TextStyle(color: AppColors.textD(dark))),
            value: p,
            groupValue: _selectedPkg,
            activeColor: AppColors.accent(dark),
            onChanged: (v) => setState(() => _selectedPkg = v!),
          );
        }),
      ],
    );
  }

  Widget _buildStepTwo(bool dark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Details', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
          const SizedBox(height: 12),
          _field(_nameCtrl, 'Full Name', dark, required: true),
          _field(_phoneCtrl, 'Phone', dark, required: true),
          _field(_emailCtrl, 'Email', dark, required: true, email: true),
          _field(_notesCtrl, 'Notes (optional)', dark, maxLines: 3),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card(dark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(dark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summary', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
                const SizedBox(height: 8),
                Text('Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}', style: TextStyle(color: AppColors.textM(dark))),
                Text('Time: $_selectedTime', style: TextStyle(color: AppColors.textM(dark))),
                Text('Guests: $_guests', style: TextStyle(color: AppColors.textM(dark))),
                Text('Package: $_selectedPkg', style: TextStyle(color: AppColors.textM(dark))),
                const Divider(),
                Text(
                  'Total: ${_fmt(_totalPrice)} EGP',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    bool dark, {
    bool required = false,
    bool email = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.textD(dark)),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.input(dark),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) {
          if (!required) return null;
          if (v == null || v.trim().isEmpty) return '$label is required';
          if (email && !v.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final bool dark;

  const _StepIndicator({required this.step, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _dot(1, step >= 0, dark),
          Expanded(child: Container(height: 2, color: step >= 1 ? AppColors.accent(dark) : AppColors.border(dark))),
          _dot(2, step >= 1, dark),
        ],
      ),
    );
  }

  Widget _dot(int n, bool active, bool dark) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: active ? AppColors.accent(dark) : AppColors.border(dark),
      child: Text('$n', style: TextStyle(color: active ? Colors.white : AppColors.textM(dark), fontSize: 12)),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final bool dark;
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final List<String> weekdays;
  final int daysInMonth;
  final int firstWeekday;
  final bool Function(int day) isSelectable;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onSelectDay;

  const _CalendarCard({
    required this.dark,
    required this.focusedMonth,
    required this.selectedDate,
    required this.weekdays,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.isSelectable,
    required this.onPrev,
    required this.onNext,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel =
        '${_months[focusedMonth.month - 1]} ${focusedMonth.year}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.shadow(dark)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
              Text(monthLabel, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textD(dark))),
              IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          Row(
            children: weekdays
                .map((w) => Expanded(
                      child: Center(
                        child: Text(w, style: TextStyle(color: AppColors.textL(dark), fontSize: 12)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < firstWeekday) return const SizedBox();
              final day = i - firstWeekday + 1;
              final selectable = isSelectable(day);
              final selected = selectedDate != null &&
                  selectedDate!.year == focusedMonth.year &&
                  selectedDate!.month == focusedMonth.month &&
                  selectedDate!.day == day;
              return GestureDetector(
                onTap: selectable ? () => onSelectDay(day) : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent(dark) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : selectable
                                ? AppColors.textD(dark)
                                : AppColors.textL(dark),
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
}

class _BottomBar extends StatelessWidget {
  final bool dark;
  final int step;
  final int total;
  final String Function(int) fmt;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.dark,
    required this.step,
    required this.total,
    required this.fmt,
    required this.loading,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (step == 1)
              TextButton(onPressed: onBack, child: const Text('Back')),
            Expanded(
              child: Text(
                '${fmt(total)} EGP',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: loading ? null : (step == 0 ? onNext : onSubmit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent(dark),
                foregroundColor: Colors.white,
              ),
              child: loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(step == 0 ? 'Continue' : 'Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
