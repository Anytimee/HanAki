import '../../domain/entities/title.dart';

// Seed 3 kategori: Anime JP | Drakor KR | Donghua CN.
// Produksi: GET /api/contents?country=JP&type=ANIME dst.

List<CatalogTitle> seedCatalog() => const [
      CatalogTitle(
        id: 'a-solo',
        kind: ContentKind.anime,
        country: Country.japan,
        titles: {'id': 'Solo Leveling', 'en': 'Solo Leveling'},
        synopses: {
          'id': 'Hunter terlemah bangkit jadi monarch bayangan.',
          'en': 'Weakest hunter rises as shadow monarch.'
        },
        genres: ['Action', 'Fantasy'],
        year: 2024,
        rating: 9.0,
        poster: 'https://picsum.photos/seed/solo-p/400/600',
        banner: 'https://picsum.photos/seed/solo-b/1200/600',
        episodes: 12,
        status: 'ONGOING',
      ),
      CatalogTitle(
        id: 'a-frieren',
        kind: ContentKind.anime,
        country: Country.japan,
        titles: {'id': 'Frieren', 'en': 'Frieren'},
        synopses: {
          'id': 'Penyihir abadi memahami manusia dan waktu.',
          'en': 'An elven mage understands humanity.'
        },
        genres: ['Fantasy', 'Drama', 'Isekai'],
        year: 2024,
        rating: 9.1,
        poster: 'https://picsum.photos/seed/frieren-p/400/600',
        banner: 'https://picsum.photos/seed/frieren-b/1200/600',
        episodes: 28,
        status: 'COMPLETED',
      ),
      CatalogTitle(
        id: 'k-queen',
        kind: ContentKind.drakor,
        country: Country.korea,
        titles: {'id': 'Queen of Tears', 'en': 'Queen of Tears'},
        synopses: {
          'id': 'Pewaris konglomerat selamatkan pernikahan.',
          'en': 'Heiress saves her marriage.'
        },
        genres: ['Romance', 'Melodrama'],
        year: 2024,
        rating: 8.7,
        poster: 'https://picsum.photos/seed/queen-p/400/600',
        banner: 'https://picsum.photos/seed/queen-b/1200/600',
        episodes: 16,
        status: 'COMPLETED',
      ),
      CatalogTitle(
        id: 'k-moving',
        kind: ContentKind.drakor,
        country: Country.korea,
        titles: {'id': 'Moving', 'en': 'Moving'},
        synopses: {
          'id': 'Remaja super diburu intelijen.',
          'en': 'Super teens hunted by agencies.'
        },
        genres: ['Action', 'Thriller'],
        year: 2024,
        rating: 8.9,
        poster: 'https://picsum.photos/seed/moving-p/400/600',
        banner: 'https://picsum.photos/seed/moving-b/1200/600',
        episodes: 20,
        status: 'COMPLETED',
      ),
      CatalogTitle(
        id: 'c-soulland',
        kind: ContentKind.donghua,
        country: Country.china,
        titles: {'id': 'Soul Land', 'en': 'Soul Land'},
        synopses: {
          'id': 'Tang San berkultivasi jadi dewa roh.',
          'en': 'Tang San cultivates to spirit god.'
        },
        genres: ['Cultivation', 'Action'],
        year: 2024,
        rating: 8.6,
        poster: 'https://picsum.photos/seed/soulland-p/400/600',
        banner: 'https://picsum.photos/seed/soulland-b/1200/600',
        episodes: 40,
        status: 'ONGOING',
      ),
      CatalogTitle(
        id: 'c-linkclick',
        kind: ContentKind.donghua,
        country: Country.china,
        titles: {'id': 'Link Click', 'en': 'Link Click'},
        synopses: {
          'id': 'Dua sahabat masuk foto ubah masa lalu.',
          'en': 'Friends dive into photos to alter past.'
        },
        genres: ['Supernatural', 'Mystery'],
        year: 2024,
        rating: 8.8,
        poster: 'https://picsum.photos/seed/linkclick-p/400/600',
        banner: 'https://picsum.photos/seed/linkclick-b/1200/600',
        episodes: 12,
        status: 'COMPLETED',
      ),
    ];

// Helper per-tab. Contoh API: GET /api/contents?country=JP&type=ANIME
List<CatalogTitle> byKind(List<CatalogTitle> all, ContentKind k) =>
    all.where((t) => t.kind == k).toList();
