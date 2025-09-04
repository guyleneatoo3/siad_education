class ReponseQuestionnaireModele {
  final int id;
  final int questionnaireId;
  final String reponsesJson;
  final String? utilisateurNom;
  final DateTime? dateSoumission;

  ReponseQuestionnaireModele({
    required this.id,
    required this.questionnaireId,
    required this.reponsesJson,
    this.utilisateurNom,
    this.dateSoumission,
  });

  factory ReponseQuestionnaireModele.fromJson(Map<String, dynamic> json) => ReponseQuestionnaireModele(
        id: json['id'] as int,
        questionnaireId: json['questionnaireId'] as int,
        reponsesJson: json['reponsesJson'] as String? ?? '',
        utilisateurNom: json['utilisateur']?['nomComplet'] as String?,
        dateSoumission: json['dateSoumission'] != null 
            ? DateTime.parse(json['dateSoumission'] as String)
            : null,
      );
}
