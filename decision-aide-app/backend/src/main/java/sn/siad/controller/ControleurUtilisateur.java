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

@RestController
@RequestMapping("/api/utilisateurs")
@Validated
public class ControleurUtilisateur {

    private final DepotUtilisateur depotUtilisateur;
    private final PasswordEncoder passwordEncoder;

    public ControleurUtilisateur(DepotUtilisateur depotUtilisateur, PasswordEncoder passwordEncoder) {
        this.depotUtilisateur = depotUtilisateur;
        this.passwordEncoder = passwordEncoder;
    }

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
}


