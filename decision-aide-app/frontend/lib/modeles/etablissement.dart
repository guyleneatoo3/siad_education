class EtablissementModele {
  final int id;
  final String nom;
  final String email;
  final String ville;
  final String region;
  final bool actif;

  EtablissementModele({
    required this.id,
    required this.nom,
    required this.email,
    required this.ville,
    required this.region,
    required this.actif,
  });

  factory EtablissementModele.fromJson(Map<String, dynamic> json) => EtablissementModele(
        id: json['id'] as int,
        nom: json['nom'] as String? ?? '',
        email: json['email'] as String? ?? '',
        ville: json['ville'] as String? ?? '',
        region: json['region'] as String? ?? '',
        actif: json['actif'] as bool? ?? false,
      );
}
