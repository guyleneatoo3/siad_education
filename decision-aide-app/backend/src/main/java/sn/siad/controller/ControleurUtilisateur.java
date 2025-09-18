package sn.siad.controller;

import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Utilisateur;
import sn.siad.repository.DepotUtilisateur;

import java.util.Map;
import java.util.Optional; // Import nécessaire

@RestController
@RequestMapping("/api/utilisateurs")
@Validated
public class ControleurUtilisateur { // Début de la classe

    private final DepotUtilisateur depotUtilisateur;
    private final PasswordEncoder passwordEncoder;

    public ControleurUtilisateur(DepotUtilisateur depotUtilisateur, PasswordEncoder passwordEncoder) {
        this.depotUtilisateur = depotUtilisateur;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Correction : Méthode d'ajout déplacée ici.
     * Cette méthode suppose que le corps de la requête (Utilisateur user) contient
     * au moins le nomComplet, l'email et le rôle (et potentiellement l'établissementId, 
     * bien que la gestion de l'établissement soit souvent dans un autre service).
     *
     * Remarque : Le mot de passe par défaut est renvoyé dans le corps de la réponse.
     */
    @PostMapping("/ajouter")
    public ResponseEntity<?> ajouterUtilisateur(@RequestBody Utilisateur user) {
        if (user.getEmail() != null && depotUtilisateur.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email déjà utilisé"));
        }
        
        // Sécurité : Le mot de passe par défaut ne doit jamais être stocké en clair.
        final String defaultPassword = "changeme"; 
        
        // Mot de passe par défaut encodé
        user.setMotDePasse(passwordEncoder.encode(defaultPassword));
        user.setActif(true); 

        depotUtilisateur.save(user);

        // Réponse avec le mot de passe par défaut (peut être un risque de sécurité, 
        // à utiliser uniquement si c'est la politique de l'application).
        return ResponseEntity.ok(Map.of("message", "Utilisateur créé avec mot de passe par défaut", 
                                       "motDePasseInitial", defaultPassword)); 
    }

    // -------------------------------------------------------------------------
    // Reste des méthodes existantes
    // -------------------------------------------------------------------------

    @GetMapping("/me")
    public ResponseEntity<?> moi(Authentication authentication) {
        String identifiant = authentication.getName();
        Utilisateur u = depotUtilisateur.findByEmail(identifiant)
                .orElseGet(() -> depotUtilisateur.findByMatricule(identifiant).orElse(null));
        return ResponseEntity.ok(u);
    }

    public record ChangementMotDePasse(@NotBlank String ancienMotDePasse, @NotBlank String nouveauMotDePasse) {}

    @PatchMapping("/mot-de-passe")
    public ResponseEntity<?> changerMotDePasse(Authentication auth, @RequestBody ChangementMotDePasse req) {
        String identifiant = auth.getName();
        Utilisateur u = depotUtilisateur.findByEmail(identifiant)
                .orElseGet(() -> depotUtilisateur.findByMatricule(identifiant).orElse(null));
        if (u == null) return ResponseEntity.badRequest().body(Map.of("message", "Utilisateur introuvable"));
        if (!passwordEncoder.matches(req.ancienMotDePasse(), u.getMotDePasse())) {
            return ResponseEntity.status(403).body(Map.of("message", "Ancien mot de passe incorrect"));
        }
        u.setMotDePasse(passwordEncoder.encode(req.nouveauMotDePasse()));
        depotUtilisateur.save(u);
        return ResponseEntity.ok(Map.of("message", "Mot de passe modifié"));
    }

    @GetMapping("/profil")
    public ResponseEntity<?> profilActuel(Authentication authentication) {
        String identifiant = authentication.getName();
        Utilisateur u = depotUtilisateur.findByEmail(identifiant)
                .orElseGet(() -> depotUtilisateur.findByMatricule(identifiant).orElse(null));
        if (u == null) return ResponseEntity.badRequest().body(Map.of("message", "Utilisateur introuvable"));
        
        // Construction du profil enrichi
        Map<String, Object> profil = new java.util.HashMap<>();
        profil.put("id", u.getId());
        profil.put("nomComplet", u.getNomComplet());
        profil.put("email", u.getEmail());
        profil.put("role", u.getRole() != null ? u.getRole().name() : null);
        profil.put("actif", u.isActif());
        if (u.getEtablissement() != null) {
            profil.put("etablissementId", u.getEtablissement().getId());
            profil.put("etablissementNom", u.getEtablissement().getNom());
        }
        return ResponseEntity.ok(profil);
    }

    @GetMapping("/email-existe")
    public Map<String, Object> emailExiste(@RequestParam String email) {
        boolean existe = depotUtilisateur.findByEmail(email).isPresent();
        return Map.of("existe", existe);
    }
} 