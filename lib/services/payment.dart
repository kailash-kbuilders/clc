import 'package:flutter/material.dart';
import '../data.dart';
import '../widgets.dart';

/// Opens the buy flow for a course.
///
/// This is where a real Razorpay checkout will be launched once a Razorpay
/// key is added. For now it runs a demo checkout and unlocks the course
/// locally, so the whole flow can be seen and tested.
Future<void> buyCourse(BuildContext context, Course c) async {
  final paid = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentSheet(course: c),
  );
  if (paid == true) {
    AppState.i.buy(c);
    if (context.mounted) snack(context, '${c.title} unlocked!');
  }
}

class _PaymentSheet extends StatefulWidget {
  final Course course;
  const _PaymentSheet({required this.course});
  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  bool _busy = false;

  Future<void> _pay() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: c.color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(c.icon, color: c.color, size: 28)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: tS),
              Text('${c.lessons} lessons • lifetime access', style: mS),
            ])),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF4F5FA), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('Total payable', style: tS),
              const Spacer(),
              Text('₹${c.price}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kOrange, minimumSize: const Size(0, 50)),
              onPressed: _busy ? null : _pay,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.lock),
              label: Text(_busy ? 'Processing...' : 'Pay ₹${c.price}'),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Demo checkout — connect Razorpay to collect real payments.',
              textAlign: TextAlign.center, style: mS),
          SizedBox(
              width: double.infinity,
              child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel'))),
        ]),
      ),
    );
  }
}
