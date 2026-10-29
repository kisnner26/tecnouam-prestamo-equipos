export default function Icono({ nombre, size = 20, ...props }) {
  const trazos = {
    flecha: (
      <>
        <path d="M5 12h14M13 6l6 6-6 6" />
      </>
    ),
    salir: (
      <>
        <path d="M9 4H4v16h5M9 12h11M16 8l4 4-4 4" />
      </>
    ),
    buscar: (
      <>
        <circle cx="10.5" cy="10.5" r="6.5" />
        <path d="m16 16 4 4" />
      </>
    ),
    actualizar: (
      <>
        <path d="M20 7v5h-5M4 17v-5h5" />
        <path d="M6.1 6.1A8 8 0 0 1 20 12M4 12a8 8 0 0 0 13.9 5.9" />
      </>
    ),
    cuadricula: (
      <>
        <rect x="3" y="3" width="7" height="7" rx="1.5" />
        <rect x="14" y="3" width="7" height="7" rx="1.5" />
        <rect x="3" y="14" width="7" height="7" rx="1.5" />
        <rect x="14" y="14" width="7" height="7" rx="1.5" />
      </>
    ),
    disponible: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="m8 12 3 3 5-6" />
      </>
    ),
    reloj: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M12 7v5l3 2" />
      </>
    ),
    laptop: (
      <>
        <rect x="4" y="4" width="16" height="12" rx="2" />
        <path d="m4 16-2 4h20l-2-4M9 20h6" />
      </>
    ),
    proyector: (
      <>
        <rect x="2" y="6" width="20" height="12" rx="3" />
        <circle cx="16" cy="12" r="3" />
        <path d="M5 10h3M5 13h3M6 18v2M18 18v2" />
      </>
    ),
    tableta: (
      <>
        <rect x="5" y="2" width="14" height="20" rx="2" />
        <path d="M10 18h4" />
      </>
    ),
    ojo: (
      <>
        <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" />
        <circle cx="12" cy="12" r="3" />
      </>
    ),
    ocultar: (
      <>
        <path d="m3 3 18 18M10.6 5.1 12 5c6.5 0 10 7 10 7a21 21 0 0 1-3 3.8M6.4 6.4A22 22 0 0 0 2 12s3.5 7 10 7a11 11 0 0 0 5.6-1.6" />
        <path d="M10 10a3 3 0 0 0 4 4" />
      </>
    ),
    candado: (
      <>
        <rect x="5" y="10" width="14" height="11" rx="2" />
        <path d="M8 10V7a4 4 0 0 1 8 0v3M12 14v3" />
      </>
    ),
    usuario: (
      <>
        <circle cx="12" cy="8" r="4" />
        <path d="M4 21v-2a8 8 0 0 1 16 0v2" />
      </>
    ),
    cerrar: <path d="m6 6 12 12M6 18 18 6" />,
    aviso: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M12 7v6M12 16h.01" />
      </>
    ),
    chevron: <path d="m8 10 4 4 4-4" />,
  };
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.65"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      {...props}
    >
      {trazos[nombre] || trazos.laptop}
    </svg>
  );
}
