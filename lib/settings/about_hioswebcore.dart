import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AboutHioswebcore extends StatefulWidget {
  const AboutHioswebcore({super.key});

  @override
  State<AboutHioswebcore> createState() => _AboutHioswebcoreState();
}

class _AboutHioswebcoreState extends State<AboutHioswebcore> {
  late InAppWebViewController _webViewController;

  final String url = 'https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/about-harmony.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About HarmonyCore")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }
}
