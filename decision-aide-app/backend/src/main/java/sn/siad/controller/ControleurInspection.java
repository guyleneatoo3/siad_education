package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Questionnaire;
import sn.siad.repository.DepotQuestionnaire;
import sn.siad.service.ServiceMistral;

import java.util.Map;

@RestController
@RequestMapping("/api/inspection")
public class ControleurInspection {

    private final ServiceMistral serviceMistral;
    private final DepotQuestionnaire depotQuestionnaire;

    public ControleurInspection(ServiceMistral serviceMistral, DepotQuestionnaire depotQuestionnaire) {
        this.serviceMistral = serviceMistral;
        this.depotQuestionnaire = depotQuestionnaire;
    }

    @PostMapping("/generer-questionnaire")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<?> genererQuestionnaire(@RequestParam int nombre, @RequestParam String type, @RequestParam String titre) {
        String contenu = serviceMistral.genererQuestions(nombre, type);
        Questionnaire q = new Questionnaire();
        q.setTitre(titre);
        q.setContenuJson(contenu);
        depotQuestionnaire.save(q);
        return ResponseEntity.ok(Map.of("titre", titre, "contenu", contenu));
    }
}


