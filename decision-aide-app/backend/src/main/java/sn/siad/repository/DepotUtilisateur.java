package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Etablissement;
import sn.siad.model.Utilisateur;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface DepotUtilisateur extends JpaRepository<Utilisateur, Long> {
    Optional<Utilisateur> findByEmail(String email);
    Optional<Utilisateur> findByMatricule(String matricule);
    List<Utilisateur> findByEtablissement(Etablissement etablissement);

    // Find by etablissement id and role name
    @Query("SELECT u FROM Utilisateur u WHERE u.etablissement.id = :etabId AND u.role = :role")
    List<Utilisateur> findByEtablissementIdAndRole(@Param("etabId") Long etabId, @Param("role") sn.siad.model.RoleUtilisateur role);
}


