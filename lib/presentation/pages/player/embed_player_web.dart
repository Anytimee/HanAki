import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Embed player Flutter Web: WebView native tidak tersedia di JS,
/// jadi render `<iframe src={embedUrl}>` lewat platform view.
class EmbedPlayer extends StatefulWidget {
  const EmbedPlayer({super.key, required this.url});

  final String url;

  @override
  State<EmbedPlayer> createState() => _EmbedPlayerState();
}

class _EmbedPlayerState extends State<EmbedPlayer> {
  static int _seq = 0;
  late final String _viewType = 'hanaki-embed-${_seq++}';

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => web.HTMLIFrameElement()
        ..src = Uri.parse(widget.url).toString()
        ..allowFullscreen = true
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}