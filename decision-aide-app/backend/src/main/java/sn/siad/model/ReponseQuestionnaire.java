package sn.siad.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "reponses_questionnaires")
@Getter
@Setter
public class ReponseQuestionnaire {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "questionnaire_id", nullable = false)
    private Questionnaire questionnaire;

    @ManyToOne(optional = false)
    @JoinColumn(name = "auteur_id", nullable = false)
    private Utilisateur auteur; // eleve / enseignant

    @Lob // Utilise Lob au lieu de columnDefinition
    @Column(name = "contenu_json", nullable = true) // nullable selon ton besoin
    private String contenuJson; // réponses en JSON

    @Column(name = "soumis_le", nullable = false, updatable = false)
    private Instant soumisLe;

    // Initialisation de la date à la création de l'entité
    @PrePersist
    protected void onCreate() {
        if (soumisLe == null) {
            soumisLe = Instant.now();
        }
    }
}
