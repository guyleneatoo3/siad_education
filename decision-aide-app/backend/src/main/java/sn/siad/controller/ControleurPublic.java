package sn.siad.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import sn.siad.model.Decision;
import sn.siad.repository.DepotDecision;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/public")
public class ControleurPublic {
    private final DepotDecision depotDecision;

    public ControleurPublic(DepotDecision depotDecision) { this.depotDecision = depotDecision; }

    @GetMapping("/decisions")
    public List<Decision> decisionsPubliees() {
        return depotDecision.findAll().stream().filter(Decision::isPublie).collect(Collectors.toList());
    }
}


