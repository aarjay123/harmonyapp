import 'package:flutter/material.dart';

class WebsitesPage extends StatelessWidget {
  const WebsitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Websites"),
      ),
      body: const Center(
        child: Text("List of related websites and portals."),
      ),
    );
  }
}