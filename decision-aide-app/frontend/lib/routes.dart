import 'package:flutter/material.dart';
import 'screens/connexion_screen.dart';
import 'screens/tableau_bord_screen.dart';
import 'screens/decisions_screen.dart';
import 'screens/questionnaires_screen.dart';
import 'screens/dashboards/dashboard_eleve.dart';
import 'screens/dashboards/dashboard_enseignant.dart';
import 'screens/dashboards/dashboard_etablissement.dart';
import 'screens/dashboards/dashboard_inspection.dart';
import 'screens/dashboards/dashboard_ministere.dart';
import 'screens/dashboards/dashboard_visiteur.dart';
import 'screens/dashboards/dashboard_admin.dart';
import 'screens/etablissements_screen.dart';
import 'screens/reponses_screen.dart';
import 'screens/rapports_screen.dart';
import 'screens/utilisateurs_screen.dart';
import 'screens/questionnaire_detail_screen.dart';
import 'screens/decision_detail_screen.dart';
import 'screens/accueil_public_screen.dart';
import 'screens/import_excel_screen.dart';
import 'screens/mistral_test_screen.dart';

class RoutesApp {
  static const String accueilPublic = '/accueil';
  static const String connexion = '/connexion';
  static const String tableauBord = '/tableau';
  static const String decisions = '/decisions';
  static const String questionnaires = '/questionnaires';
  static const String tableauBordEleve = '/tableau/eleve';
  static const String tableauBordEnseignant = '/tableau/enseignant';
  static const String tableauBordEtablissement = '/tableau/etablissement';
  static const String tableauBordInspection = '/tableau/inspection';
  static const String tableauBordMinistere = '/tableau/ministere';
  static const String tableauBordVisiteur = '/tableau/visiteur';
  static const String tableauBordAdmin = '/tableau/admin';
  static const String etablissements = '/etablissements';
  static const String reponses = '/reponses';
  static const String rapports = '/rapports';
  static const String utilisateurs = '/utilisateurs';
  static const String questionnaireDetail = '/questionnaire/detail';
  static const String decisionDetail = '/decision/detail';
  static const String importExcel = '/import-excel';
  static const String mistralTest = '/mistral-test';

  static String tableauBordParRole(String role) {
    switch (role) {
      case 'ELEVE':
        return tableauBordEleve;
      case 'ENSEIGNANT':
        return tableauBordEnseignant;
      case 'ETABLISSEMENT':
        return tableauBordEtablissement;
      case 'INSPECTION':
        return tableauBordInspection;
      case 'MINISTERE':
        return tableauBordMinistere;
      case 'VISITEUR':
        return tableauBordVisiteur;
      case 'ADMINISTRATEUR':
        return tableauBordAdmin;
      default:
        return connexion;
    }
  }

  static Map<String, WidgetBuilder> routes(BuildContext context) => {
        accueilPublic: (_) => const AccueilPublicScreen(),
        connexion: (_) => const ConnexionScreen(),
        tableauBord: (_) => const TableauBordScreen(),
        decisions: (_) => const DecisionsScreen(),
        questionnaires: (_) => const QuestionnairesScreen(),
        tableauBordEleve: (_) => const DashboardEleve(),
        tableauBordEnseignant: (_) => const DashboardEnseignant(),
        tableauBordEtablissement: (_) => const DashboardEtablissement(),
        tableauBordInspection: (_) => const DashboardInspection(),
        tableauBordMinistere: (_) => const DashboardMinistere(),
        tableauBordVisiteur: (_) => const DashboardVisiteur(),
        tableauBordAdmin: (_) => const DashboardAdmin(),
        etablissements: (_) => const EtablissementsScreen(),
        reponses: (_) => const ReponsesScreen(),
        rapports: (_) => const RapportsScreen(),
        utilisateurs: (_) => const UtilisateursScreen(),
        questionnaireDetail: (_) => const QuestionnaireDetailScreen(),
        decisionDetail: (_) => const DecisionDetailScreen(),
        importExcel: (_) => const ImportExcelScreen(),
        mistralTest: (_) => const MistralTestScreen(),
      };
}
