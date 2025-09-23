package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.*;
import sn.siad.repository.*;
import sn.siad.service.ServiceMistral;

import java.util.List;
import java.util.Map;
import java.util.Optional;

   

@RestController
@RequestMapping("/api/inspection")
public class ControleurInspection {

    private final ServiceMistral serviceMistral;
    private final DepotQuestionnaire depotQuestionnaire;
    private final DepotReponseQuestionnaire depotReponse;
    private final DepotRapportAnalyse depotRapport;
    private final DepotEtablissement depotEtablissement;
    private final DepotUtilisateur depotUtilisateur;

    public ControleurInspection(ServiceMistral serviceMistral, 
                               DepotQuestionnaire depotQuestionnaire,
                               DepotReponseQuestionnaire depotReponse,
                               DepotRapportAnalyse depotRapport,
                               DepotEtablissement depotEtablissement,
                               DepotUtilisateur depotUtilisateur) {
        this.serviceMistral = serviceMistral;
        this.depotQuestionnaire = depotQuestionnaire;
        this.depotReponse = depotReponse;
        this.depotRapport = depotRapport;
        this.depotEtablissement = depotEtablissement;
        this.depotUtilisateur = depotUtilisateur;
    }

    @PostMapping("/generer-questionnaire")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<?> genererQuestionnaire(@RequestParam int nombre, 
                                                @RequestParam String type, 
                                                @RequestParam String titre,
                                                Authentication auth) {
        String contenu = serviceMistral.genererQuestions(nombre, type);
        if (contenu == null) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Erreur lors de la génération du questionnaire"));
        }

        Questionnaire q = new Questionnaire();
        q.setTitre(titre);
        q.setContenuJson(contenu);
        
        // Récupérer l'utilisateur inspection qui crée le questionnaire
        String email = auth.getName();
        Optional<Utilisateur> inspecteur = depotUtilisateur.findByEmail(email);
        if (inspecteur.isPresent()) {
            q.setCreePar(inspecteur.get());
        }
        
        depotQuestionnaire.save(q);
        return ResponseEntity.ok(Map.of("titre", titre, "contenu", contenu, "id", q.getId()));
    }

    @GetMapping("/questionnaires")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<List<Questionnaire>> listerQuestionnaires() {
        return ResponseEntity.ok(depotQuestionnaire.findAll());
    }

    @GetMapping("/reponses")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<List<ReponseQuestionnaire>> listerReponses() {
        return ResponseEntity.ok(depotReponse.findAll());
    }

    @PostMapping("/analyser-reponses/{questionnaireId}")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<?> analyserReponses(@PathVariable Long questionnaireId,
                                           @RequestParam String typeQuestionnaire) {
        Optional<Questionnaire> questionnaire = depotQuestionnaire.findById(questionnaireId);
        if (questionnaire.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        // Récupérer toutes les réponses pour ce questionnaire
        List<ReponseQuestionnaire> reponses = depotReponse.findByQuestionnaire(questionnaire.get());
        if (reponses.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Aucune réponse trouvée pour ce questionnaire"));
        }

        // Combiner toutes les réponses en JSON
        StringBuilder toutesReponses = new StringBuilder();
        for (ReponseQuestionnaire reponse : reponses) {
            toutesReponses.append(reponse.getContenuJson()).append("\n");
        }

        // Analyser avec Mistral
        String analyse = serviceMistral.analyserReponses(toutesReponses.toString(), typeQuestionnaire);
        if (analyse == null) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Erreur lors de l'analyse des réponses"));
        }

        return ResponseEntity.ok(Map.of("analyse", analyse));
    }

    @PostMapping("/generer-rapport")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<?> genererRapport(@RequestParam Long questionnaireId,
                                          @RequestParam String titre,
                                          @RequestParam String avisInspection,
                                          Authentication auth) {
        Optional<Questionnaire> questionnaire = depotQuestionnaire.findById(questionnaireId);
        if (questionnaire.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        // Récupérer toutes les réponses pour ce questionnaire
        List<ReponseQuestionnaire> reponses = depotReponse.findByQuestionnaire(questionnaire.get());
        if (reponses.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Aucune réponse trouvée pour ce questionnaire"));
        }

        // Combiner toutes les réponses en JSON
        StringBuilder toutesReponses = new StringBuilder();
        for (ReponseQuestionnaire reponse : reponses) {
            toutesReponses.append(reponse.getContenuJson()).append("\n");
        }

        // Analyser avec Mistral
        String analyse = serviceMistral.analyserReponses(toutesReponses.toString(), "questionnaire");
        if (analyse == null) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Erreur lors de l'analyse des réponses"));
        }

        // Générer le rapport final
        String rapportFinal = serviceMistral.genererRapportFinal(analyse, avisInspection);
        if (rapportFinal == null) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Erreur lors de la génération du rapport final"));
        }

        // Créer le rapport
        RapportAnalyse rapport = new RapportAnalyse();
        rapport.setTitre(titre);
        rapport.setResume(rapportFinal);
        rapport.setQuestionnaire(questionnaire.get());

        depotRapport.save(rapport);
        return ResponseEntity.ok(rapport);
    }

    @GetMapping("/etablissements")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<List<Etablissement>> listerEtablissements() {
        return ResponseEntity.ok(depotEtablissement.findAll());
    }

    @PatchMapping("/etablissements/{id}/activation")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<?> activerEtablissement(@PathVariable Long id, @RequestParam boolean actif) {
        Optional<Etablissement> etablissement = depotEtablissement.findById(id);
        if (etablissement.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Etablissement etab = etablissement.get();
        etab.setActif(actif);
        depotEtablissement.save(etab);

        // Activer/désactiver aussi les utilisateurs de cet établissement
        List<Utilisateur> utilisateurs = depotUtilisateur.findByEtablissement(etab);
        for (Utilisateur utilisateur : utilisateurs) {
            utilisateur.setActif(actif);
            depotUtilisateur.save(utilisateur);
        }

        return ResponseEntity.ok(Map.of("message", "Établissement " + (actif ? "activé" : "désactivé") + " avec succès"));
    }

    @GetMapping("/rapports")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<List<RapportAnalyse>> listerRapports() {
        return ResponseEntity.ok(depotRapport.findAll());
    }


     /**
     * Liste les questionnaires créés par l'inspecteur connecté
     */
    @GetMapping("/mes-questionnaires")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<List<Questionnaire>> listerQuestionnairesParCreateur(Authentication auth) {
        String email = auth.getName();
        Optional<Utilisateur> inspecteur = depotUtilisateur.findByEmail(email);
        if (inspecteur.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        List<Questionnaire> questionnaires = depotQuestionnaire.findByCreePar(inspecteur.get());
        return ResponseEntity.ok(questionnaires);
    }

    /**
     * Liste les questionnaires créés par l'inspecteur connecté filtrés par destinataire (ELEVE/ENSEIGNANT)
     */
    @GetMapping("/mes-questionnaires/{destinataire}")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<List<Questionnaire>> listerQuestionnairesParCreateurEtDestinataire(@PathVariable String destinataire, Authentication auth) {
        String email = auth.getName();
        Optional<Utilisateur> inspecteur = depotUtilisateur.findByEmail(email);
        if (inspecteur.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        List<Questionnaire> questionnaires = depotQuestionnaire.findByCreePar(inspecteur.get())
            .stream()
            .filter(q -> destinataire.equalsIgnoreCase(q.getDestinataire()))
            .toList();
        return ResponseEntity.ok(questionnaires);
    }

}


