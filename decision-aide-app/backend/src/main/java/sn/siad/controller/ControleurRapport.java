package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.RapportAnalyse;
import sn.siad.service.ServiceRapport;

import java.util.List;

@RestController
@RequestMapping("/api/rapports")
public class ControleurRapport {
    private final ServiceRapport service;

    public ControleurRapport(ServiceRapport service) { this.service = service; }

    @GetMapping
    @PreAuthorize("hasAnyRole('INSPECTION','MINISTERE','ADMINISTRATEUR')")
    public List<RapportAnalyse> lister() { return service.lister(); }

    @PostMapping
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<RapportAnalyse> creer(@RequestBody RapportAnalyse r) { return ResponseEntity.ok(service.creer(r)); }
}


