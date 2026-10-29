import { useEffect, useState, useCallback } from "react";
import api from "../api/cliente";
import Icono from "./Icono";
import Marca from "./Marca";

const nombreTipo = (tipo) =>
  ({ LAPTOP: "Laptop", PROYECTOR: "Proyector", TABLETA: "Tableta" })[tipo] ||
  tipo?.replaceAll("_", " ") ||
  "Equipo";
const iconoTipo = (tipo) =>
  ({ LAPTOP: "laptop", PROYECTOR: "proyector", TABLETA: "tableta" })[tipo] ||
  "laptop";
const normalizar = (valor) =>
  String(valor ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("es");

export default function TablaEquipos({ onCerrarSesion, usuario, rol }) {
  const [equipos, setEquipos] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");
  const [sesionExpirada, setSesionExpirada] = useState(false);
  const [busqueda, setBusqueda] = useState("");
  const [estado, setEstado] = useState("TODOS");
  const [tipo, setTipo] = useState("TODOS");
  const [ultimaConsulta, setUltimaConsulta] = useState(null);

  const obtenerEquipos = useCallback(async (signal) => {
    try {
      const { data } = await api.get("/equipos", { signal });
      setEquipos(data);
      setUltimaConsulta(new Date());
    } catch (err) {
      if (signal?.aborted) return;
      setSesionExpirada(err.response?.status === 401);
      setError(
        err.response?.status === 401
          ? "Tu sesión ha expirado. Inicia sesión nuevamente para consultar los equipos."
          : "No pudimos cargar el inventario. Comprueba la conexión e inténtalo de nuevo.",
      );
    } finally {
      if (!signal?.aborted) setCargando(false);
    }
  }, []);

  useEffect(() => {
    const peticion = new AbortController();
    // oxlint-disable-next-line react/set-state-in-effect -- El estado cambia tras recibir la respuesta asincrona de la API.
    obtenerEquipos(peticion.signal);
    return () => peticion.abort();
  }, [obtenerEquipos]);

  function cargarEquipos() {
    setCargando(true);
    setError("");
    setSesionExpirada(false);
    obtenerEquipos();
  }

  const disponibles = equipos.filter((eq) => eq.estado === "DISPONIBLE").length;
  const prestados = equipos.filter((eq) => eq.estado === "PRESTADO").length;
  const tipos = [
    ...new Set(equipos.map((eq) => eq.tipo).filter(Boolean)),
  ].sort();
  const filtrados = equipos.filter(
    (eq) =>
      (estado === "TODOS" || eq.estado === estado) &&
      (tipo === "TODOS" || eq.tipo === tipo) &&
      normalizar(
        `${eq.nombre} ${eq.codigoPatrimonial} ${nombreTipo(eq.tipo)}`,
      ).includes(normalizar(busqueda.trim())),
  );
  const hayFiltros = busqueda !== "" || estado !== "TODOS" || tipo !== "TODOS";
  const cantidad = (n) =>
    cargando || error ? "—" : String(n).padStart(2, "0");
  const limpiarFiltros = () => {
    setBusqueda("");
    setEstado("TODOS");
    setTipo("TODOS");
  };
  const opciones = [
    {
      valor: "TODOS",
      texto: "Todos los equipos",
      icono: "cuadricula",
      cantidad: equipos.length,
    },
    {
      valor: "DISPONIBLE",
      texto: "Disponibles",
      icono: "disponible",
      cantidad: disponibles,
    },
    {
      valor: "PRESTADO",
      texto: "En préstamo",
      icono: "reloj",
      cantidad: prestados,
    },
  ];

  return (
    <div className="campus">
      <a className="saltar-contenido" href="#inventario">
        Saltar al inventario
      </a>
      <aside className="barra-lateral">
        <Marca clara />
        <div className="navegacion-contenedor">
          <p className="sobrelinea">TU ESPACIO DE TRABAJO</p>
          <nav className="navegacion" aria-label="Filtrar equipos por estado">
            {opciones.map((opcion) => (
              <button
                key={opcion.valor}
                className={estado === opcion.valor ? "nav-activo" : ""}
                onClick={() => setEstado(opcion.valor)}
                aria-pressed={estado === opcion.valor}
              >
                <Icono nombre={opcion.icono} />
                <span>{opcion.texto}</span>
                <small>{cantidad(opcion.cantidad)}</small>
              </button>
            ))}
          </nav>
        </div>
        <div className="lateral-mensaje">
          <span className="lateral-asterisco" aria-hidden="true">
            ✳
          </span>
          <p>
            Comparte tecnología.
            <br />
            <em>Multiplica posibilidades.</em>
          </p>
          <span>Una comunidad que crea.</span>
        </div>
        <div className="lateral-usuario">
          <span className="avatar">
            {(usuario || "U").slice(0, 2).toUpperCase()}
          </span>
          <div>
            <strong>{usuario || "Usuario"}</strong>
            <span>{rol === "ADMIN" ? "Administrador" : "Instructor"}</span>
          </div>
          <button
            className="boton-icono salir"
            onClick={onCerrarSesion}
            aria-label="Cerrar sesión"
            title="Cerrar sesión"
          >
            <Icono nombre="salir" />
          </button>
        </div>
      </aside>

      <main className="contenido-campus" id="inventario" tabIndex={-1}>
        <header className="cabecera-campus">
          <span>
            Campus <span className="separador">/</span>{" "}
            <strong>Recursos tecnológicos</strong>
          </span>
          <span className="sello-universidad">
            UNIVERSIDAD AMERICANA <span aria-hidden="true">↗</span>
          </span>
        </header>

        <section className="bienvenida" aria-labelledby="titulo-catalogo">
          <div>
            <span className="sobrelinea">
              <span className="linea-acento" /> EL CAMPUS A TU ALCANCE
            </span>
            <h1 id="titulo-catalogo">
              Equipos que impulsan
              <br />
              <em>tus ideas.</em>
            </h1>
            <p>
              Encuentra las herramientas para tu próximo proyecto.
              <br className="salto-escritorio" /> Consulta el inventario y su
              disponibilidad en un solo lugar.
            </p>
          </div>
          <div className="bienvenida-grafico" aria-hidden="true">
            <div className="grafico-circulo" />
            <div className="grafico-rejilla" />
            <span className="grafico-etiqueta">TECNO / UAM</span>
            <Icono nombre="laptop" size={108} />
            <span className="grafico-estrella">✳</span>
            <span className="grafico-texto">HECHO PARA CREAR</span>
          </div>
        </section>

        <section
          className="resumen-inventario"
          aria-label="Resumen del inventario"
        >
          <div className="metrica">
            <span className="metrica-icono">
              <Icono nombre="cuadricula" />
            </span>
            <div>
              <span>Total de equipos</span>
              <strong>{cantidad(equipos.length)}</strong>
            </div>
            <span className="metrica-descripcion">En el inventario</span>
          </div>
          <div className="metrica">
            <span className="metrica-icono verde">
              <Icono nombre="disponible" />
            </span>
            <div>
              <span>Disponibles</span>
              <strong>{cantidad(disponibles)}</strong>
            </div>
            <span className="metrica-descripcion">Listos para usar</span>
          </div>
          <div className="metrica">
            <span className="metrica-icono ambar">
              <Icono nombre="reloj" />
            </span>
            <div>
              <span>En préstamo</span>
              <strong>{cantidad(prestados)}</strong>
            </div>
            <span className="metrica-descripcion">En uso actualmente</span>
          </div>
        </section>

        <section className="catalogo" aria-labelledby="titulo-inventario">
          <div className="catalogo-cabecera">
            <div>
              <h2 id="titulo-inventario">
                Inventario del campus
                <span className="contador-tipos">
                  {!cargando && !error ? equipos.length : "—"}
                </span>
              </h2>
              <p>Un buen proyecto empieza con las herramientas correctas.</p>
            </div>
            <button
              className="boton-secundario"
              onClick={cargarEquipos}
              disabled={cargando}
            >
              <Icono
                nombre="actualizar"
                size={17}
                className={cargando ? "girando" : ""}
              />
              {cargando ? "Actualizando…" : "Actualizar"}
            </button>
          </div>

          <div className="herramientas-catalogo">
            <div className="buscador">
              <Icono nombre="buscar" />
              <label className="solo-lectores" htmlFor="buscar-equipo">
                Buscar equipos por nombre, código o tipo
              </label>
              <input
                id="buscar-equipo"
                type="search"
                placeholder="Busca por nombre, código o tipo de equipo…"
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
              />
            </div>
            <div className="selector-tipo">
              <label className="solo-lectores" htmlFor="tipo-equipo">
                Tipo de equipo
              </label>
              <select
                id="tipo-equipo"
                value={tipo}
                onChange={(e) => setTipo(e.target.value)}
              >
                <option value="TODOS">Todos los tipos</option>
                {tipos.map((valor) => (
                  <option key={valor} value={valor}>
                    {nombreTipo(valor)}
                  </option>
                ))}
              </select>
              <Icono nombre="chevron" size={17} />
            </div>
          </div>
          {hayFiltros && (
            <div className="filtros-aplicados">
              <span>
                {estado === "TODOS"
                  ? "Todos los estados"
                  : estado === "DISPONIBLE"
                    ? "Equipos disponibles"
                    : "Equipos en préstamo"}
              </span>
              <button onClick={limpiarFiltros}>
                Limpiar filtros
                <Icono nombre="cerrar" size={14} />
              </button>
            </div>
          )}

          <div className="resultados-catalogo" aria-busy={cargando}>
            {cargando ? (
              <div className="carga-inventario" role="status">
                <span className="sobrelinea">CONSULTANDO INVENTARIO</span>
                {[1, 2, 3].map((n) => (
                  <div className="fila-esqueleto" key={n}>
                    <i />
                    <span />
                    <span />
                  </div>
                ))}
                <span className="solo-lectores">Cargando equipos…</span>
              </div>
            ) : error ? (
              <div className="estado-vacio estado-error" role="alert">
                <span className="vacio-icono">
                  <Icono nombre="aviso" size={30} />
                </span>
                <h3>
                  {sesionExpirada
                    ? "Volvamos a conectar"
                    : "No pudimos traer los equipos"}
                </h3>
                <p>{error}</p>
                <button
                  className="boton-primario"
                  onClick={sesionExpirada ? onCerrarSesion : cargarEquipos}
                >
                  {sesionExpirada ? "Iniciar sesión" : "Volver a intentar"}
                  <Icono nombre="flecha" size={18} />
                </button>
              </div>
            ) : filtrados.length === 0 ? (
              <div className="estado-vacio">
                <span className="vacio-icono">
                  <Icono
                    nombre={equipos.length ? "buscar" : "cuadricula"}
                    size={30}
                  />
                </span>
                <h3>
                  {equipos.length
                    ? "No encontramos coincidencias"
                    : "El inventario está por comenzar"}
                </h3>
                <p>
                  {equipos.length
                    ? "Prueba con otro nombre, código o tipo de equipo."
                    : "Los equipos aparecerán aquí cuando se registren en el sistema."}
                </p>
                {hayFiltros && (
                  <button className="boton-secundario" onClick={limpiarFiltros}>
                    Mostrar todos los equipos
                    <Icono nombre="flecha" size={17} />
                  </button>
                )}
              </div>
            ) : (
              <div className="tabla-contenedor">
                <table className="tabla-equipos">
                  <caption className="solo-lectores">
                    Equipos del campus y su disponibilidad
                  </caption>
                  <thead>
                    <tr>
                      <th scope="col">Equipo</th>
                      <th scope="col">Código patrimonial</th>
                      <th scope="col">Tipo</th>
                      <th scope="col">Disponibilidad</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filtrados.map((eq) => (
                      <tr key={eq.id}>
                        <td>
                          <div className="identidad-equipo">
                            <span
                              className={`equipo-icono tipo-${eq.tipo?.toLowerCase()}`}
                            >
                              <Icono nombre={iconoTipo(eq.tipo)} size={29} />
                            </span>
                            <div>
                              <strong>{eq.nombre}</strong>
                              <span>
                                {nombreTipo(eq.tipo)} · Equipo del campus
                              </span>
                            </div>
                          </div>
                        </td>
                        <td data-label="Código">
                          <span className="codigo-equipo">
                            {eq.codigoPatrimonial}
                          </span>
                        </td>
                        <td data-label="Tipo">
                          <span className="tipo-equipo">
                            {nombreTipo(eq.tipo)}
                          </span>
                        </td>
                        <td data-label="Estado">
                          <span
                            className={`etiqueta-estado ${eq.estado === "DISPONIBLE" ? "disponible" : eq.estado === "PRESTADO" ? "prestado" : ""}`}
                          >
                            <span className="punto" />
                            {eq.estado === "DISPONIBLE"
                              ? "Disponible"
                              : eq.estado === "PRESTADO"
                                ? "En préstamo"
                                : eq.estado}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
          <footer className="catalogo-pie">
            <span role="status">
              {cargando
                ? "Consultando equipos…"
                : error
                  ? "Inventario no disponible"
                  : `Mostrando ${filtrados.length} de ${equipos.length} equipos`}
            </span>
            <span>
              {ultimaConsulta && !error
                ? `Última consulta: ${ultimaConsulta.toLocaleTimeString("es-NI", { hour: "2-digit", minute: "2-digit" })}`
                : "Catálogo de recursos tecnológicos"}
            </span>
          </footer>
        </section>
        <footer className="pie-campus">
          <p>
            <strong>TecnoUAM</strong> <span>·</span> Tecnología que se comparte.
          </p>
          <span>
            APRENDER JUNTOS NOS LLEVA MÁS LEJOS{" "}
            <span aria-hidden="true">↗</span>
          </span>
        </footer>
      </main>
    </div>
  );
}
