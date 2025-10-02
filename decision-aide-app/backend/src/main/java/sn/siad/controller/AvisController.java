package com.siad.education.controller;

import com.siad.education.model.Avis;
import com.siad.education.service.AvisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/avis")
public class AvisController {
    @Autowired
    private AvisService avisService;

    @PostMapping
    public Avis ajouterAvis(@RequestBody Avis avis) {
        return avisService.save(avis);
    }

    @GetMapping("/rapport/{rapportId}/type/{type}")
    public List<Avis> getAvisByRapportAndType(@PathVariable Long rapportId, @PathVariable String type) {
        return avisService.getAvisByRapportAndType(rapportId, type);
    }
}
