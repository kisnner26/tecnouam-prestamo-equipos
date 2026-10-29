package com.uam.tecnouam.backend;

import com.uam.tecnouam.backend.modelo.Equipo;
import com.uam.tecnouam.backend.modelo.EstadoEquipo;
import com.uam.tecnouam.backend.modelo.Rol;
import com.uam.tecnouam.backend.modelo.Usuario;
import com.uam.tecnouam.backend.repositorio.EquipoRepository;
import com.uam.tecnouam.backend.repositorio.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataLoader implements CommandLineRunner {

    private final UsuarioRepository usuarioRepository;
    private final EquipoRepository equipoRepository;
    private final PasswordEncoder passwordEncoder;

    public DataLoader(UsuarioRepository usuarioRepository, EquipoRepository equipoRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.equipoRepository = equipoRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (usuarioRepository.findByUsername("admin").isEmpty()) {
            usuarioRepository.save(new Usuario("admin", passwordEncoder.encode("admin123"), Rol.ADMIN));
        }
        if (usuarioRepository.findByUsername("instructor").isEmpty()) {
            usuarioRepository.save(new Usuario("instructor", passwordEncoder.encode("instructor123"), Rol.USER));
        }

        if (equipoRepository.count() == 0) {
            equipoRepository.save(new Equipo("TEC-001", "Laptop Dell Latitude 5420", "LAPTOP", EstadoEquipo.DISPONIBLE));
            equipoRepository.save(new Equipo("TEC-002", "Proyector Epson PowerLite", "PROYECTOR", EstadoEquipo.DISPONIBLE));
            equipoRepository.save(new Equipo("TEC-003", "Tableta Samsung Galaxy Tab A8", "TABLETA", EstadoEquipo.DISPONIBLE));
        }
    }
}
