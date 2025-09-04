package sn.siad.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.Instant;

@Entity
@Table(name = "utilisateurs")
@Getter
@Setter
public class Utilisateur {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nomComplet;
    @Column(unique = true)
    private String email; // pour enseignants, admin, inspection, ministere

    @Column(unique = true)
    private String matricule; // pour eleves

    private String motDePasse;

    @Enumerated(EnumType.STRING)
    private RoleUtilisateur role;

    private boolean actif = true;

    @ManyToOne
    private Etablissement etablissement;

    private Instant creeLe = Instant.now();
}


