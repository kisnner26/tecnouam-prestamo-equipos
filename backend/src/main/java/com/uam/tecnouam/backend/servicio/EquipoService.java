package com.uam.tecnouam.backend.servicio;

import com.uam.tecnouam.backend.dto.EquipoRequest;
import com.uam.tecnouam.backend.excepcion.ConflictoNegocioException;
import com.uam.tecnouam.backend.excepcion.RecursoNoEncontradoException;
import com.uam.tecnouam.backend.modelo.Equipo;
import com.uam.tecnouam.backend.modelo.EstadoEquipo;
import com.uam.tecnouam.backend.modelo.EstadoPrestamo;
import com.uam.tecnouam.backend.repositorio.EquipoRepository;
import com.uam.tecnouam.backend.repositorio.PrestamoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class EquipoService {

    private final EquipoRepository equipoRepository;
    private final PrestamoRepository prestamoRepository;

    public EquipoService(EquipoRepository equipoRepository, PrestamoRepository prestamoRepository) {
        this.equipoRepository = equipoRepository;
        this.prestamoRepository = prestamoRepository;
    }

    public List<Equipo> listar() {
        return equipoRepository.findAll();
    }

    public Equipo obtener(Long id) {
        return equipoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Equipo no encontrado con id " + id));
    }

    @Transactional
    public Equipo crear(EquipoRequest request) {
        if (equipoRepository.existsByCodigoPatrimonial(request.getCodigoPatrimonial())) {
            throw new ConflictoNegocioException("Ya existe un equipo con el codigo patrimonial " + request.getCodigoPatrimonial());
        }
        Equipo equipo = new Equipo(request.getCodigoPatrimonial(), request.getNombre(), request.getTipo(), EstadoEquipo.DISPONIBLE);
        return equipoRepository.save(equipo);
    }

    @Transactional
    public Equipo actualizar(Long id, EquipoRequest request) {
        Equipo equipo = obtener(id);

        equipoRepository.findByCodigoPatrimonial(request.getCodigoPatrimonial())
                .filter(otro -> !otro.getId().equals(id))
                .ifPresent(otro -> {
                    throw new ConflictoNegocioException("Ya existe otro equipo con el codigo patrimonial " + request.getCodigoPatrimonial());
                });

        equipo.setCodigoPatrimonial(request.getCodigoPatrimonial());
        equipo.setNombre(request.getNombre());
        equipo.setTipo(request.getTipo());
        return equipoRepository.save(equipo);
    }

    @Transactional
    public void eliminar(Long id) {
        Equipo equipo = obtener(id);

        boolean tienePrestamoActivo = prestamoRepository.existsByEquipoAndEstado(equipo, EstadoPrestamo.ACTIVO);
        if (tienePrestamoActivo) {
            throw new ConflictoNegocioException("No se puede eliminar un equipo con prestamos activos");
        }

        prestamoRepository.deleteAll(prestamoRepository.findByEquipo(equipo));
        equipoRepository.delete(equipo);
    }
}
