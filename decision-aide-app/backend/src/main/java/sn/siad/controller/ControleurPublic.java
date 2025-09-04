package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Decision;
import sn.siad.repository.DepotDecision;

import java.util.List;

@RestController
@RequestMapping("/api/public")
public class ControleurPublic {

    private final DepotDecision depotDecision;

    public ControleurPublic(DepotDecision depotDecision) {
        this.depotDecision = depotDecision;
    }

    @GetMapping("/decisions")
    public ResponseEntity<List<Decision>> listerDecisionsPubliees() {
        // Récupérer seulement les décisions publiées
        List<Decision> decisionsPubliees = depotDecision.findByPublieTrue();
        return ResponseEntity.ok(decisionsPubliees);
    }

    @GetMapping("/decisions/{id}")
    public ResponseEntity<Decision> obtenirDecision(@PathVariable Long id) {
        return depotDecision.findById(id)
                .filter(Decision::isPublie)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}


