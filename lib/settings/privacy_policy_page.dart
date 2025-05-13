import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..loadRequest(Uri.parse('https://thehighlandcafe.github.io/hioswebcore/settings/privacypolicy.html'));

    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: WebViewWidget(controller: controller),
    );
  }
}
