package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;

import org.springframework.web.bind.annotation.*;
import sn.siad.model.Etablissement;
import sn.siad.repository.DepotEtablissement;
import sn.siad.repository.DepotUtilisateur;
import sn.siad.model.Utilisateur;
import sn.siad.service.ServiceEtablissement;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.Optional;
import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("/api/etablissements")
public class ControleurEtablissement {
    private final ServiceEtablissement service;
    private final DepotEtablissement depotEtablissement;
    private final DepotUtilisateur depotUtilisateur;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @Autowired
    public ControleurEtablissement(
            ServiceEtablissement service,
            DepotEtablissement depotEtablissement,
            DepotUtilisateur depotUtilisateur,
            org.springframework.security.crypto.password.PasswordEncoder passwordEncoder) {
        this.service = service;
        this.depotEtablissement = depotEtablissement;
        this.depotUtilisateur = depotUtilisateur;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('INSPECTION','ADMINISTRATEUR')")
    public List<Etablissement> lister() {
        return service.lister();
    }

    @PostMapping("/{id}/activation")
    @PreAuthorize("hasRole('INSPECTION')")
    public ResponseEntity<Etablissement> activer(@PathVariable Long id, @RequestBody Map<String, Object> body) {
       
        boolean actif = Boolean.TRUE.equals(body.get("actif"));
        System.out.println("Activation request body: " + actif);
        Optional<Etablissement> opt = service.trouverParId(id);
       
        if (opt.isPresent()) {
            Etablissement e = opt.get();
            Utilisateur user = depotUtilisateur.findByEmail(e.getEmail()).get();
            e.setActif(actif);
            user.setActif(actif);
            
            service.enregistrer(e);
            depotUtilisateur.save(user);
            return ResponseEntity.ok(e);
        }
        return ResponseEntity.notFound().build();
    }
    // Lister les élèves d'un établissement
    @GetMapping("/{etabId}/eleves")
    @PreAuthorize("hasAnyRole('ETABLISSEMENT','INSPECTION','ADMINISTRATEUR')")
    public List<Utilisateur> listerEleves(@PathVariable Long etabId) {
        return service.listerEleves(etabId);
    }

    // Lister les enseignants d'un établissement
    @GetMapping("/{etabId}/enseignants")
    @PreAuthorize("hasAnyRole('ETABLISSEMENT','INSPECTION','ADMINISTRATEUR')")
    public List<Utilisateur> listerEnseignants(@PathVariable Long etabId) {
        return service.listerEnseignants(etabId);
    }

    // Ajouter un élève
    @PostMapping("/{etabId}/eleves")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public Utilisateur ajouterEleve(@PathVariable Long etabId, @RequestBody Utilisateur eleve) {
        return service.ajouterEleve(etabId, eleve);
    }

    // Modifier un élève
    @PutMapping("/{etabId}/eleves/{id}")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public Utilisateur modifierEleve(@PathVariable Long etabId, @PathVariable Long id, @RequestBody Utilisateur eleve) {
        return service.modifierUtilisateur(etabId, id, eleve);
    }

    // Supprimer un élève
    @DeleteMapping("/{etabId}/eleves/{id}")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public ResponseEntity<Void> supprimerEleve(@PathVariable Long etabId, @PathVariable Long id) {
        service.supprimerUtilisateur(id);
        return ResponseEntity.noContent().build();
    }

    // Ajouter un enseignant
    @PostMapping("/{etabId}/enseignants")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public Utilisateur ajouterEnseignant(@PathVariable Long etabId, @RequestBody Utilisateur enseignant) {
        return service.ajouterEnseignant(etabId, enseignant);
    }

    // Modifier un enseignant
    @PutMapping("/{etabId}/enseignants/{id}")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public Utilisateur modifierEnseignant(@PathVariable Long etabId, @PathVariable Long id, @RequestBody Utilisateur enseignant) {
        return service.modifierUtilisateur(etabId, id, enseignant);
    }

    // Supprimer un enseignant
    @DeleteMapping("/{etabId}/enseignants/{id}")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public ResponseEntity<Void> supprimerEnseignant(@PathVariable Long etabId, @PathVariable Long id) {
        service.supprimerUtilisateur(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/inscription")
    public ResponseEntity<?> inscrireEtablissement(@RequestBody Map<String, Object> req) {
        // Extraction des champs
        System.out.println("Requête d'inscription reçue: " + req);
        String nom = (String) req.get("nom");
        String email = (String) req.get("email");
        String ville = (String) req.get("ville");
        String arrondissement = (String) req.get("arrondissement");
        String departement = (String) req.get("departement");
        String region = (String) req.get("region");
        String motDePasse = (String) req.get("motDePasse");
        if (nom == null || email == null || ville == null || arrondissement == null || departement == null || region == null || motDePasse == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "Champs manquants"));
        }
        // Création de l'établissement inactif
        Etablissement etab = new Etablissement();
        etab.setNom(nom);
        etab.setEmail(email);
        etab.setVille(ville);
        etab.setArrondissement(arrondissement);
        etab.setDepartement(departement);
        etab.setRegion(region);
        etab.setActif(false); // Doit être activé par l'inspection
        etab = depotEtablissement.save(etab);
        // Création du gestionnaire établissement
        Utilisateur gest = new Utilisateur();
        gest.setNomComplet("Gestionnaire " + nom);
        gest.setEmail(email);
        gest.setMotDePasse(passwordEncoder.encode(motDePasse));
        gest.setRole(sn.siad.model.RoleUtilisateur.ETABLISSEMENT);
        gest.setEtablissement(etab);
        gest.setActif(false); // Doit être activé par l'inspection
        depotUtilisateur.save(gest);

        return ResponseEntity.status(201).body(Map.of("message", "Inscription enregistrée. En attente de validation par l'inspection."));
   
    }
}


