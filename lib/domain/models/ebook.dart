class Ebook {
  final int id;
  final String slug;
  final String title;
  final String description;
  final int priceCents;
  final int? programId;
  final bool? owned;
  Ebook({required this.id, required this.slug, required this.title, required this.description, required this.priceCents, this.programId, this.owned});

  factory Ebook.fromJson(Map<String, dynamic> j) => Ebook(
        id: j['id'] as int,
        slug: j['slug'] as String,
        title: (j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        priceCents: (j['price_cents'] ?? 0) as int,
        programId: j['program_id'] as int?,
        owned: j['owned'] as bool?,
      );
}

