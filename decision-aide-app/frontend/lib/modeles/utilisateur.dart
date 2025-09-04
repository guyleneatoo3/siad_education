class UtilisateurModele {
  final int id;
  final String nomComplet;
  final String? email;
  final String? matricule;
  final String role;
  final bool actif;
  final String? etablissementNom;

  UtilisateurModele({
    required this.id,
    required this.nomComplet,
    this.email,
    this.matricule,
    required this.role,
    required this.actif,
    this.etablissementNom,
  });

  factory UtilisateurModele.fromJson(Map<String, dynamic> json) => UtilisateurModele(
        id: json['id'] as int,
        nomComplet: json['nomComplet'] as String? ?? '',
        email: json['email'] as String?,
        matricule: json['matricule'] as String?,
        role: json['role'] as String? ?? '',
        actif: json['actif'] as bool? ?? false,
        etablissementNom: json['etablissement']?['nom'] as String?,
      );
}
