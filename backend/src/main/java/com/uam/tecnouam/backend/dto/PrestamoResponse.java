package com.uam.tecnouam.backend.dto;

import com.uam.tecnouam.backend.modelo.EstadoPrestamo;
import com.uam.tecnouam.backend.modelo.Prestamo;

import java.time.LocalDate;

public class PrestamoResponse {

    private Long id;
    private Long equipoId;
    private String equipoCodigoPatrimonial;
    private String equipoNombre;
    private String nombreSolicitante;
    private LocalDate fechaPrestamo;
    private LocalDate fechaDevolucionPrevista;
    private LocalDate fechaDevolucionReal;
    private EstadoPrestamo estado;

    public PrestamoResponse(Prestamo prestamo) {
        this.id = prestamo.getId();
        this.equipoId = prestamo.getEquipo().getId();
        this.equipoCodigoPatrimonial = prestamo.getEquipo().getCodigoPatrimonial();
        this.equipoNombre = prestamo.getEquipo().getNombre();
        this.nombreSolicitante = prestamo.getNombreSolicitante();
        this.fechaPrestamo = prestamo.getFechaPrestamo();
        this.fechaDevolucionPrevista = prestamo.getFechaDevolucionPrevista();
        this.fechaDevolucionReal = prestamo.getFechaDevolucionReal();
        this.estado = prestamo.getEstado();
    }

    public Long getId() {
        return id;
    }

    public Long getEquipoId() {
        return equipoId;
    }

    public String getEquipoCodigoPatrimonial() {
        return equipoCodigoPatrimonial;
    }

    public String getEquipoNombre() {
        return equipoNombre;
    }

    public String getNombreSolicitante() {
        return nombreSolicitante;
    }

    public LocalDate getFechaPrestamo() {
        return fechaPrestamo;
    }

    public LocalDate getFechaDevolucionPrevista() {
        return fechaDevolucionPrevista;
    }

    public LocalDate getFechaDevolucionReal() {
        return fechaDevolucionReal;
    }

    public EstadoPrestamo getEstado() {
        return estado;
    }
}
