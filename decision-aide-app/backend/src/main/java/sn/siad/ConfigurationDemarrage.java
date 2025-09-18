package sn.siad;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import sn.siad.model.Etablissement;
import sn.siad.model.RoleUtilisateur;
import sn.siad.model.Utilisateur;
import sn.siad.repository.DepotEtablissement;
import sn.siad.repository.DepotUtilisateur;

@Configuration
public class ConfigurationDemarrage {

    @Bean
    CommandLineRunner initialiserDonnees(DepotUtilisateur depotUtilisateur, DepotEtablissement depotEtablissement, PasswordEncoder encoder) {
        return args -> {
            if (depotUtilisateur.count() == 0) {
                Etablissement etab = new Etablissement();
                etab.setNom("Lycée Exemple");
                etab.setEmail("contact@lycee-exemple.sn");
                etab.setVille("Dakar");
                etab.setRegion("Dakar");
                etab.setActif(true);
                etab = depotEtablissement.save(etab);
                

                
                Utilisateur admin = new Utilisateur();
                admin.setNomComplet("Admin Système");
                admin.setEmail("admin@gmail.com");
                admin.setMotDePasse(encoder.encode("admin123"));
                admin.setRole(RoleUtilisateur.ADMINISTRATEUR);
                admin.setActif(true);
                depotUtilisateur.save(admin);

                Utilisateur insp = new Utilisateur();
                insp.setNomComplet("Inspecteur Académique");
                insp.setEmail("inspection@gmail.com");
                    insp.setMotDePasse(encoder.encode("")); // Suppression de la ligne invalide
                insp.setRole(RoleUtilisateur.INSPECTION);
                insp.setActif(true);
                depotUtilisateur.save(insp);

                Utilisateur min = new Utilisateur();
                min.setNomComplet("Responsable Ministère");
                min.setEmail("ministere@gmail.com");
                min.setMotDePasse(encoder.encode("minist123"));
                min.setRole(RoleUtilisateur.MINISTERE);
                min.setActif(true);
                depotUtilisateur.save(min);

                Utilisateur gestEtab = new Utilisateur();
                gestEtab.setNomComplet("Gestion Etablissement");
                gestEtab.setEmail("etab@gmail.com");
                gestEtab.setMotDePasse(encoder.encode("etab123"));
                gestEtab.setRole(RoleUtilisateur.ETABLISSEMENT);
                gestEtab.setEtablissement(etab);
                gestEtab.setActif(true);
                depotUtilisateur.save(gestEtab);
            }
        };
    }
}


