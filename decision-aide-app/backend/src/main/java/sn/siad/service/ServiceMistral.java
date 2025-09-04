package sn.siad.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ServiceMistral {

    @Value("${application.mistral.api.cle}")
    private String cleApi;

    @Value("${application.mistral.modele}")
    private String modele;

    @Value("${application.mistral.endpoint}")
    private String endpoint;

    public String genererQuestions(int nombre, String type) {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(cleApi);

        String prompt = "Génère " + nombre + " questions de type " + type + " pour l'évaluation pédagogique. Réponds en JSON avec un tableau 'questions' et champs: 'intitule', 'type', 'choix' (si QCM).";

        Map<String, Object> body = new HashMap<>();
        body.put("model", modele);
        body.put("messages", List.of(
                Map.of("role", "system", "content", "Tu es un assistant spécialisé en pédagogie."),
                Map.of("role", "user", "content", prompt)
        ));

        HttpEntity<Map<String, Object>> req = new HttpEntity<>(body, headers);
        Map<?, ?> res = rt.postForObject(endpoint, req, Map.class);
        if (res == null) return null;
        // Pour Mistral chat, le texte est généralement sous choices[0].message.content
        List<?> choices = (List<?>) res.get("choices");
        if (choices == null || choices.isEmpty()) return null;
        Map<?, ?> first = (Map<?, ?>) choices.get(0);
        Map<?, ?> message = (Map<?, ?>) first.get("message");
        return message != null ? (String) message.get("content") : null;
    }

    public String analyserReponses(String reponsesJson, String typeQuestionnaire) {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(cleApi);

        String prompt = String.format(
            "Analyse les réponses suivantes du questionnaire de type '%s' et génère un rapport pédagogique détaillé. " +
            "Le rapport doit inclure : 1) Un résumé des tendances principales, 2) Les points forts identifiés, " +
            "3) Les axes d'amélioration, 4) Des recommandations concrètes. " +
            "Réponses à analyser : %s",
            typeQuestionnaire, reponsesJson
        );

        Map<String, Object> body = new HashMap<>();
        body.put("model", modele);
        body.put("messages", List.of(
                Map.of("role", "system", "content", "Tu es un expert en analyse pédagogique et en évaluation éducative."),
                Map.of("role", "user", "content", prompt)
        ));

        HttpEntity<Map<String, Object>> req = new HttpEntity<>(body, headers);
        Map<?, ?> res = rt.postForObject(endpoint, req, Map.class);
        if (res == null) return null;
        
        List<?> choices = (List<?>) res.get("choices");
        if (choices == null || choices.isEmpty()) return null;
        Map<?, ?> first = (Map<?, ?>) choices.get(0);
        Map<?, ?> message = (Map<?, ?>) first.get("message");
        return message != null ? (String) message.get("content") : null;
    }

    public String genererRapportFinal(String analyseReponses, String avisInspection) {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(cleApi);

        String prompt = String.format(
            "Génère un rapport final pédagogique en combinant l'analyse automatique et l'avis de l'inspection. " +
            "Analyse automatique : %s\nAvis de l'inspection : %s\n\n" +
            "Le rapport final doit être structuré et professionnel, incluant des recommandations claires pour le Ministère.",
            analyseReponses, avisInspection
        );

        Map<String, Object> body = new HashMap<>();
        body.put("model", modele);
        body.put("messages", List.of(
                Map.of("role", "system", "content", "Tu es un expert en rédaction de rapports pédagogiques pour le Ministère de l'Éducation."),
                Map.of("role", "user", "content", prompt)
        ));

        HttpEntity<Map<String, Object>> req = new HttpEntity<>(body, headers);
        Map<?, ?> res = rt.postForObject(endpoint, req, Map.class);
        if (res == null) return null;
        
        List<?> choices = (List<?>) res.get("choices");
        if (choices == null || choices.isEmpty()) return null;
        Map<?, ?> first = (Map<?, ?>) choices.get(0);
        Map<?, ?> message = (Map<?, ?>) first.get("message");
        return message != null ? (String) message.get("content") : null;
    }
}


