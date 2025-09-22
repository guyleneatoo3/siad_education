import 'utilisateur.dart';

class QuestionnaireModele {
  final int id;
  final String titre;
  final String contenuJson;
  final UtilisateurModele? creePar;
  bool partage;
  DateTime? dateFinPartage;
  String destinataire; // ENSEIGNANT ou ELEVE

  QuestionnaireModele({
    required this.id,
    required this.titre,
    required this.contenuJson,
    this.creePar,
    this.partage = false,
    this.dateFinPartage,
    this.destinataire = '',
  });

  factory QuestionnaireModele.fromJson(Map<String, dynamic> json) =>
      QuestionnaireModele(
        id: json['id'] as int,
        titre: json['titre'] as String? ?? '',
        contenuJson: json['contenuJson'] as String? ?? '',
        creePar: json['creePar'] != null
            ? UtilisateurModele.fromJson(json['creePar'])
            : null,
        partage: json['partage'] ?? false,
        dateFinPartage: json['dateFinPartage'] != null
            ? DateTime.parse(json['dateFinPartage'])
            : null,
        destinataire: json['destinataire'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'contenuJson': contenuJson,
        if (creePar != null) 'creePar': creePar!.toJson(),
        'partage': partage,
        if (dateFinPartage != null)
          'dateFinPartage': dateFinPartage!.toIso8601String(),
        'destinataire': destinataire,
      };
}
