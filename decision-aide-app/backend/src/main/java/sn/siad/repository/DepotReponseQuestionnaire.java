package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Questionnaire;
import sn.siad.model.ReponseQuestionnaire;

import java.util.List;

public interface DepotReponseQuestionnaire extends JpaRepository<ReponseQuestionnaire, Long> {
    List<ReponseQuestionnaire> findByQuestionnaire(Questionnaire questionnaire);
}


