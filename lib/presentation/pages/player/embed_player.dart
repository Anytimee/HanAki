// Renderer URL embed — WebView native di Android/iOS, `<iframe>` di web.
// Dipilih otomatis via conditional export (dart.library.js_interop = web).
export 'embed_player_mobile.dart'
    if (dart.library.js_interop) 'embed_player_web.dart';