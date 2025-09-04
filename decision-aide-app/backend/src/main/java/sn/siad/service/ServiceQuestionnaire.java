package sn.siad.service;

import org.springframework.stereotype.Service;
import sn.siad.model.Questionnaire;
import sn.siad.repository.DepotQuestionnaire;

import java.util.List;

@Service
public class ServiceQuestionnaire {
    private final DepotQuestionnaire depot;

    public ServiceQuestionnaire(DepotQuestionnaire depot) {
        this.depot = depot;
    }

    public Questionnaire creer(Questionnaire q) { return depot.save(q); }
    public List<Questionnaire> lister() { return depot.findAll(); }
}


