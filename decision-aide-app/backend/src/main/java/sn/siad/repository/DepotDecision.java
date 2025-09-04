package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Decision;

public interface DepotDecision extends JpaRepository<Decision, Long> {
}


