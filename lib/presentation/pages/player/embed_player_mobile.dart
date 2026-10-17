import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Embed player non-web: tampilkan URL embed (Dailymotion/OK.ru/dll.)
/// lewat WebView native.
class EmbedPlayer extends StatefulWidget {
  const EmbedPlayer({super.key, required this.url});

  final String url;

  @override
  State<EmbedPlayer> createState() => _EmbedPlayerState();
}

class _EmbedPlayerState extends State<EmbedPlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
