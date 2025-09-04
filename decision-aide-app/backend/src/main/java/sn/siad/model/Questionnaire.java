package sn.siad.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "questionnaires")
@Getter
@Setter
public class Questionnaire {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titre;
    @Column(columnDefinition = "TEXT")
    private String contenuJson; // JSON des questions générées

    @ManyToOne
    private Utilisateur creePar; // inspection

    private Instant creeLe = Instant.now();
}


