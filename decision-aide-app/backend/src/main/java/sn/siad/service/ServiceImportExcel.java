package sn.siad.service;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import sn.siad.model.Etablissement;
import sn.siad.model.RoleUtilisateur;
import sn.siad.model.Utilisateur;
import sn.siad.repository.DepotUtilisateur;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class ServiceImportExcel {

    private final DepotUtilisateur depotUtilisateur;
    private final PasswordEncoder passwordEncoder;

    public ServiceImportExcel(DepotUtilisateur depotUtilisateur, PasswordEncoder passwordEncoder) {
        this.depotUtilisateur = depotUtilisateur;
        this.passwordEncoder = passwordEncoder;
    }

    public Map<String, Object> importerEleves(MultipartFile file, Etablissement etablissement) {
        List<String> erreurs = new ArrayList<>();
        List<String> succes = new ArrayList<>();
        int totalImportes = 0;

        try (InputStream is = file.getInputStream()) {
            Workbook workbook = new XSSFWorkbook(is);
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i <= sheet.getLastRowNum(); i++) { // Skip header row
                Row row = sheet.getRow(i);
                if (row == null) continue;

                try {
                    String matricule = getCellValueAsString(row.getCell(0));
                    String classe = getCellValueAsString(row.getCell(1));
                    String filiere = getCellValueAsString(row.getCell(2));

                    if (matricule == null || matricule.trim().isEmpty()) {
                        erreurs.add("Ligne " + (i + 1) + ": Matricule manquant");
                        continue;
                    }

                    // Vérifier si l'élève existe déjà
                    if (depotUtilisateur.findByMatricule(matricule).isPresent()) {
                        erreurs.add("Ligne " + (i + 1) + ": Élève avec matricule " + matricule + " existe déjà");
                        continue;
                    }

                    // Créer l'élève
                    Utilisateur eleve = new Utilisateur();
                    eleve.setMatricule(matricule);
                    eleve.setNomComplet("Élève " + matricule); // Nom temporaire
                    eleve.setRole(RoleUtilisateur.ELEVE);
                    eleve.setEtablissement(etablissement);
                    eleve.setActif(true);
                    eleve.setMotDePasse(passwordEncoder.encode("eleve123")); // Mot de passe par défaut

                    depotUtilisateur.save(eleve);
                    succes.add("Élève " + matricule + " importé avec succès");
                    totalImportes++;

                } catch (Exception e) {
                    erreurs.add("Ligne " + (i + 1) + ": " + e.getMessage());
                }
            }

            workbook.close();
        } catch (IOException e) {
            erreurs.add("Erreur lors de la lecture du fichier: " + e.getMessage());
        }

        return Map.of(
            "totalImportes", totalImportes,
            "succes", succes,
            "erreurs", erreurs
        );
    }

    public Map<String, Object> importerEnseignants(MultipartFile file, Etablissement etablissement) {
        List<String> erreurs = new ArrayList<>();
        List<String> succes = new ArrayList<>();
        int totalImportes = 0;

        try (InputStream is = file.getInputStream()) {
            Workbook workbook = new XSSFWorkbook(is);
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i <= sheet.getLastRowNum(); i++) { // Skip header row
                Row row = sheet.getRow(i);
                if (row == null) continue;

                try {
                    String email = getCellValueAsString(row.getCell(0));
                    String matiere = getCellValueAsString(row.getCell(1));

                    if (email == null || email.trim().isEmpty()) {
                        erreurs.add("Ligne " + (i + 1) + ": Email manquant");
                        continue;
                    }

                    // Vérifier si l'enseignant existe déjà
                    if (depotUtilisateur.findByEmail(email).isPresent()) {
                        erreurs.add("Ligne " + (i + 1) + ": Enseignant avec email " + email + " existe déjà");
                        continue;
                    }

                    // Créer l'enseignant
                    Utilisateur enseignant = new Utilisateur();
                    enseignant.setEmail(email);
                    enseignant.setNomComplet("Enseignant " + matiere); // Nom temporaire
                    enseignant.setRole(RoleUtilisateur.ENSEIGNANT);
                    enseignant.setEtablissement(etablissement);
                    enseignant.setActif(true);
                    enseignant.setMotDePasse(passwordEncoder.encode("enseignant123")); // Mot de passe par défaut

                    depotUtilisateur.save(enseignant);
                    succes.add("Enseignant " + email + " importé avec succès");
                    totalImportes++;

                } catch (Exception e) {
                    erreurs.add("Ligne " + (i + 1) + ": " + e.getMessage());
                }
            }

            workbook.close();
        } catch (IOException e) {
            erreurs.add("Erreur lors de la lecture du fichier: " + e.getMessage());
        }

        return Map.of(
            "totalImportes", totalImportes,
            "succes", succes,
            "erreurs", erreurs
        );
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) return null;
        
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                return String.valueOf((int) cell.getNumericCellValue());
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            default:
                return null;
        }
    }
}
