package sn.siad.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "rapports_analyse")
@Getter
@Setter
public class RapportAnalyse {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titre;

    @Column(columnDefinition = "TEXT")
    private String resume; // texte généré (avis)

    @ManyToOne
    private Questionnaire questionnaire;

    private Instant creeLe = Instant.now();
}


