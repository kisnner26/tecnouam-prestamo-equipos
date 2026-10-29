import { useState } from "react";
import api from "../api/cliente";

export default function Login({ onLogin }) {
  const [username, setUsername] = useState("instructor");
  const [password, setPassword] = useState("instructor123");
  const [error, setError] = useState("");
  const [cargando, setCargando] = useState(false);

  async function manejarSubmit(e) {
    e.preventDefault();
    setError("");
    setCargando(true);
    try {
      const { data } = await api.post("/auth/login", { username, password });
      localStorage.setItem("token", data.token);
      localStorage.setItem("username", data.username);
      localStorage.setItem("rol", data.rol);
      onLogin(data);
    } catch (err) {
      if (err.response?.status === 401) {
        setError("Usuario o contrasena incorrectos");
      } else {
        setError("No se pudo conectar con el servidor");
      }
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="login-contenedor">
      <form className="login-form" onSubmit={manejarSubmit}>
        <h1>TecnoUAM</h1>
        <p className="subtitulo">Ingreso al sistema de prestamos</p>

        <label>
          Usuario
          <input
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            autoComplete="username"
          />
        </label>

        <label>
          Contrasena
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="current-password"
          />
        </label>

        {error && <p className="error">{error}</p>}

        <button type="submit" disabled={cargando}>
          {cargando ? "Ingresando..." : "Ingresar"}
        </button>

        <p className="ayuda">
          admin / admin123 (ADMIN) &middot; instructor / instructor123 (USER)
        </p>
      </form>
    </div>
  );
}
