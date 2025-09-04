package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Etablissement;
import sn.siad.model.Utilisateur;
import java.util.List;
import java.util.Optional;

public interface DepotUtilisateur extends JpaRepository<Utilisateur, Long> {
    Optional<Utilisateur> findByEmail(String email);
    Optional<Utilisateur> findByMatricule(String matricule);
    List<Utilisateur> findByEtablissement(Etablissement etablissement);
}


