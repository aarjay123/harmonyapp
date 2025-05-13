import 'package:flutter/material.dart';

class SocialsPage extends StatelessWidget {
  const SocialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Socials"),
      ),
      body: const Center(
        child: Text("Follow us on social media."),
      ),
    );
  }
}
