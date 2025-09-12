class EtablissementModele {
  final int id;
  final String nom;
  final String email;
  final String ville;
  final String arrondissement;
  final String departement;
  final String region;
  final bool actif;

  EtablissementModele({
    required this.id,
    required this.nom,
    required this.email,
    required this.ville,
    required this.arrondissement,
    required this.departement,
    required this.region,
    required this.actif,
  });

  factory EtablissementModele.fromJson(Map<String, dynamic> json) =>
      EtablissementModele(
        id: json['id'] as int,
        nom: json['nom'] as String? ?? '',
        email: json['email'] as String? ?? '',
        ville: json['ville'] as String? ?? '',
        arrondissement: json['arrondissement'] as String? ?? '',
        departement: json['departement'] as String? ?? '',
        region: json['region'] as String? ?? '',
        actif: json['actif'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'ville': ville,
        'arrondissement': arrondissement,
        'departement': departement,
        'region': region,
        'actif': actif,
      };
}
