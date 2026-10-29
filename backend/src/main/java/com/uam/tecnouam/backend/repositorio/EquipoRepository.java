package com.uam.tecnouam.backend.repositorio;

import com.uam.tecnouam.backend.modelo.Equipo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EquipoRepository extends JpaRepository<Equipo, Long> {
    Optional<Equipo> findByCodigoPatrimonial(String codigoPatrimonial);

    boolean existsByCodigoPatrimonial(String codigoPatrimonial);
}
