import { useState } from "react";
import Login from "./componentes/Login";
import TablaEquipos from "./componentes/TablaEquipos";
import "./App.css";

function App() {
  const [sesion, setSesion] = useState(() => {
    const token = localStorage.getItem("token");
    const username = localStorage.getItem("username");
    const rol = localStorage.getItem("rol");
    return token ? { token, username, rol } : null;
  });

  function cerrarSesion() {
    localStorage.removeItem("token");
    localStorage.removeItem("username");
    localStorage.removeItem("rol");
    setSesion(null);
  }

  if (!sesion) {
    return <Login onLogin={setSesion} />;
  }

  return (
    <TablaEquipos
      onCerrarSesion={cerrarSesion}
      usuario={sesion.username}
      rol={sesion.rol}
    />
  );
}

export default App;
