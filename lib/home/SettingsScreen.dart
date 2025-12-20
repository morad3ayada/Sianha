import 'package:flutter/material.dart';
import '../screens/role_selection_screen.dart';

// شاشة الإعدادات
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // متغير لتخزين اللغة المختارة حاليًا
  String _selectedLanguage = 'العربية';

  // قائمة اللغات المتاحة مع رموزها
  final List<Map<String, String>> _availableLanguages = [
    {'name': 'العربية', 'code': 'ar', 'flag': '🇪🇬'},
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Italiano', 'code': 'it', 'flag': '🇮🇹'},
    {'name': 'Türkçe', 'code': 'tr', 'flag': '🇹🇷'},
    {'name': 'Deutsch', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'Español', 'code': 'es', 'flag': '🇪🇸'},
  ];

  void _shareApp() {
    // ... محتوى دالة المشاركة كما هو
    const String shareText =
        'تحميل تطبيق الصيانة الرائع الآن! يمكنك إيجاد فنيين لجميع التخصصات. [رابط التحميل]';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري فتح قائمة المشاركة...'),
        backgroundColor: Colors.blue,
      ),
    );
    // TODO: قم بتنفيذ Share.share(shareText);
  }

  void _confirmLogout() {
    // ... محتوى دالة تأكيد الخروج كما هو
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // إغلاق النافذة
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق نافذة التأكيد
              // TODO: تنفيذ دالة تسجيل الخروج الفعلية
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل الخروج بنجاح.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد الخروج'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // مهم للسماح بتحكم أكبر في الحجم
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        // 🌟 الحل هنا: استخدام SingleChildScrollView لتجنب Overflow داخل الـ BottomSheet
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // مهم جداً: لتحديد الحجم الأدنى للمحتوى
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'اختر اللغة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(),
              ..._availableLanguages.map((lang) {
                final isSelected = _selectedLanguage == lang['name'];
                return ListTile(
                  title: Text(
                    '${lang['flag']} ${lang['name']}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.yellow[800] : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Colors.yellow[800])
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = lang['name']!;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تغيير اللغة إلى: ${lang['name']}'),
                        backgroundColor: Colors.yellow[700],
                      ),
                    );
                    // TODO: تنفيذ تغيير اللغة الفعلي في التطبيق
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء البطاقات (كما هي)
  Widget _buildSettingsCard(List<Widget> children) {
    // ... محتوى الدالة كما هو
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // دالة مساعدة لبناء عناصر الإعدادات (كما هي)
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    // ... محتوى الدالة كما هو
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // 🌟 الحل الرئيسي: تغليف الـ Column بـ SingleChildScrollView
      body: SingleChildScrollView(
        child: Column(
          children: [
            // شريط العنوان المخصص
            Container(
              color: Color(
                  0xc6ffbc03), // تغيير اللون الأسود ليتماشى مع اللون الأصفر
              height: 100,
              padding: const EdgeInsets.only(top: 40, right: 16, left: 16),
              child: Row(
                children: [
                  // Back button removed
                  const Spacer(),
                  const Text(
                    "قائمة الإعدادات",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // مساحة لتعويض زر الرجوع
                ],
              ),
            ),

            const SizedBox(height: 10),

            // قسم الإجراءات
            _buildSettingsCard([
              // دعوة صديق
              _buildSettingItem(
                icon: Icons.share,
                title: "دعوة صديق",
                subtitle: 'شارك التطبيق مع أصدقائك واحصل على مكافآت',
                onTap: _shareApp,
              ),
              const Divider(height: 0),

              // تغيير اللغة
              _buildSettingItem(
                icon: Icons.language,
                title: "تغيير اللغة",
                subtitle: 'اللغة الحالية: $_selectedLanguage',
                onTap: _showLanguageSelector,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ]),

            const SizedBox(height: 20),

            // قسم الخروج
            _buildSettingsCard([
              // تسجيل الخروج
              _buildSettingItem(
                icon: Icons.logout,
                title: "تسجيل الخروج",
                onTap: _confirmLogout,
                color: Colors.red[700], // لون أحمر للتنبيه
              ),
            ]),

            // إضافة مساحة سفلية احتياطية (اختياري)
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
