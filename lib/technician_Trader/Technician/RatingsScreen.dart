import 'package:flutter/material.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية للتقييمات
    final List<Map<String, dynamic>> ratings = [
      {
        'customer': 'أحمد محمد',
        'rating': 5,
        'comment': 'فني ممتاز ومحترف، العمل كان متقن وسريع',
        'date': '2024-01-15',
        'service': 'صيانة تكييف'
      },
      {
        'customer': 'سارة خالد',
        'rating': 4,
        'comment': 'جيد ولكن تأخر قليلاً في الوصول',
        'date': '2024-01-14',
        'service': 'تنظيف مكيف'
      },
      {
        'customer': 'علي محمود',
        'rating': 5,
        'comment': 'أداء رائع وأسعار مناسبة، شكراً جزيلاً',
        'date': '2024-01-12',
        'service': 'تركيب تكييف'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('التقييمات'),
        backgroundColor: Colors.amber[700],
      ),
      body: Column(
        children: [
          // ملخص التقييمات
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '⭐ التقييم العام',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '4.7/5',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 5),
                const Text('بناءً على 25 تقييم'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRatingStats('5 نجوم', '15', Colors.green),
                    _buildRatingStats('4 نجوم', '7', Colors.lightGreen),
                    _buildRatingStats('3 نجوم', '2', Colors.orange),
                    _buildRatingStats('2 نجوم', '1', Colors.orangeAccent),
                    _buildRatingStats('1 نجوم', '0', Colors.red),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // قائمة التقييمات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                return _buildRatingCard(ratings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStats(String stars, String count, Color color) {
    return Column(
      children: [
        Text(
          stars,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating['customer'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        rating['service'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStars(rating['rating']),
                    Text(
                      rating['date'],
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // النجوم
            _buildStars(rating['rating'], size: 20),
            
            const SizedBox(height: 8),
            
            // التعليق
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rating['comment'],
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStars(int rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}