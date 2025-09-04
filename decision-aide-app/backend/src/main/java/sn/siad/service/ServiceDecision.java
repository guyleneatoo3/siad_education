package sn.siad.service;

import org.springframework.stereotype.Service;
import sn.siad.model.Decision;
import sn.siad.repository.DepotDecision;

import java.util.List;

@Service
public class ServiceDecision {
    private final DepotDecision depot;

    public ServiceDecision(DepotDecision depot) {
        this.depot = depot;
    }

    public Decision creer(Decision d) { return depot.save(d); }
    public List<Decision> lister() { return depot.findAll(); }
}


