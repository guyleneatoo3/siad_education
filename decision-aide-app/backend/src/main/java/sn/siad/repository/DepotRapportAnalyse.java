package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.RapportAnalyse;
import sn.siad.model.Questionnaire;

public interface DepotRapportAnalyse extends JpaRepository<RapportAnalyse, Long> {
	RapportAnalyse findByQuestionnaire(Questionnaire questionnaire);
}


