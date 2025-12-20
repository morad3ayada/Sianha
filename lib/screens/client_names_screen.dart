import 'package:flutter/material.dart';

class ClientNamesScreen extends StatelessWidget {
  const ClientNamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل فني / تاجر")),
      body: const Center(child: Text("هنا شاشة تسجيل الفني أو التاجر")),
    );
  }
}
