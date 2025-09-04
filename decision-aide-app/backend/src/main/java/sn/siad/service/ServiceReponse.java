package sn.siad.service;

import org.springframework.stereotype.Service;
import sn.siad.model.ReponseQuestionnaire;
import sn.siad.repository.DepotReponseQuestionnaire;

import java.util.List;

@Service
public class ServiceReponse {
    private final DepotReponseQuestionnaire depot;

    public ServiceReponse(DepotReponseQuestionnaire depot) {
        this.depot = depot;
    }

    public ReponseQuestionnaire enregistrer(ReponseQuestionnaire r) { return depot.save(r); }
    public List<ReponseQuestionnaire> lister() { return depot.findAll(); }
}


