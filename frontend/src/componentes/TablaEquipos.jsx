import { useEffect, useState, useCallback } from "react";
import api from "../api/cliente";

export default function TablaEquipos({ onCerrarSesion, usuario, rol }) {
  const [equipos, setEquipos] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  const cargarEquipos = useCallback(async () => {
    setCargando(true);
    setError("");
    try {
      const { data } = await api.get("/equipos");
      setEquipos(data);
    } catch (err) {
      if (err.response?.status === 401) {
        setError("Sesion expirada, vuelva a iniciar sesion");
      } else {
        setError("No se pudieron cargar los equipos");
      }
    } finally {
      setCargando(false);
    }
  }, []);

  useEffect(() => {
    cargarEquipos();
  }, [cargarEquipos]);

  return (
    <div className="panel">
      <header className="panel-header">
        <div>
          <h1>Equipos tecnologicos</h1>
          <p className="subtitulo">
            Sesion: {usuario} ({rol})
          </p>
        </div>
        <div className="acciones-header">
          <button onClick={cargarEquipos} disabled={cargando}>
            Actualizar
          </button>
          <button className="secundario" onClick={onCerrarSesion}>
            Cerrar sesion
          </button>
        </div>
      </header>

      {cargando && <p className="estado">Cargando equipos...</p>}

      {!cargando && error && <p className="estado error">{error}</p>}

      {!cargando && !error && equipos.length === 0 && (
        <p className="estado">No hay equipos registrados.</p>
      )}

      {!cargando && !error && equipos.length > 0 && (
        <table className="tabla">
          <thead>
            <tr>
              <th>Codigo</th>
              <th>Nombre</th>
              <th>Tipo</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            {equipos.map((eq) => (
              <tr key={eq.id}>
                <td>{eq.codigoPatrimonial}</td>
                <td>{eq.nombre}</td>
                <td>{eq.tipo}</td>
                <td>
                  <span className={`etiqueta ${eq.estado === "DISPONIBLE" ? "disponible" : "prestado"}`}>
                    {eq.estado}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <p className="nota">
        Para crear equipos, registrar prestamos o devoluciones usa Postman con
        la cuenta ADMIN; esta tabla se actualiza al presionar &quot;Actualizar&quot;.
      </p>
    </div>
  );
}
