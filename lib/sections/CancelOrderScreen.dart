import 'package:flutter/material.dart';

// نموذج بيانات لسبب الإلغاء
class CancellationReason {
  final String key;
  final String label;

  CancellationReason(this.key, this.label);
}

class CancelOrderScreen extends StatefulWidget {
  final String orderId;

  const CancelOrderScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  // قائمة بأسباب الإلغاء المقترحة
  final List<CancellationReason> _reasons = [
    CancellationReason('no_longer_needed', 'لم أعد بحاجة للخدمة'),
    CancellationReason('long_wait', 'وقت الانتظار طويل جداً'),
    CancellationReason('wrong_order', 'تم طلب الخدمة بالخطأ'),
    CancellationReason('found_other', 'تم إيجاد فني آخر'),
    CancellationReason('cost_high', 'تكلفة الخدمة مرتفعة'),
    CancellationReason('other', 'سبب آخر (يرجى التحديد أدناه)'),
  ];

  CancellationReason? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _isCancelling = false;

  // دالة لمعالجة عملية الإلغاء
  void _processCancellation() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار سبب للإلغاء أولاً.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedReason!.key == 'other' &&
        _otherReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء كتابة سبب الإلغاء في الحقل المخصص.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    // محاكاة لعملية الإلغاء (يمكن استبدالها باستدعاء API حقيقي)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isCancelling = false;
    });

    // رسالة نجاح الإلغاء
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إلغاء الطلب رقم ${widget.orderId} بنجاح.'),
        backgroundColor: Colors.green,
      ),
    );

    // العودة إلى الشاشة السابقة (أو شاشة رئيسية)
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إلغاء الطلب',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة تحذيرية
            _buildWarningCard(),

            const SizedBox(height: 20),

            // عنوان الطلب
            Text(
              'طلب رقم: ${widget.orderId}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),

            const SizedBox(height: 10),

            // بطاقة أسباب الإلغاء
            _buildReasonsCard(),

            const SizedBox(height: 20),

            // زر الإلغاء
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isCancelling ? null : _processCancellation,
                icon: _isCancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined, color: Colors.white),
                label: Text(
                  _isCancelling ? 'جاري الإلغاء...' : 'تأكيد إلغاء الطلب',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ),

            const SizedBox(height: 10),
            // زر العودة
            SizedBox(
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'العودة إلى شاشة التتبع',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 30),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحذير: قد تترتب رسوم على الإلغاء!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'إذا كان الفني في طريقه إليك، قد يتم تطبيق رسوم إلغاء بسيطة. يرجى المتابعة بحذر.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'لماذا ترغب في إلغاء الطلب؟',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 25),
            ..._reasons.map((reason) {
              return RadioListTile<CancellationReason>(
                title: Text(reason.label),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (CancellationReason? value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                activeColor: Colors.red[600],
                dense: true,
              );
            }).toList(),
            const SizedBox(height: 15),
            // حقل النص يظهر فقط إذا كان السبب المختار هو "سبب آخر"
            if (_selectedReason?.key == 'other')
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _otherReasonController,
                  decoration: InputDecoration(
                    labelText: 'الرجاء تحديد سبب الإلغاء بالتفصيل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
