package sn.siad.service;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.siad.model.Etablissement;
import sn.siad.model.RoleUtilisateur;
import sn.siad.model.Utilisateur;
import sn.siad.repository.DepotEtablissement;
import sn.siad.repository.DepotUtilisateur;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Service
public class ServiceUtilisateur implements UserDetailsService {

    private final DepotUtilisateur depotUtilisateur;
    private final DepotEtablissement depotEtablissement;
    private final PasswordEncoder passwordEncoder;

    public ServiceUtilisateur(DepotUtilisateur depotUtilisateur,
                              DepotEtablissement depotEtablissement,
                              PasswordEncoder passwordEncoder) {
        this.depotUtilisateur = depotUtilisateur;
        this.depotEtablissement = depotEtablissement;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Optional<Utilisateur> parEmail = depotUtilisateur.findByEmail(username);
        Utilisateur u = parEmail.orElseGet(() -> depotUtilisateur.findByMatricule(username)
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur introuvable")));

        Collection<? extends GrantedAuthority> roles = List.of(new SimpleGrantedAuthority("ROLE_" + u.getRole().name()));
        return new User(u.getEmail() != null ? u.getEmail() : u.getMatricule(), u.getMotDePasse(),
                u.isActif(), true, true, true, roles);
    }

    @Transactional
    public Etablissement enregistrerEtablissement(Etablissement e, String motDePasseAdmin) {
        Etablissement saved = depotEtablissement.save(e);
        // Créer un utilisateur Etablissement (compte principal)
        Utilisateur gestion = new Utilisateur();
        gestion.setNomComplet(e.getNom());
        gestion.setEmail(e.getEmail());
        gestion.setRole(RoleUtilisateur.ETABLISSEMENT);
        gestion.setMotDePasse(passwordEncoder.encode(motDePasseAdmin));
        gestion.setActif(false); // en attente d'activation par inspection
        gestion.setEtablissement(saved);
        depotUtilisateur.save(gestion);
        return saved;
    }
}
