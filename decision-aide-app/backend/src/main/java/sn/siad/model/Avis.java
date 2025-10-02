package com.siad.education.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class Avis {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 1000)
    private String contenu;

    @Column(nullable = false)
    private String auteurNom;

    @Column(nullable = false)
    private String type; // ETAB_TO_INSPECTION ou INSPECTION_TO_MINISTERE

    @Column(nullable = false)
    private Long rapportId;

    private LocalDateTime date = LocalDateTime.now();

    public Avis() {}

    public Avis(String contenu, String auteurNom, String type, Long rapportId) {
        this.contenu = contenu;
        this.auteurNom = auteurNom;
        this.type = type;
        this.rapportId = rapportId;
        this.date = LocalDateTime.now();
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }
    public String getAuteurNom() { return auteurNom; }
    public void setAuteurNom(String auteurNom) { this.auteurNom = auteurNom; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Long getRapportId() { return rapportId; }
    public void setRapportId(Long rapportId) { this.rapportId = rapportId; }
    public LocalDateTime getDate() { return date; }
    public void setDate(LocalDateTime date) { this.date = date; }
}
