
package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Questionnaire;
import sn.siad.service.ServiceQuestionnaire;
import java.util.Map;
import java.util.List;
import java.time.LocalDateTime;
import java.time.ZoneOffset;


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

    @PatchMapping("/{id}/partage")
@PreAuthorize("hasRole('INSPECTION')")
public ResponseEntity<Questionnaire> partager(@PathVariable Long id, @RequestBody Map<String, Object> body) {
    Questionnaire q = service.trouverParId(id);
    if (q == null) return ResponseEntity.notFound().build();
    q.setPartage(Boolean.TRUE.equals(body.get("partage")));
    if (body.get("dateFinPartage") != null) {
        String dateStr = body.get("dateFinPartage").toString();
        // Gère les deux formats : avec ou sans 'Z'
        if (dateStr.endsWith("Z")) {
            q.setDateFinPartage(java.time.Instant.parse(dateStr));
        } else {
            LocalDateTime ldt = LocalDateTime.parse(dateStr);
            q.setDateFinPartage(ldt.toInstant(ZoneOffset.UTC));
        }
    }
    service.enregistrer(q);
    return ResponseEntity.ok(q);
}
}


