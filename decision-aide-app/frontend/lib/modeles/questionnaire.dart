class QuestionnaireModele {
  final int id;
  final String titre;
  final String contenuJson;

  QuestionnaireModele(
      {required this.id, required this.titre, required this.contenuJson});

  factory QuestionnaireModele.fromJson(Map<String, dynamic> json) =>
      QuestionnaireModele(
        id: json['id'] as int,
        titre: json['titre'] as String? ?? '',
        contenuJson: json['contenuJson'] as String? ?? '',
      );
}
