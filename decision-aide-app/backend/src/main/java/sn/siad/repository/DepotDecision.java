package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Decision;

import java.util.List;

public interface DepotDecision extends JpaRepository<Decision, Long> {
    List<Decision> findByPublieTrue();
}


