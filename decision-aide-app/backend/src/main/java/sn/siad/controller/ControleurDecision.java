package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Decision;
import sn.siad.service.ServiceDecision;

import java.util.List;

@RestController
@RequestMapping("/api/decisions")
public class ControleurDecision {
    private final ServiceDecision service;

    public ControleurDecision(ServiceDecision service) { this.service = service; }

    @GetMapping
    public List<Decision> lister() { return service.lister(); }

    @PostMapping
    @PreAuthorize("hasRole('MINISTERE')")
    public ResponseEntity<Decision> creer(@RequestBody Decision d) { return ResponseEntity.ok(service.creer(d)); }

    @PatchMapping("/{id}/publication")
    @PreAuthorize("hasRole('MINISTERE')")
    public ResponseEntity<Decision> publier(@PathVariable Long id, @RequestParam boolean publie) {
        return service.lister().stream().filter(dec -> dec.getId().equals(id)).findFirst()
                .map(dec -> { dec.setPublie(publie); return ResponseEntity.ok(service.creer(dec)); })
                .orElse(ResponseEntity.notFound().build());
    }
}


