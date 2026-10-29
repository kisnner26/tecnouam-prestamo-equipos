package com.uam.tecnouam.backend.repositorio;

import com.uam.tecnouam.backend.modelo.Equipo;
import com.uam.tecnouam.backend.modelo.EstadoPrestamo;
import com.uam.tecnouam.backend.modelo.Prestamo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PrestamoRepository extends JpaRepository<Prestamo, Long> {
    Optional<Prestamo> findByEquipoAndEstado(Equipo equipo, EstadoPrestamo estado);

    List<Prestamo> findByEquipo(Equipo equipo);

    boolean existsByEquipoAndEstado(Equipo equipo, EstadoPrestamo estado);
}
