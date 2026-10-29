package com.uam.tecnouam.backend.servicio;

import com.uam.tecnouam.backend.dto.PrestamoRequest;
import com.uam.tecnouam.backend.excepcion.ConflictoNegocioException;
import com.uam.tecnouam.backend.excepcion.RecursoNoEncontradoException;
import com.uam.tecnouam.backend.excepcion.SolicitudInvalidaException;
import com.uam.tecnouam.backend.modelo.Equipo;
import com.uam.tecnouam.backend.modelo.EstadoEquipo;
import com.uam.tecnouam.backend.modelo.EstadoPrestamo;
import com.uam.tecnouam.backend.modelo.Prestamo;
import com.uam.tecnouam.backend.repositorio.EquipoRepository;
import com.uam.tecnouam.backend.repositorio.PrestamoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class PrestamoService {

    private final PrestamoRepository prestamoRepository;
    private final EquipoRepository equipoRepository;

    public PrestamoService(PrestamoRepository prestamoRepository, EquipoRepository equipoRepository) {
        this.prestamoRepository = prestamoRepository;
        this.equipoRepository = equipoRepository;
    }

    public List<Prestamo> listar() {
        return prestamoRepository.findAll();
    }

    public Prestamo obtener(Long id) {
        return prestamoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Prestamo no encontrado con id " + id));
    }

    @Transactional
    public Prestamo registrar(PrestamoRequest request) {
        if (request.getFechaDevolucionPrevista().isBefore(request.getFechaPrestamo())) {
            throw new SolicitudInvalidaException("La fecha prevista de devolucion no puede ser anterior a la fecha del prestamo");
        }

        Equipo equipo = equipoRepository.findById(request.getEquipoId())
                .orElseThrow(() -> new RecursoNoEncontradoException("Equipo no encontrado con id " + request.getEquipoId()));

        if (equipo.getEstado() == EstadoEquipo.PRESTADO) {
            throw new ConflictoNegocioException("El equipo ya se encuentra PRESTADO");
        }

        Prestamo prestamo = new Prestamo();
        prestamo.setEquipo(equipo);
        prestamo.setNombreSolicitante(request.getNombreSolicitante());
        prestamo.setFechaPrestamo(request.getFechaPrestamo());
        prestamo.setFechaDevolucionPrevista(request.getFechaDevolucionPrevista());
        prestamo.setEstado(EstadoPrestamo.ACTIVO);

        equipo.setEstado(EstadoEquipo.PRESTADO);
        equipoRepository.save(equipo);

        return prestamoRepository.save(prestamo);
    }

    @Transactional
    public Prestamo devolver(Long id) {
        Prestamo prestamo = obtener(id);

        if (prestamo.getEstado() == EstadoPrestamo.DEVUELTO) {
            throw new ConflictoNegocioException("El prestamo ya fue devuelto");
        }

        prestamo.setEstado(EstadoPrestamo.DEVUELTO);
        prestamo.setFechaDevolucionReal(LocalDate.now());

        Equipo equipo = prestamo.getEquipo();
        equipo.setEstado(EstadoEquipo.DISPONIBLE);
        equipoRepository.save(equipo);

        return prestamoRepository.save(prestamo);
    }
}
