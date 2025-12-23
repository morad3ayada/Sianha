import 'package:flutter/material.dart';
import 'location_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';

class RequestDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        backgroundColor: Colors.amber[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات الطلب الأساسية
            _buildInfoCard(
              'معلومات الطلب',
              [
                _buildInfoRow('رقم الطلب', request['id']),
                _buildInfoRow('نوع الخدمة', request['service']),
                _buildInfoRow('تاريخ الطلب', _formatDateOnly(request['createdAt'] ?? request['date'])),
                _buildInfoRow('وقت الطلب', _formatTimeOnly(request['createdAt'] ?? request['date'])),
                _buildInfoRow('طريقة الدفع',
                    (request['payWay'] == 0 || request['payWay'] == '0') ? 'كاش' : 'اونلاين'),
                _buildInfoRow('السعر', '${request['amount'] ?? request['totalPrice'] ?? request['price'] ?? '0'} جنية'),
                _buildInfoRow('الأولوية', _getPriorityText(request['priority'])),
                _buildInfoRow('حالة الطلب', _getStatusText(request['status'])),
                if (request['problemImageUrl'] != null && 
                    request['problemImageUrl'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'صورة المشكلة:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            request['problemImageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey, size: 50)
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // معلومات العميل
            _buildInfoCard(
              'معلومات العميل',
              [
                _buildInfoRow('اسم العميل', request['customer']),
                _buildInfoRow('رقم الهاتف', request['customerPhoneNumber'] ?? request['phone'] ?? 'غير متوفر'),
                // // _buildInfoRow('المحافظة', request['governorate']),
                _buildInfoRow('العنوان', request['address']),
              ],
            ),

            // تفاصيل إضافية
            _buildInfoCard(
              'تفاصيل إضافية',
              [
                _buildInfoRow(
                    'ملاحظات العميل', request['problemDescription'] ?? request['notes'] ?? 'لا توجد ملاحظات'),
                // _buildInfoRow(
                //     'التقييم السابق', request['previousRating'] ?? 'لا يوجد'),
              ],
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            // أزرار التحكم حسب حالة الطلب
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في انتظار الرد';
      case 'accepted':
        return 'تم القبول';
      case 'on_the_way':
        return 'في الطريق';
      case 'arrived':
        return 'وصل الموقع';
      case 'repairing':
        return 'جاري التصليح';
      case 'completed':
        return 'تم الانتهاء';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'في انتظار الرد';
    }
  }

  String _getPriorityText(dynamic priority) {
    int p = 1; // Default Normal
    if (priority is int) {
      p = priority;
    } else if (priority is String) {
      p = int.tryParse(priority) ?? 1;
    }

    switch (p) {
      case 0:
        return 'منخفضة';
      case 1:
        return 'عادية';
      case 2:
        return 'عالية';
      case 3:
        return 'طارئة';
      default:
        return 'عادية';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (request['status']) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  _acceptRequest(context);
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'قبول الطلب',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  _rejectRequestWithReason(context);
                },
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  'رفض الطلب',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );

      case 'accepted':
        return Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                _startNavigation(context);
              },
              icon: const Icon(Icons.directions, color: Colors.white),
              label: const Text(
                'بدء التوجه للعميل',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'تم قبول الطلب، يمكنك الآن التوجه لموقع العميل',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 'on_the_way':
        return Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                _markAsArrived(context);
              },
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: const Text(
                'تأكيد الوصول للموقع',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'أنت في طريقك للعميل',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

      case 'arrived':
        return Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                _startRepair(context);
              },
              icon: const Icon(Icons.build, color: Colors.white),
              label: const Text(
                'بدء التصليح',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                _cancelWithReason(context);
              },
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text(
                'إلغاء بعد الوصول',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );

      case 'repairing':
        return Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                _completeRepair(context);
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'إنهاء التصليح',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'جاري العمل على التصليح...',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

      case 'completed':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 10),
              const Text(
                'تم الانتهاء من التصليح بنجاح',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                'المبلغ: ${request['amount'] ?? '0'} جنية',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

      default:
        return Container();
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget _buildRawDataCard() {
  //   // Define keys that are already displayed to exclude them
  //   final excludedKeys = [
  //     'id', 'service', 'date', 'time', 'payment', 'priority', 'status', 
  //     'customer', 'phone', 'governorate', 'address', 'notes', 'previousRating',
  //     'Id', 'ServiceName', 'OrderDate', 'Time', 'PaymentStatus', 'Priority', 'Status',
  //     'CustomerName', 'PhoneNumber', 'GovernorateName', 'Address', 'Notes', 'TotalPrice'
  //   ];

  //   final otherData = request.entries.where((e) {
  //     final key = e.key;
  //     // Exclude already shown keys and complex objects/lists
  //     return !excludedKeys.contains(key) && e.value is! List && e.value is! Map;
  //   }).toList();

  //   if (otherData.isEmpty) return const SizedBox.shrink();

   
  // }

  String _formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'غير متوفر';
    try {
      final date = DateTime.parse(dateStr);
      final year = date.year;
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTimeOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'غير متوفر';
    try {
      final date = DateTime.parse(dateStr);
      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '$hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'غير متوفر',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _acceptRequest(BuildContext context) {
    final TextEditingController priceController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('قبول الطلب'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أدخل السعر المقترح للخدمة:'),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'السعر (جنية)',
                    border: OutlineInputBorder(),
                    suffixText: 'جنية',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final price = priceController.text.trim();
                        if (price.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('الرجاء إدخال السعر')),
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('auth_token');
                          final orderId = request['id'];

                          if (token == null) {
                            throw Exception('غير مصرح لك، يرجى تسجيل الدخول');
                          }

                          final apiClient = ApiClient();
                          final url = "${ApiConstants.acceptOrder}/$orderId?price=$price";
                          
                          print("🚀 Accepting Order: $url");
                          
                          await apiClient.post(
                            url,
                            {}, // Empty body
                            token: token,
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // Close Dialog
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم قبول الطلب بسعر $price جنية')),
                            );

                            // Pop back to home screen to trigger refresh
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          print("❌ Error Accepting Order: $e");
                           if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('فشل قبول الطلب: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('تأكيد وقبول'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startNavigation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(request: request),
      ),
    ).then((_) {
      // عند العودة من شاشة اللوكيشن، تحديث الحالة إلى "في الطريق"
      _updateRequestStatus('on_the_way');
    });
  }

  void _markAsArrived(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الوصول'),
        content: const Text('هل وصلت إلى موقع العميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateRequestStatus('arrived');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تأكيد الوصول للموقع')),
              );
            },
            child: const Text('نعم، وصلت'),
          ),
        ],
      ),
    );
  }

  void _startRepair(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بدء التصليح'),
        content: const Text('هل تريد بدء عملية التصليح الآن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateRequestStatus('repairing');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم بدء التصليح')),
              );
            },
            child: const Text('بدء التصليح'),
          ),
        ],
      ),
    );
  }

  void _completeRepair(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنهاء التصليح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل انتهيت من التصليح بنجاح؟'),
            const SizedBox(height: 16),
            const Text('المبلغ المستحق:'),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'أدخل المبلغ المستحق',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateRequestStatus('completed');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنهاء التصليح بنجاح')),
              );
            },
            child: const Text('تأكيد الانتهاء'),
          ),
        ],
      ),
    );
  }

  void _rejectRequestWithReason(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('رفض الطلب'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('سبب الرفض:'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'أدخل سبب رفض الطلب...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isLoading
                    ? null
                    : () async {
                        final String reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى إدخال سبب الرفض')),
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('auth_token');
                          final orderId = request['id'];

                          if (token == null) {
                            throw Exception('غير مصرح لك، يرجى تسجيل الدخول');
                          }

                          final apiClient = ApiClient();
                          final payload = {
                            "orderId": orderId,
                            "rejectionReason": reason
                          };

                          print("🚀 Rejecting Order: ${ApiConstants.rejectOrder}");
                          print("📦 Payload: $payload");

                          await apiClient.post(
                            ApiConstants.rejectOrder,
                            payload,
                            token: token,
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // Close Dialog
                             // You might want to pop the details screen as well or update status
                             Navigator.pop(context); // Back to Home
                             
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم رفض الطلب - السبب: $reason')),
                            );
                          }
                        } catch (e) {
                          print("❌ Error Rejecting Order: $e");
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('فشل رفض الطلب: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('تأكيد الرفض'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _cancelWithReason(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء بعد الوصول'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سبب الإلغاء بعد الوصول:'),
            const SizedBox(height: 8),
            TextFormField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'أدخل سبب الإلغاء...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final String reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال سبب الإلغاء')),
                );
                return;
              }

              Navigator.pop(context);
              Navigator.pop(context);
              _updateRequestStatus('cancelled');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إلغاء الطلب - السبب: $reason')),
              );
            },
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }

  void _updateRequestStatus(String newStatus) {
    // هنا يمكنك إضافة كود لتحديث حالة الطلب في قاعدة البيانات
    print('تم تحديث حالة الطلب ${request['id']} إلى: $newStatus');

    // مثال:
    // await DatabaseService().updateRequestStatus(request['id'], newStatus);
  }
}
