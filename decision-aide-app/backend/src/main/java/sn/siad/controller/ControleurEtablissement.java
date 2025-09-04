package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Etablissement;
import sn.siad.repository.DepotEtablissement;

import java.util.List;

@RestController
@RequestMapping("/api/etablissements")
public class ControleurEtablissement {
    private final DepotEtablissement depot;

    public ControleurEtablissement(DepotEtablissement depot) { this.depot = depot; }

    @GetMapping
    @PreAuthorize("hasAnyRole('INSPECTION','ADMINISTRATEUR')")
    public List<Etablissement> lister() { return depot.findAll(); }

    @PatchMapping("/{id}/activation")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<Etablissement> activer(@PathVariable Long id, @RequestParam boolean actif) {
        return depot.findById(id)
                .map(e -> { e.setActif(actif); return ResponseEntity.ok(depot.save(e)); })
                .orElse(ResponseEntity.notFound().build());
    }
}


