import 'utilisateur.dart';

class QuestionnaireModele {
  final int id;
  final String titre;
  final String contenuJson;
  final UtilisateurModele? creePar;

  QuestionnaireModele({
    required this.id,
    required this.titre,
    required this.contenuJson,
    this.creePar,
  });

  factory QuestionnaireModele.fromJson(Map<String, dynamic> json) =>
      QuestionnaireModele(
        id: json['id'] as int,
        titre: json['titre'] as String? ?? '',
        contenuJson: json['contenuJson'] as String? ?? '',
        creePar: json['creePar'] != null
            ? UtilisateurModele.fromJson(json['creePar'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'contenuJson': contenuJson,
        if (creePar != null) 'creePar': creePar!.toJson(),
      };
}
