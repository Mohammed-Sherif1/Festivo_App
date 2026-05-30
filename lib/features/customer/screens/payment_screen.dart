import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:festivo/app/providers/app_providers.dart';
import 'package:festivo/core/constants/app_colors.dart';
import 'package:festivo/features/customer/screens/customer_shell.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String venueName;
  final int totalAmount;
  final DateTime bookingDate;
  final String bookingTime;

  const PaymentScreen({
    super.key,
    required this.venueName,
    required this.totalAmount,
    required this.bookingDate,
    required this.bookingTime,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedMethod = 0;
  File? _receiptFile;
  bool _isConfirming = false;

  static const _methods = [
    _PayMethod(
      icon: Icons.payments_rounded,
      iconBg: Color(0xFFD4F0DF),
      iconColor: Color(0xFF4CAF50),
      title: 'Cash',
      subtitle: 'Pay on arrival at the venue',
    ),
    _PayMethod(
      icon: Icons.dialpad_rounded,
      iconBg: Color(0xFFDDE0FF),
      iconColor: Color(0xFF7B9FD4),
      title: 'Vodafone Cash',
      subtitle: 'Pay via Vodafone Cash wallet',
    ),
    _PayMethod(
      icon: Icons.bolt_rounded,
      iconBg: Color(0xFFFFF3CD),
      iconColor: Color(0xFFE8A87C),
      title: 'InstaPay',
      subtitle: 'Instant bank transfer via InstaPay',
    ),
  ];

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  String get _dateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = widget.bookingDate;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (file != null) {
      setState(() => _receiptFile = File(file.path));
    }
  }

  Future<void> _confirm() async {
    if (_selectedMethod > 0 && _receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a payment receipt.')),
      );
      return;
    }
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isConfirming = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Booking Confirmed!'),
        content: Text(
          'Your booking at ${widget.venueName} on $_dateLabel at ${widget.bookingTime} '
          'has been confirmed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CustomerShell()),
                (route) => false,
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(isDarkProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(dark),
      appBar: AppBar(
        backgroundColor: AppColors.bg(dark),
        elevation: 0,
        title: Text('Payment', style: TextStyle(color: AppColors.textD(dark))),
        iconTheme: IconThemeData(color: AppColors.textD(dark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent(dark), AppColors.accent2(dark)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.venueName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('$_dateLabel · ${widget.bookingTime}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Text(
                    '${_fmt(widget.totalAmount)} EGP',
                    style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
            const SizedBox(height: 12),
            ...List.generate(_methods.length, (i) {
              final m = _methods[i];
              final sel = _selectedMethod == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card(dark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? AppColors.accent(dark) : AppColors.border(dark),
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: m.iconBg, borderRadius: BorderRadius.circular(12)),
                        child: Icon(m.icon, color: m.iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textD(dark))),
                            Text(m.subtitle, style: TextStyle(fontSize: 12, color: AppColors.textM(dark))),
                          ],
                        ),
                      ),
                      Icon(
                        sel ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: sel ? AppColors.accent(dark) : AppColors.textL(dark),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedMethod > 0) ...[
              const SizedBox(height: 16),
              Text('Upload Receipt', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textD(dark))),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickReceipt,
                icon: const Icon(Icons.upload_file),
                label: Text(_receiptFile == null ? 'Choose image' : 'Receipt selected'),
              ),
              if (_receiptFile != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_receiptFile!, height: 120, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isConfirming ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent(dark),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isConfirming
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayMethod {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _PayMethod({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
