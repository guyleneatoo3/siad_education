class DecisionModele {
  final int id;
  final String titre;
  final String contenu;
  final bool publie;

  DecisionModele(
      {required this.id,
      required this.titre,
      required this.contenu,
      required this.publie});

  factory DecisionModele.fromJson(Map<String, dynamic> json) => DecisionModele(
        id: json['id'] as int,
        titre: json['titre'] as String? ?? '',
        contenu: json['contenu'] as String? ?? '',
        publie: json['publie'] as bool? ?? false,
      );
}
