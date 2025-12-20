import 'package:flutter/material.dart';
import 'VerificationScreen.dart';

class TechnicianForgotPasswordScreen extends StatefulWidget {
  const TechnicianForgotPasswordScreen({super.key});

  @override
  State<TechnicianForgotPasswordScreen> createState() =>
      _TechnicianForgotPasswordScreenState();
}

class _TechnicianForgotPasswordScreenState
    extends State<TechnicianForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }

    String cleanPhone = value.replaceAll(' ', '');

    if (!cleanPhone.startsWith('01')) {
      return 'يجب أن يبدأ رقم الهاتف بـ 01';
    }

    if (cleanPhone.length != 11) {
      return 'يجب أن يكون رقم الهاتف 11 رقمًا بالضبط';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return 'يجب أن يحتوي رقم الهاتف على أرقام فقط';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("استرجاع كلمة المرور"),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "من فضلك أدخل رقم هاتفك لاسترجاع كلمة المرور",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "رقم الهاتف",
                  hintText: "01XXXXXXXXX",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                validator: _validatePhone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // حفظ رقم الهاتف في متغير مؤقت أو SharedPreferences
                      String phoneNumber = _phoneController.text;
                      print('تم إرسال الكود إلى: $phoneNumber');

                      // الانتقال إلى شاشة التحقق
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerificationScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "إرسال الكود",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
