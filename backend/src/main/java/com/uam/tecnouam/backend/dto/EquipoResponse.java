package com.uam.tecnouam.backend.dto;

import com.uam.tecnouam.backend.modelo.Equipo;
import com.uam.tecnouam.backend.modelo.EstadoEquipo;

public class EquipoResponse {

    private Long id;
    private String codigoPatrimonial;
    private String nombre;
    private String tipo;
    private EstadoEquipo estado;

    public EquipoResponse(Equipo equipo) {
        this.id = equipo.getId();
        this.codigoPatrimonial = equipo.getCodigoPatrimonial();
        this.nombre = equipo.getNombre();
        this.tipo = equipo.getTipo();
        this.estado = equipo.getEstado();
    }

    public Long getId() {
        return id;
    }

    public String getCodigoPatrimonial() {
        return codigoPatrimonial;
    }

    public String getNombre() {
        return nombre;
    }

    public String getTipo() {
        return tipo;
    }

    public EstadoEquipo getEstado() {
        return estado;
    }
}
