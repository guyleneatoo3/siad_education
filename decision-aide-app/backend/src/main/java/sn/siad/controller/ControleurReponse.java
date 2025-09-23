package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.ReponseQuestionnaire;
import sn.siad.service.ServiceReponse;
import sn.siad.repository.DepotUtilisateur;
import sn.siad.repository.DepotQuestionnaire;
import sn.siad.model.Utilisateur;
import sn.siad.model.Questionnaire;
import java.security.Principal;
import java.util.Map;

import java.util.List;

@RestController
@RequestMapping("/api/reponses")
public class ControleurReponse {
    private final ServiceReponse service;
    private final DepotUtilisateur depotUtilisateur;
    private final DepotQuestionnaire depotQuestionnaire;

    public ControleurReponse(ServiceReponse service, DepotUtilisateur depotUtilisateur, DepotQuestionnaire depotQuestionnaire) {
        this.service = service;
        this.depotUtilisateur = depotUtilisateur;
        this.depotQuestionnaire = depotQuestionnaire;
    }

    @GetMapping
    public List<ReponseQuestionnaire> lister() { return service.lister(); }

    @PostMapping
    @PreAuthorize("hasAnyRole('ELEVE','ENSEIGNANT')")
    public ResponseEntity<ReponseQuestionnaire> enregistrer(@RequestBody Map<String, Object> body, Principal principal) {
        // Récupérer l'utilisateur connecté
        Utilisateur utilisateur = depotUtilisateur.findByEmail(principal.getName())
            .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        // Récupérer l'id du questionnaire
        Long questionnaireId = Long.valueOf(body.get("questionnaireId").toString());
        Questionnaire questionnaire = depotQuestionnaire.findById(questionnaireId)
            .orElseThrow(() -> new RuntimeException("Questionnaire non trouvé"));
        // Créer l'entité à partir du JSON
        ReponseQuestionnaire r = new ReponseQuestionnaire();
        r.setAuteur(utilisateur);
        r.setQuestionnaire(questionnaire);
        r.setContenuJson((String) body.get("reponsesJson"));
        // La date de soumission sera gérée par @PrePersist
        return ResponseEntity.ok(service.enregistrer(r));
    }
}


