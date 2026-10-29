package com.uam.tecnouam.backend.controlador;

import com.uam.tecnouam.backend.dto.PrestamoRequest;
import com.uam.tecnouam.backend.dto.PrestamoResponse;
import com.uam.tecnouam.backend.modelo.Prestamo;
import com.uam.tecnouam.backend.servicio.PrestamoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/prestamos")
public class PrestamoController {

    private final PrestamoService prestamoService;

    public PrestamoController(PrestamoService prestamoService) {
        this.prestamoService = prestamoService;
    }

    @GetMapping
    public List<PrestamoResponse> listar() {
        return prestamoService.listar().stream().map(PrestamoResponse::new).toList();
    }

    @GetMapping("/{id}")
    public PrestamoResponse obtener(@PathVariable Long id) {
        return new PrestamoResponse(prestamoService.obtener(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PrestamoResponse registrar(@Valid @RequestBody PrestamoRequest request) {
        Prestamo prestamo = prestamoService.registrar(request);
        return new PrestamoResponse(prestamo);
    }

    @PutMapping("/{id}/devolver")
    public PrestamoResponse devolver(@PathVariable Long id) {
        Prestamo prestamo = prestamoService.devolver(id);
        return new PrestamoResponse(prestamo);
    }
}
