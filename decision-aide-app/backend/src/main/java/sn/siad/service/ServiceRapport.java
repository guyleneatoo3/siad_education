package sn.siad.service;

import org.springframework.stereotype.Service;
import sn.siad.model.RapportAnalyse;
import sn.siad.repository.DepotRapportAnalyse;

import java.util.List;

@Service
public class ServiceRapport {
    private final DepotRapportAnalyse depot;

    public ServiceRapport(DepotRapportAnalyse depot) {
        this.depot = depot;
    }

    public RapportAnalyse creer(RapportAnalyse r) { return depot.save(r); }
    public List<RapportAnalyse> lister() { return depot.findAll(); }
}


