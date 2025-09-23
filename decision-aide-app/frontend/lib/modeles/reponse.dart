class ReponseQuestionnaireModele {
  final int id;
  final int questionnaireId;
  final String? questionnaireTitre;
  final String reponsesJson;
  final String? utilisateurNom;
  final DateTime? dateSoumission;

  ReponseQuestionnaireModele({
    required this.id,
    required this.questionnaireId,
    this.questionnaireTitre,
    required this.reponsesJson,
    this.utilisateurNom,
    this.dateSoumission,
  });

  factory ReponseQuestionnaireModele.fromJson(Map<String, dynamic> json) {
    final questionnaire = json['questionnaire'] as Map<String, dynamic>?;
    return ReponseQuestionnaireModele(
      id: (json['id'] ?? 0) is int
          ? (json['id'] ?? 0) as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      questionnaireId: questionnaire != null
          ? (questionnaire['id'] is int
              ? questionnaire['id'] as int
              : int.tryParse(questionnaire['id']?.toString() ?? '') ?? 0)
          : 0,
      questionnaireTitre:
          questionnaire != null ? questionnaire['titre'] as String? : null,
      reponsesJson: json['contenuJson'] as String? ?? '',
      utilisateurNom: json['auteur']?['nomComplet'] as String?,
      dateSoumission: json['soumisLe'] != null
          ? DateTime.parse(json['soumisLe'] as String)
          : null,
    );
  }
}
