export default function Marca({ clara = false }) {
  return (
    <div
      className={`marca ${clara ? "marca-clara" : ""}`}
      aria-label="TecnoUAM"
    >
      <span className="marca-simbolo" aria-hidden="true">
        <svg viewBox="0 0 32 32" fill="none">
          <path d="M5 8h22v6H19v13h-6V14H5V8Z" fill="currentColor" />
          <path d="M23 20h4v7h-4z" fill="currentColor" opacity=".45" />
        </svg>
      </span>
      <span className="marca-nombre">
        tecno<span>UAM</span>
        <small>TECNOLOGÍA COMPARTIDA</small>
      </span>
    </div>
  );
}
