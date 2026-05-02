import { useState, useEffect, useRef, useCallback } from 'react'; 
import { useNavigate } from 'react-router-dom';
import logo from '../assets/logo.png';
import './administrador.css';

interface UsuarioPersonal {
    numero_colegio: string;
    username: string;
    tipo: string;
    especialidad: string;
    departamento: string;
}

const Administrador = () => {
    const navigate = useNavigate();
    const [personal, setPersonal] = useState<UsuarioPersonal[]>([]);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const obtenerUsuarios = useCallback(async () => {
        try {
            const res = await fetch('http://127.0.0.1:3000/personal');
            if (!res.ok) throw new Error('Error en la respuesta del servidor');
            const data: UsuarioPersonal[] = await res.json();
            setPersonal(data);
        } catch (err) {
            console.error("Error al obtener el personal:", err);
        }
    }, []); 

    useEffect(() => {
        const cargarData = async () => {
            await obtenerUsuarios();
        };
        cargarData();
    }, [obtenerUsuarios]); 

    const handleCargaMasivaClick = () => {
        fileInputRef.current?.click();
    };

    const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = async (e) => {
            try {
                const jsonContent = JSON.parse(e.target?.result as string);
                
                const response = await fetch('http://127.0.0.1:3000/carga-masiva', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(jsonContent)
                });

                if (response.ok) {
                    alert("¡Carga masiva procesada exitosamente!");
                    await obtenerUsuarios(); // Actualizamos la tabla
                } else {
                    const errorData = await response.json();
                    alert("Error en el servidor: " + (errorData.mensaje || "No se pudo procesar"));
                }
            } catch (err) {
                alert("Error: El archivo seleccionado no es un JSON válido." + (err instanceof Error ? err.message : "")); // No es un error de React
            } finally {
                if (fileInputRef.current) fileInputRef.current.value = "";
            }
        };
        reader.readAsText(file);
    };

    return (
        <div id="admin-container">
            <div className="admin-card">
                <header className="admin-header">
                    <img src={logo} className="admin-logo-small" alt="Logo" />
                    <h1>Panel de Administración</h1>
                    <p>Bienvenido, <strong>Administrador TIPO-05</strong></p>
                    
                    <div className="refresh-container">
                        <button onClick={obtenerUsuarios} className="btn-refresh">
                            ↻ Refrescar Tabla
                        </button>
                    </div>
                </header>

                <div className="table-container">
                    <table className="admin-table">
                        <thead>
                            <tr>
                                <th>Colegio</th>
                                <th>Nombre</th>
                                <th>Tipo</th>
                                <th>Especialidad</th>
                                <th>Departamento</th>
                            </tr>
                        </thead>
                        <tbody>
                            {personal.length > 0 ? (
                                personal.map((u: UsuarioPersonal, i: number) => (
                                    <tr key={u.numero_colegio || i}>
                                        <td>{u.numero_colegio}</td>
                                        <td>{u.username}</td>
                                        <td>{u.tipo}</td>
                                        <td>{u.especialidad}</td>
                                        <td>{u.departamento}</td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan={5} style={{ textAlign: 'center' }}>No hay personal registrado</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                <div className="admin-actions">
                    <div className="action-row">
                        <input 
                            type="file" 
                            ref={fileInputRef} 
                            style={{ display: 'none' }} 
                            accept=".json" 
                            onChange={handleFileChange} 
                        />
                        <button onClick={handleCargaMasivaClick} className="btn-action">
                            Carga Masiva (JSON)
                        </button>
                        <button onClick={() => navigate('/registro')} className="btn-action">
                            Registrar Manual
                        </button>
                        <button className="btn-action">Cargar Mensajes (LZW)</button>
                    </div>
                    
                    <div className="action-row">
                        <button className="btn-report">Reporte AVL</button>
                        <button className="btn-report accent">Reporte Tabla Hash</button>
                        <button className="btn-report accent">Reporte Grafo Colaboración</button>
                    </div>
                    
                    <div className="action-row">
                        <button onClick={() => navigate('/')} className="btn-exit">Cerrar Sesión</button>
                    </div>
                </div>

                <footer className="footer-card">
                    <p><strong>Estructuras de Datos - USAC 2026</strong></p>
                    <p>Luis Cornelio Marroquín López | 202300727</p>
                </footer>
            </div>
        </div>
    );
};

export default Administrador;