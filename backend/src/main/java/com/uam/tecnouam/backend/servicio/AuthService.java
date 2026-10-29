package com.uam.tecnouam.backend.servicio;

import com.uam.tecnouam.backend.dto.LoginRequest;
import com.uam.tecnouam.backend.dto.LoginResponse;
import com.uam.tecnouam.backend.modelo.Usuario;
import com.uam.tecnouam.backend.repositorio.UsuarioRepository;
import com.uam.tecnouam.backend.seguridad.JwtUtil;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UsuarioRepository usuarioRepository;
    private final JwtUtil jwtUtil;

    public AuthService(AuthenticationManager authenticationManager, UsuarioRepository usuarioRepository, JwtUtil jwtUtil) {
        this.authenticationManager = authenticationManager;
        this.usuarioRepository = usuarioRepository;
        this.jwtUtil = jwtUtil;
    }

    public LoginResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );

        Usuario usuario = usuarioRepository.findByUsername(request.getUsername())
                .orElseThrow();

        String token = jwtUtil.generarToken(usuario.getUsername(), usuario.getRol().name());
        return new LoginResponse(token, usuario.getUsername(), usuario.getRol().name());
    }
}
