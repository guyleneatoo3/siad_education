package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sn.siad.model.Etablissement;
import sn.siad.security.JwtUtil;
import sn.siad.service.ServiceUtilisateur;

import jakarta.validation.constraints.NotBlank;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Validated
public class ControleurAuth {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final ServiceUtilisateur serviceUtilisateur;

    public ControleurAuth(AuthenticationManager authenticationManager, JwtUtil jwtUtil, ServiceUtilisateur serviceUtilisateur) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.serviceUtilisateur = serviceUtilisateur;
    }

    public record DemandeConnexion(@NotBlank String identifiant, @NotBlank String motDePasse) {}

    @PostMapping("/connexion")
    public ResponseEntity<?> connexion(@RequestBody DemandeConnexion demande) {
        System.out.println("dans le controleur"+demande);
        Authentication auth = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(demande.identifiant(), demande.motDePasse()));
        System.out.println("dans le controleur 1"+auth );
        UserDetails user = (UserDetails) auth.getPrincipal();
        System.out.println("dans le controleur 2"+user);
        String token = jwtUtil.genererToken(user.getUsername());
        return ResponseEntity.ok(Map.of("jeton", token, "utilisateur", user.getUsername()));
    }

@GetMapping("/con")
public String connexion() {
    return "Guylene";
}

    @PostMapping("/inscription-etablissement")
    public ResponseEntity<?> inscriptionEtablissement(@RequestBody Etablissement e, @RequestParam("motPasse") String motPasse) {
        Etablissement saved = serviceUtilisateur.enregistrerEtablissement(e, motPasse);
        return ResponseEntity.ok(saved);
    }
}


