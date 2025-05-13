import 'package:flutter/material.dart';

class AppsServicesPage extends StatelessWidget {
  const AppsServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apps & Services"),
      ),
      body: const Center(
        child: Text("Manage integrated apps and services."),
      ),
    );
  }
}
