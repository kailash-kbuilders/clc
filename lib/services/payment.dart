import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data.dart';
import '../widgets.dart';

/// Razorpay Key ID.
///
/// This is a PUBLISHABLE key — it is designed to be shipped inside the app,
/// so it is safe to keep here. The matching Key Secret must NEVER be put in
/// app code: it belongs only on a server that creates orders and verifies
/// payment signatures.
const String razorpayKeyId = 'rzp_test_TpQYP57hgNKH0k';

/// Opens the buy flow for a course and, on a successful Razorpay payment,
/// unlocks the course (saved on the device).
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
  late final Razorpay _razorpay;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onSuccess(PaymentSuccessResponse r) {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _onError(PaymentFailureResponse r) {
    if (!mounted) return;
    setState(() => _busy = false);
    snack(context, 'Payment not completed. ${r.message ?? ''}'.trim());
  }

  void _onWallet(ExternalWalletResponse r) {
    if (!mounted) return;
    setState(() => _busy = false);
    snack(context, 'Wallet selected: ${r.walletName ?? ''}');
  }

  void _pay() {
    final c = widget.course;
    setState(() => _busy = true);
    final options = <String, dynamic>{
      'key': razorpayKeyId,
      'amount': c.price * 100, // rupees -> paise
      'name': 'CLC Barmer',
      'description': c.title,
      'theme': {'color': '#14196B'},
      'prefill': {
        'contact': AppState.i.userPhone,
        'name': AppState.i.userName,
      },
    };
    try {
      _razorpay.open(options);
    } catch (_) {
      setState(() => _busy = false);
      snack(context, 'Could not open the payment window.');
    }
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
              label: Text(_busy ? 'Opening...' : 'Pay ₹${c.price}'),
            ),
          ),
          const SizedBox(height: 10),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.verified_user, size: 14, color: kGreen),
            SizedBox(width: 6),
            Text('Secure payment via Razorpay', style: mS),
          ]),
          SizedBox(
              width: double.infinity,
              child: TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'))),
        ]),
      ),
    );
  }
}
