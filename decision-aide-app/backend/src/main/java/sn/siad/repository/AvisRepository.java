package com.siad.education.repository;

import com.siad.education.model.Avis;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvisRepository extends JpaRepository<Avis, Long> {
    List<Avis> findByRapportIdAndType(Long rapportId, String type);
}
