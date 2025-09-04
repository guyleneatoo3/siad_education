package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Questionnaire;
import sn.siad.service.ServiceQuestionnaire;

import java.util.List;

@RestController
@RequestMapping("/api/questionnaires")
public class ControleurQuestionnaire {
    private final ServiceQuestionnaire service;

    public ControleurQuestionnaire(ServiceQuestionnaire service) { this.service = service; }

    @GetMapping
    public List<Questionnaire> lister() { return service.lister(); }

    @PostMapping
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<Questionnaire> creer(@RequestBody Questionnaire q) { return ResponseEntity.ok(service.creer(q)); }
}


