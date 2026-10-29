import { useState } from "react";
import api from "../api/cliente";
import Icono from "./Icono";
import Marca from "./Marca";

export default function Login({ onLogin }) {
  const [username, setUsername] = useState("instructor");
  const [password, setPassword] = useState("instructor123");
  const [mostrarPassword, setMostrarPassword] = useState(false);
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
      setError(
        err.response?.status === 401
          ? "El usuario o la contraseña son incorrectos. Inténtalo de nuevo."
          : "No pudimos conectar con el servidor. Inténtalo nuevamente.",
      );
    } finally {
      setCargando(false);
    }
  }

  return (
    <main className="acceso">
      <section className="acceso-portada" aria-labelledby="portada-titulo">
        <Marca clara />
        <div className="portada-texto">
          <span className="sobrelinea">
            <span className="punto" /> UNIVERSIDAD AMERICANA
          </span>
          <h1 id="portada-titulo">
            Tus ideas.
            <br />
            Nuestro equipo.
            <br />
            <em>Más posibilidades.</em>
          </h1>
          <p>La tecnología del campus, al alcance de tu próximo proyecto.</p>
        </div>
        <div className="portada-ilustracion" aria-hidden="true">
          <svg viewBox="0 0 540 220" fill="none">
            <circle
              cx="290"
              cy="115"
              r="94"
              stroke="currentColor"
              opacity=".15"
            />
            <circle
              cx="290"
              cy="115"
              r="119"
              stroke="currentColor"
              opacity=".08"
            />
            <path
              d="m134 154 23-116a10 10 0 0 1 10-8h230a9 9 0 0 1 9 11l-23 113H134Z"
              fill="#f5e9e0"
            />
            <path d="m149 143 21-100h222l-20 100H149Z" fill="#401a29" />
            <path
              d="m190 70 21 20-29 20M235 113h51"
              stroke="#f2b38e"
              strokeWidth="6"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M102 154h303l35 22a5 5 0 0 1-3 9H86a5 5 0 0 1-3-9l19-22Z"
              fill="#d9b5a5"
            />
            <path d="M221 154h70l11 10h-91l10-10Z" fill="#a97975" />
            <rect
              x="376"
              y="73"
              width="76"
              height="111"
              rx="9"
              fill="#f0b38f"
              transform="rotate(8 376 73)"
            />
            <path d="m386 89 47 7-9 64-47-7 9-64Z" fill="#6a2b3b" />
            <path
              d="m392 172 14 2"
              stroke="#6a2b3b"
              strokeWidth="3"
              strokeLinecap="round"
            />
            <path
              d="M88 52v20M78 62h20M454 39v12M448 45h12"
              stroke="currentColor"
              strokeWidth="2"
              opacity=".65"
            />
          </svg>
          <span>APRENDE. CREA. COMPARTE.</span>
        </div>
        <footer className="portada-pie">
          <span>Recursos tecnológicos del campus</span>
          <span>
            UAM <span aria-hidden="true">↗</span>
          </span>
        </footer>
      </section>

      <section className="acceso-formulario" aria-labelledby="acceso-titulo">
        <div className="acceso-etiqueta">
          <span className="punto" /> PORTAL DE EQUIPOS
        </div>
        <form className="login-form" onSubmit={manejarSubmit}>
          <span className="sobrelinea">UN ESPACIO PARA HACER MÁS</span>
          <h2 id="acceso-titulo">
            Qué bueno
            <br />
            tenerte de vuelta<span>.</span>
          </h2>
          <p className="login-introduccion">
            Ingresa a tu cuenta para consultar los equipos y su disponibilidad.
          </p>

          <div className="campo-formulario">
            <label htmlFor="usuario">Usuario</label>
            <div className="campo-icono">
              <Icono nombre="usuario" size={19} />
              <input
                id="usuario"
                name="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                autoComplete="username"
                required
                autoCapitalize="none"
                spellCheck={false}
                placeholder="Tu nombre de usuario"
              />
            </div>
          </div>
          <div className="campo-formulario">
            <label htmlFor="password">Contraseña</label>
            <div className="campo-icono">
              <Icono nombre="candado" size={19} />
              <input
                id="password"
                name="password"
                type={mostrarPassword ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
                required
                placeholder="Tu contraseña"
              />
              <button
                type="button"
                className="boton-icono"
                onClick={() => setMostrarPassword(!mostrarPassword)}
                aria-label={
                  mostrarPassword ? "Ocultar contraseña" : "Mostrar contraseña"
                }
                aria-pressed={mostrarPassword}
              >
                <Icono nombre={mostrarPassword ? "ocultar" : "ojo"} size={19} />
              </button>
            </div>
          </div>
          {error && (
            <div className="mensaje-error" role="alert">
              <Icono nombre="aviso" />
              <p>{error}</p>
            </div>
          )}
          <button
            className="boton-primario boton-ingresar"
            type="submit"
            disabled={cargando}
          >
            {cargando ? "Ingresando…" : "Ingresar al campus"}
            <Icono
              nombre={cargando ? "actualizar" : "flecha"}
              className={cargando ? "girando" : ""}
            />
          </button>

          <details className="cuentas-demo">
            <summary>
              ¿Estás probando el sistema?{" "}
              <span>Ver cuentas de demostración</span>
            </summary>
            <dl>
              <div>
                <dt>Instructor</dt>
                <dd>instructor / instructor123</dd>
              </div>
              <div>
                <dt>Administrador</dt>
                <dd>admin / admin123</dd>
              </div>
            </dl>
          </details>
        </form>
        <footer className="acceso-pie">
          <span className="mini-marca">TU</span>
          <p>
            TecnoUAM · Sistema de préstamo de equipos
            <br />
            <span>Universidad Americana</span>
          </p>
        </footer>
      </section>
    </main>
  );
}
