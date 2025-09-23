package sn.siad.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.siad.model.Questionnaire;

import java.util.List;
import sn.siad.model.Utilisateur;

public interface DepotQuestionnaire extends JpaRepository<Questionnaire, Long> {
	List<Questionnaire> findByCreePar(Utilisateur utilisateur);
	List<Questionnaire> findByDestinataire(String destinataire);
}


