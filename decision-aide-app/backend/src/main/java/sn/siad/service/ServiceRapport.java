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

    public RapportAnalyse creer(RapportAnalyse r) {
        // Vérifie si un rapport existe déjà pour ce questionnaire
        RapportAnalyse existant = depot.findByQuestionnaire(r.getQuestionnaire());
        if (existant != null) {
            return existant; // Retourne le rapport existant, pas de doublon
        }
        return depot.save(r);
    }
    public List<RapportAnalyse> lister() { return depot.findAll(); }
}


