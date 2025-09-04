package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Questionnaire;

public interface DepotQuestionnaire extends JpaRepository<Questionnaire, Long> {
}


