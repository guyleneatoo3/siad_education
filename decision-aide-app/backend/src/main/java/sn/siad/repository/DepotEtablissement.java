package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Etablissement;

public interface DepotEtablissement extends JpaRepository<Etablissement, Long> {
}


