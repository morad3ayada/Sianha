import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_sections.dart';

class GeneralRatingScreen extends StatefulWidget {
  final String? orderId;
  const GeneralRatingScreen({super.key, this.orderId});

  @override
  State<GeneralRatingScreen> createState() => _GeneralRatingScreenState();
}

class _GeneralRatingScreenState extends State<GeneralRatingScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // بيانات تقييمات وهمية عامة
  final List<Map<String, dynamic>> _sampleRatings = [
    {
      'user': 'أحمد محمد',
      'rating': 5,
      'comment': 'خدمة ممتازة وسريعة، فريق العمل محترف جداً',
      'date': 'منذ ساعتين',
    },
    {
      'user': 'فاطمة علي',
      'rating': 4,
      'comment': 'جيدة ولكن تأخر قليلاً في الوصول',
      'date': 'منذ يوم',
    },
    {
      'user': 'خالد إبراهيم',
      'rating': 5,
      'comment': 'أفضل خدمة استخدمتها، سعر معقول وسرعة في التنفيذ',
      'date': 'منذ 3 أيام',
    },
    {
      'user': 'سارة عبدالله',
      'rating': 3,
      'comment': 'متوسطة، تحتاج لتحسين في وقت الاستجابة',
      'date': 'منذ أسبوع',
    },
    {
      'user': 'محمود حسن',
      'rating': 5,
      'comment': 'خدمة رائعة وأنصح الجميع بتجربتها',
      'date': 'منذ أسبوع',
    },
    {
      'user': 'نورا أحمد',
      'rating': 2,
      'comment': 'لم تكن التجربة جيدة كما توقعت',
      'date': 'منذ أسبوعين',
    },
  ];

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء اختيار التقييم أولاً'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    if (widget.orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الطلب غير موجود')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final apiClient = ApiClient();

      final payload = {
        "orderId": widget.orderId,
        "rating": _rating,
        "comment": _commentController.text.isNotEmpty ? _commentController.text : "No comment",
      };

      await apiClient.post(
        ApiConstants.rateOrder,
        payload,
        token: token,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال التقييم: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'شكراً لتقييمك!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم حفظ تقييمك: $_rating نجوم',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              child: const Text('تم'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreens()), 
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating,
      {bool isInteractive = true, double size = 30}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive
              ? () {
                  setState(() {
                    _rating = index + 1;
                  });
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: size,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRatingItem(Map<String, dynamic> rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating['user'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      rating['date'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRatingStars(rating['rating'],
                  isInteractive: false, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rating['comment'],
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'التقييمات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم إضافة تقييم جديد
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'قيم تجربتك معنا',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // النجوم التفاعلية
                  _buildRatingStars(_rating, isInteractive: true, size: 40),

                  const SizedBox(height: 8),
                  Text(
                    _rating == 0 ? 'لم يتم التقييم بعد' : 'تقييمك: $_rating/5',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _rating == 0 ? Colors.grey : Colors.amber,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // حقل التعليق
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقك هنا (اختياري)...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر إرسال التقييم
                  if (_isSubmitting)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    )
                  else
                    ElevatedButton(
                      onPressed: _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إرسال التقييم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // قسم التقييمات السابقة
            const Text(
              'آراء العملاء',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${_sampleRatings.length} تقييم',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // قائمة التقييمات
            ..._sampleRatings.map(_buildRatingItem).toList(),
          ],
        ),
      ),
    );
  }
}
