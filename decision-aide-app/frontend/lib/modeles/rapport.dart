class RapportAnalyseModele {
  final int id;
  final String titre;
  final String contenu;
  final String? auteurNom;
  final DateTime? dateCreation;

  RapportAnalyseModele({
    required this.id,
    required this.titre,
    required this.contenu,
    this.auteurNom,
    this.dateCreation,
  });

  factory RapportAnalyseModele.fromJson(Map<String, dynamic> json) => RapportAnalyseModele(
        id: json['id'] as int,
        titre: json['titre'] as String? ?? '',
        contenu: json['contenu'] as String? ?? '',
        auteurNom: json['auteur']?['nomComplet'] as String?,
        dateCreation: json['dateCreation'] != null 
            ? DateTime.parse(json['dateCreation'] as String)
            : null,
      );
}
