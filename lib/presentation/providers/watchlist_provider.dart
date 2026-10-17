import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final watchlistProvider =
    StateNotifierProvider<WatchlistStore, Set<String>>((_) => WatchlistStore());

class WatchlistStore extends StateNotifier<Set<String>> {
  WatchlistStore() : super({}) {
    final box = Hive.box('prefs');
    final list = (box.get('watchlist', defaultValue: <String>[]) as List)
        .map((e) => e.toString())
        .toSet();
    state = list;
  }

  bool has(String id) => state.contains(id);

  void toggle(String id) {
    state = state.contains(id)
        ? (Set.of(state)..remove(id))
        : (Set.of(state)..add(id));
    Hive.box('prefs').put('watchlist', state.toList());
  }
}
