package sn.siad.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "etablissements")
@Getter
@Setter
public class Etablissement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nom;
    private String email;
    private String ville;
    private String arrondissement;
    private String departement;
    private String region;
    private boolean actif = false;
}


