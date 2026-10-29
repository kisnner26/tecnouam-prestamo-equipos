package com.uam.tecnouam.backend.controlador;

import com.uam.tecnouam.backend.dto.EquipoRequest;
import com.uam.tecnouam.backend.dto.EquipoResponse;
import com.uam.tecnouam.backend.modelo.Equipo;
import com.uam.tecnouam.backend.servicio.EquipoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/equipos")
public class EquipoController {

    private final EquipoService equipoService;

    public EquipoController(EquipoService equipoService) {
        this.equipoService = equipoService;
    }

    @GetMapping
    public List<EquipoResponse> listar() {
        return equipoService.listar().stream().map(EquipoResponse::new).toList();
    }

    @GetMapping("/{id}")
    public EquipoResponse obtener(@PathVariable Long id) {
        return new EquipoResponse(equipoService.obtener(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EquipoResponse crear(@Valid @RequestBody EquipoRequest request) {
        Equipo equipo = equipoService.crear(request);
        return new EquipoResponse(equipo);
    }

    @PutMapping("/{id}")
    public EquipoResponse actualizar(@PathVariable Long id, @Valid @RequestBody EquipoRequest request) {
        Equipo equipo = equipoService.actualizar(id, request);
        return new EquipoResponse(equipo);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminar(@PathVariable Long id) {
        equipoService.eliminar(id);
    }
}
