package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.ReponseQuestionnaire;
import sn.siad.service.ServiceReponse;

import java.util.List;

@RestController
@RequestMapping("/api/reponses")
public class ControleurReponse {
    private final ServiceReponse service;

    public ControleurReponse(ServiceReponse service) { this.service = service; }

    @GetMapping
    @PreAuthorize("hasAnyRole('INSPECTION','ADMINISTRATEUR')")
    public List<ReponseQuestionnaire> lister() { return service.lister(); }

    @PostMapping
    @PreAuthorize("hasAnyRole('ELEVE','ENSEIGNANT')")
    public ResponseEntity<ReponseQuestionnaire> enregistrer(@RequestBody ReponseQuestionnaire r) { return ResponseEntity.ok(service.enregistrer(r)); }
}


