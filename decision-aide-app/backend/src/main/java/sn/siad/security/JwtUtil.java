package sn.siad.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.function.Function;

@Component
public class JwtUtil {
    @Value("${application.securite.jwt.secret}")
    private String secret;

    @Value("${application.securite.jwt.expiration-ms}")
    private long expirationMs;

    public String extraireNomUtilisateur(String token) {
        return extraireRevendication(token, Claims::getSubject);
    }

    public <T> T extraireRevendication(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extraireToutesRevendications(token);
        return claimsResolver.apply(claims);
    }

    private Claims extraireToutesRevendications(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(clef())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public String genererToken(String sujet) {
        Date maintenant = new Date();
        Date expiration = new Date(maintenant.getTime() + expirationMs);
        return Jwts.builder()
                .setSubject(sujet)
                .setIssuedAt(maintenant)
                .setExpiration(expiration)
                .signWith(clef(), SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean validerToken(String token, String sujetAttendu) {
        final String sujet = extraireNomUtilisateur(token);
        return sujet.equals(sujetAttendu) && !estExpire(token);
    }

    private boolean estExpire(String token) {
        return extraireRevendication(token, Claims::getExpiration).before(new Date());
    }

    private Key clef() {
        byte[] keyBytes = Decoders.BASE64.decode(secret);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}


