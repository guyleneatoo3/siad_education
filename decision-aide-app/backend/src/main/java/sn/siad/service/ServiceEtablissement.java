package sn.siad.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import sn.siad.model.Etablissement;
import sn.siad.model.Utilisateur;
import sn.siad.repository.DepotEtablissement;
import sn.siad.repository.DepotUtilisateur;

import java.util.List;
import java.util.Optional;

@Service
public class ServiceEtablissement {
    @Autowired
    private DepotEtablissement depotEtablissement;
    @Autowired
    private DepotUtilisateur depotUtilisateur;

    public List<Etablissement> lister() {
        return depotEtablissement.findAll();
    }

    public Optional<Etablissement> trouverParId(Long id) {
        return depotEtablissement.findById(id);
    }

    public Etablissement enregistrer(Etablissement etab) {
        return depotEtablissement.save(etab);
    }

    public boolean activer(Long id, boolean actif) {
        Optional<Etablissement> opt = depotEtablissement.findById(id);
        if (opt.isPresent()) {
            Etablissement e = opt.get();
            e.setActif(actif);
            depotEtablissement.save(e);
            return true;
        }
        return false;
    }

    public List<Utilisateur> listerEleves(Long etabId) {
    return depotUtilisateur.findByEtablissementIdAndRole(etabId, sn.siad.model.RoleUtilisateur.ELEVE);
    }

    public List<Utilisateur> listerEnseignants(Long etabId) {
    return depotUtilisateur.findByEtablissementIdAndRole(etabId, sn.siad.model.RoleUtilisateur.ENSEIGNANT);
    }

    public Utilisateur ajouterEleve(Long etabId, Utilisateur eleve) {
    eleve.setRole(sn.siad.model.RoleUtilisateur.ELEVE);
        eleve.setEtablissement(depotEtablissement.findById(etabId).orElse(null));
        return depotUtilisateur.save(eleve);
    }

    public Utilisateur ajouterEnseignant(Long etabId, Utilisateur enseignant) {
    enseignant.setRole(sn.siad.model.RoleUtilisateur.ENSEIGNANT);
        enseignant.setEtablissement(depotEtablissement.findById(etabId).orElse(null));
        return depotUtilisateur.save(enseignant);
    }

    public Utilisateur modifierUtilisateur(Long etabId, Long userId, Utilisateur utilisateur) {
        utilisateur.setId(userId);
        utilisateur.setEtablissement(depotEtablissement.findById(etabId).orElse(null));
        return depotUtilisateur.save(utilisateur);
    }

    public void supprimerUtilisateur(Long userId) {
        depotUtilisateur.deleteById(userId);
    }
}
