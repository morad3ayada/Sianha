import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'التحقق من الرمز',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Segoe UI',
      ),
      home: VerificationScreen(),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    // إعداد التركيز التلقائي بين الحقول
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (!focusNodes[i].hasFocus && controllers[i].text.isEmpty) {
          if (i > 0) focusNodes[i - 1].requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // مساحة في الأعلى
              SizedBox(height: 40),

              // عنوان الشاشة
              Text(
                'التحقق من الرمز',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 15),

              // النص التوضيحي
              Text(
                'التحقق من الرمز المرسل إلى بريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),

              SizedBox(height: 10),

              // التعليمات
              Text(
                'أدخل رمز التحقق المرسل إليك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 40),

              // عرض الرمز المثال (948418)
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildExampleDigit(''),
                    _buildExampleDigit(''),
                    _buildExampleDigit(''),
                    _buildExampleDigit(''),
                    _buildExampleDigit(''),
                    _buildExampleDigit(''),
                  ],
                ),
              ),

              // حقول إدخال الرمز
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return _buildCodeField(index);
                }),
              ),

              SizedBox(height: 40),

              // زر التحقق
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'تحقق',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // إعادة إرسال الرمز
              TextButton(
                onPressed: _resendCode,
                child: Text(
                  'إعادة إرسال الرمز',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء حقل إدخال الرمز
  Widget _buildCodeField(int index) {
    return Container(
      width: 45,
      height: 60,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  // بناء خانة الرقم المثال
  Widget _buildExampleDigit(String digit) {
    return Container(
      width: 40,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // دالة التحقق من الرمز
  void _verifyCode() {
    String code = controllers.map((controller) => controller.text).join();
    if (code.length == 6) {
      // هنا يمكنك إضافة منطق التحقق من الرمز
      print('الرمز المدخل: $code');

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التحقق بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال الرمز بالكامل'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة إعادة إرسال الرمز
  void _resendCode() {
    // هنا يمكنك إضافة منطق إعادة إرسال الرمز
    print('إعادة إرسال الرمز');

    // عرض رسالة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إعادة إرسال الرمز'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
