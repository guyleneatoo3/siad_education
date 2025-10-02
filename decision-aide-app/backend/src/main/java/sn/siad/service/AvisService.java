package com.siad.education.service;

import com.siad.education.model.Avis;
import com.siad.education.repository.AvisRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AvisService {
    @Autowired
    private AvisRepository avisRepository;

    public Avis save(Avis avis) {
        return avisRepository.save(avis);
    }

    public List<Avis> getAvisByRapportAndType(Long rapportId, String type) {
        return avisRepository.findByRapportIdAndType(rapportId, type);
    }
}
