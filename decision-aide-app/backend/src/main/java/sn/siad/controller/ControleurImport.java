package sn.siad.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import sn.siad.model.Etablissement;
import sn.siad.model.Utilisateur;
import sn.siad.repository.DepotEtablissement;
import sn.siad.repository.DepotUtilisateur;
import sn.siad.service.ServiceImportExcel;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/import")
public class ControleurImport {

    private final ServiceImportExcel serviceImport;
    private final DepotUtilisateur depotUtilisateur;
    private final DepotEtablissement depotEtablissement;

    public ControleurImport(ServiceImportExcel serviceImport,
                           DepotUtilisateur depotUtilisateur,
                           DepotEtablissement depotEtablissement) {
        this.serviceImport = serviceImport;
        this.depotUtilisateur = depotUtilisateur;
        this.depotEtablissement = depotEtablissement;
    }

    @PostMapping("/eleves")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public ResponseEntity<?> importerEleves(@RequestParam("file") MultipartFile file,
                                          Authentication auth) {
        // Récupérer l'établissement de l'utilisateur connecté
        String email = auth.getName();
        Optional<Utilisateur> utilisateur = depotUtilisateur.findByEmail(email);
        if (utilisateur.isEmpty() || utilisateur.get().getEtablissement() == null) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Utilisateur non associé à un établissement"));
        }

        Etablissement etablissement = utilisateur.get().getEtablissement();
        
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Fichier vide"));
        }

        if (!file.getOriginalFilename().endsWith(".xlsx")) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Format de fichier non supporté. Utilisez .xlsx"));
        }

        try {
            Map<String, Object> resultat = serviceImport.importerEleves(file, etablissement);
            return ResponseEntity.ok(resultat);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Erreur lors de l'import: " + e.getMessage()));
        }
    }

    @PostMapping("/enseignants")
    @PreAuthorize("hasRole('ETABLISSEMENT')")
    public ResponseEntity<?> importerEnseignants(@RequestParam("file") MultipartFile file,
                                                Authentication auth) {
        // Récupérer l'établissement de l'utilisateur connecté
        String email = auth.getName();
        Optional<Utilisateur> utilisateur = depotUtilisateur.findByEmail(email);
        if (utilisateur.isEmpty() || utilisateur.get().getEtablissement() == null) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Utilisateur non associé à un établissement"));
        }

        Etablissement etablissement = utilisateur.get().getEtablissement();
        
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Fichier vide"));
        }

        if (!file.getOriginalFilename().endsWith(".xlsx")) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Format de fichier non supporté. Utilisez .xlsx"));
        }

        try {
            Map<String, Object> resultat = serviceImport.importerEnseignants(file, etablissement);
            return ResponseEntity.ok(resultat);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("erreur", "Erreur lors de l'import: " + e.getMessage()));
        }
    }
}
