// order_tracking_screen.dart

import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // متغير لتخزين وقت التجهيز (يمكن أن يكون فارغاً)
  late String _preparationTime;
  // **متغير جديد لتتبع الحالة القابلة للتغيير يدويًا**
  late String _currentOrderStatus;
  // **متغير جديد لتغيير لون الحالة القابلة للتغيير يدويًا**
  late Color _currentStatusColor;

  @override
  void initState() {
    super.initState();
    _preparationTime = widget.order['preparationTime'] ?? '--';
    _currentOrderStatus = widget.order['status'] ?? 'جديد';
    _currentStatusColor = widget.order['statusColor'] ?? Colors.grey;
  }

  // **دالة جديدة: لتأكيد الطلب يدويًا (التاجر)**
  void _confirmOrder() {
    setState(() {
      // قم بتغيير الحالة إلى "قيد التجهيز" أو "مقبول"
      _currentOrderStatus = 'مقبول';
      _currentStatusColor = Colors.green;
    });
    // هنا يجب إضافة منطق لحفظ الحالة الجديدة في قاعدة البيانات/الـ State
    _showSuccessMessage(
        context, 'تم تأكيد الطلب بنجاح. الآن يمكنك تحديد وقت التجهيز.');
  }

  // 1. دالة لعرض مربع حوار إدخال وقت التجهيز
  void _showPreparationTimeDialog() {
    String tempTime = _preparationTime == '--' ? '' : _preparationTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تحديد وقت التجهيز ⏱️'),
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              tempTime = value;
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "مثال: 30 دقيقة",
              labelText: "وقت التجهيز المتوقع (للتجار)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tempTime.isNotEmpty) {
                  setState(() {
                    _preparationTime = tempTime;
                    _currentOrderStatus =
                        'قيد التجهيز'; // تحديث الحالة إلى قيد التجهيز
                    _currentStatusColor = Colors.amber;
                    // هنا يمكن إضافة منطق لحفظ القيمة في قاعدة البيانات/الـ State
                  });
                }
                Navigator.pop(context);
                _showSuccessMessage(context,
                    'تم حفظ وقت التجهيز وتحديث حالة الطلب إلى (قيد التجهيز): $_preparationTime');
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'تتبع الطلب ${widget.order['id']}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطلب الأساسية والمبلغ (يستخدم المتغيرات الجديدة)
            _buildOrderSummaryCard(context),

            SizedBox(height: 24),

            // معلومات العميل والمندوب
            _buildCustomerAndAgentInfo(),

            SizedBox(height: 24),

            // عنوان خطوات التتبع
            Text(
              'حالة ومراحل تنفيذ الطلب 🚚',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            // خطوات التتبع الفعلية (تعتمد الآن على _currentOrderStatus)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: _buildTrackingSteps(),
            ),
          ],
        ),
      ),
    );
  }

  // 2. دالة بناء بطاقة ملخص الطلب (تم تعديلها لاستخدام المتغيرات الجديدة)
  Widget _buildOrderSummaryCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_cart, color: Colors.black, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العميل: ${widget.order['customer']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'رقم الطلب: ${widget.order['id']}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.order['amount'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  // **استخدام اللون المُحدَّث**
                  color: _currentStatusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  // **استخدام الحالة المُحدَّثة**
                  _currentOrderStatus,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. دالة بناء معلومات العميل والمندوب
  Widget _buildCustomerAndAgentInfo() {
    // يجب التأكد من تمرير هذه الحقول في خريطة الطلب (order)
    final customer = widget.order['customerInfo'] ??
        {'name': 'غير متوفر', 'phone': '--', 'address': 'غير متوفر'};
    final agent =
        widget.order['deliveryAgent'] ?? {'name': 'غير متوفر', 'phone': '--'};

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // معلومات العميل
        Expanded(
          child: _buildInfoCard(
            title: 'معلومات العميل',
            icon: Icons.person,
            details: [
              _buildDetailRow('الاسم:', customer['name']),
              _buildDetailRow('العنوان:', customer['address']),
              _buildDetailRow('الهاتف:', customer['phone'], isPhone: true),
            ],
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 16),
        // معلومات المندوب
        Expanded(
          child: _buildInfoCard(
            title: 'معلومات المندوب',
            icon: Icons.delivery_dining,
            details: [
              _buildDetailRow('الاسم:', agent['name']),
              _buildDetailRow('الهاتف:', agent['phone'], isPhone: true),
            ],
            color: Colors.deepOrange,
          ),
        ),
      ],
    );
  }

  // 4. دالة بناء بطاقة معلومات (عميل/مندوب)
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> details,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: color.withOpacity(0.5), height: 15),
          ...details,
        ],
      ),
    );
  }

  // 5. دالة بناء صف تفصيلي
  Widget _buildDetailRow(String label, String value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                decoration:
                    isPhone ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. دالة بناء خطوات التتبع (تم تعديلها لدعم زر تأكيد الطلب اليدوي)
  Widget _buildTrackingSteps() {
    // **استخدام المتغيرات المُحدَّثة**
    String currentStatus = _currentOrderStatus;
    Color activeColor = Color(0xFFFFD700);

    List<Map<String, dynamic>> trackingSteps = [
      {
        'step': 'استلام الطلب 📝',
        'responsible': 'النظام/التاجر',
        'completed': true,
        'time': widget.order['time'] ?? 'الآن',
      },
      {
        'step': 'تأكيد الطلب ✅',
        'responsible': '**التاجر**',
        // تعتبر الخطوة مكتملة إذا كانت الحالة ليست 'جديد'
        'completed': currentStatus != 'جديد' && currentStatus != 'مرفوض',
        'time': (currentStatus != 'جديد' && currentStatus != 'مرفوض')
            ? 'تم التأكيد'
            : '--',
        // **إضافة زر الإجراء لخطوة تأكيد الطلب**
        'action': true,
        'actionType': 'confirm',
      },
      {
        'step': 'تجهيز الطلب (وقت: $_preparationTime) 📦',
        'responsible': '**التاجر**',
        // تعتبر الخطوة مكتملة إذا كانت الحالة 'قيد التجهيز' أو ما بعدها
        'completed': currentStatus == 'قيد التجهيز' ||
            currentStatus == 'للشحن' ||
            currentStatus == 'تم التوصيل',
        'time': currentStatus == 'قيد التجهيز' ? 'الآن' : '--',
        // **تعديل شرط إظهار زر الإجراء لوقت التجهيز**
        'action': true,
        'actionType': 'prep_time',
      },
      {
        'step': 'الشحن والاستلام 🛵',
        'responsible': '**المندوب**',
        'completed':
            currentStatus == 'في الطريق' || currentStatus == 'تم التوصيل',
        'time': currentStatus == 'في الطريق' ? 'الآن' : '--',
      },
      {
        'step': 'التسليم والدفع 💰',
        'responsible': '**المندوب/العميل**',
        'completed': currentStatus == 'تم التوصيل',
        'time': currentStatus == 'تم التوصيل' ? 'تم الانتهاء' : '--',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: trackingSteps.length,
      itemBuilder: (context, index) {
        final step = trackingSteps[index];
        bool isLast = index == trackingSteps.length - 1;

        Widget? actionButton;

        if (step['action'] == true && !step['completed']) {
          // زر تأكيد الطلب
          if (step['actionType'] == 'confirm' && currentStatus == 'جديد') {
            actionButton = ElevatedButton.icon(
              onPressed: _confirmOrder, // الدالة لتأكيد الطلب يدويًا
              icon: Icon(Icons.verified, size: 16),
              label: Text('تأكيد الطلب يدويًا'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                textStyle: TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          // زر تحديد وقت التجهيز
          else if (step['actionType'] == 'prep_time' &&
              currentStatus == 'مقبول') {
            actionButton = ElevatedButton.icon(
              onPressed: _showPreparationTimeDialog,
              icon: Icon(Icons.timer, size: 16),
              label: Text('تحديد وقت التجهيز'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                textStyle: TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator & Connector Line
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            step['completed'] ? activeColor : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: step['completed']
                          ? Icon(Icons.check, color: Colors.black, size: 18)
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    if (!isLast)
                      Container(
                        height: 50, // طول الخط الرأسي
                        width: 2,
                        color:
                            step['completed'] ? activeColor : Colors.grey[300],
                      ),
                  ],
                ),

                SizedBox(width: 16),

                // Step Info and Action
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['step'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: step['completed']
                                ? Colors.black
                                : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'مسؤولية: ${step['responsible']}',
                              style: TextStyle(
                                color: step['completed']
                                    ? Colors.black87
                                    : Colors.black45,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              step['time'],
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // زر الإجراء الجديد أو زر وقت التجهيز
                        if (actionButton != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: actionButton,
                          ),
                        if (actionButton == null &&
                            step['action'] == true &&
                            step['completed'])
                          SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 7. دالة مساعدة لعرض رسائل النجاح
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
