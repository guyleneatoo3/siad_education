package sn.siad.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class ConfigurationSecurite {

    private final JwtFiltre jwtFiltre;
    private final org.springframework.security.core.userdetails.UserDetailsService userDetailsService;

    public ConfigurationSecurite(@Lazy JwtFiltre jwtFiltre,
                                 @Lazy org.springframework.security.core.userdetails.UserDetailsService userDetailsService) {
        this.jwtFiltre = jwtFiltre;
        this.userDetailsService = userDetailsService;
    }

    @Bean
    public SecurityFilterChain filtre(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(configurationCors()))
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**", "/api/public/**","/api/decisions/**","/api/etablissements/**","/api/import/**","/api/inspection/**","/api/questionnaires/**","/api/rapports/**","/api/reponses/**","/api/utilisateurs/**").permitAll()
                .anyRequest().authenticated()
            );

        http.authenticationProvider(fournisseurAuthentification());
        http.addFilterBefore(jwtFiltre, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public PasswordEncoder encodeur() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager gestionnaireAuthentification(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }

    @Bean
    public DaoAuthenticationProvider fournisseurAuthentification() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(encodeur());
        return provider;
    }

    @Bean
    public CorsConfigurationSource configurationCors() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Autoriser tous les localhost (Flutter, React, etc.)
        configuration.addAllowedOriginPattern("http://localhost:*");
        configuration.addAllowedOriginPattern("http://127.0.0.1:*");

        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        configuration.setAllowCredentials(false); // Important si on utilise "*"

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
