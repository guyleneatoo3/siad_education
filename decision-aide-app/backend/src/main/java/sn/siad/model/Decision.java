package sn.siad.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "decisions")
@Getter
@Setter
public class Decision {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titre;

    @Column(columnDefinition = "TEXT")
    private String contenu; // texte decision

    private boolean publie = false;

    @ManyToOne
    private Utilisateur auteur; // ministere

    private Instant creeLe = Instant.now();
}


