import 'package:flutter_test/flutter_test.dart';
import 'package:hanaki/data/datasources/catalog_seed.dart';
import 'package:hanaki/domain/entities/title.dart';

void main() {
  test('seed 3 kategori: anime, drakor, donghua ada', () {
    final all = seedCatalog();
    expect(all.any((t) => t.kind == ContentKind.anime), isTrue);
    expect(all.any((t) => t.kind == ContentKind.drakor), isTrue);
    expect(all.any((t) => t.kind == ContentKind.donghua), isTrue);
    // J-Drama tidak boleh ada.
    expect(all.any((t) => t.id.startsWith('j-')), isFalse);
  });

  test('badge negara JP/KR/CN benar', () {
    expect(countryBadge(Country.japan), '🇯🇵');
    expect(countryBadge(Country.korea), '🇰🇷');
    expect(countryBadge(Country.china), '🇨🇳');
    expect(countryCode(Country.japan), 'JP');
    expect(countryCode(Country.korea), 'KR');
    expect(countryCode(Country.china), 'CN');
  });

  test('partisi negara konsisten dengan kind', () {
    final all = seedCatalog();
    for (final t in all) {
      if (t.kind == ContentKind.anime) {
        expect(t.country, Country.japan);
      } else if (t.kind == ContentKind.drakor) {
        expect(t.country, Country.korea);
      } else {
        expect(t.country, Country.china);
      }
    }
  });
}
