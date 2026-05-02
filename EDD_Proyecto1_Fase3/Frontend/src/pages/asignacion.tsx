import { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import logo from '../assets/logo.png';
import './asignacion.css';

interface UsuarioPersonal {
    numero_colegio: string;
    username: string;
    tipo: string;
    especialidad: string;
    departamento: string;
}

const Asignacion = () => {
    const navigate = useNavigate();
    const [usuarios, setUsuarios] = useState<UsuarioPersonal[]>([]);
    
    // Estados para el formulario
    const [selectedColegio, setSelectedColegio] = useState<string>('');
    const [selectedDeptTexto, setSelectedDeptTexto] = useState<string>('');
    const [mensaje, setMensaje] = useState<{texto: string, tipo: 'error' | 'exito'} | null>(null);

    const obtenerUsuarios = async () => {
        try {
            const res = await fetch('http://127.0.0.1:3000/personal');
            if (res.ok) {
                const data: UsuarioPersonal[] = await res.json();
                setUsuarios(data);
            }
        } catch (err) {
            console.error("Error al refrescar usuarios:", err);
        }
    };

    useEffect(() => {
        let isMounted = true;
        fetch('http://127.0.0.1:3000/personal')
            .then(res => res.json())
            .then(data => {
                if (isMounted) setUsuarios(data);
            })
            .catch(console.error);

        return () => { isMounted = false; };
    }, []);

    // Filtrar usuarios pendientes
    const usuariosPendientes = useMemo(() => {
        return usuarios.filter(u => !u.departamento || u.departamento === 'null' || u.departamento === 'SIN-DEP');
    }, [usuarios]);

    // Obtener el usuario seleccionado
    const usuarioSeleccionado = useMemo(() => {
        return usuarios.find(u => u.numero_colegio === selectedColegio);
    }, [selectedColegio, usuarios]);

    // Departamentos disponibles
    const departamentosDisponibles = useMemo(() => {
        if (!usuarioSeleccionado) return [];
        switch (usuarioSeleccionado.tipo) {
            case 'TIPO-01': return ["Medicina general y consulta externa"];
            case 'TIPO-02': return ["Cirugía y quirofanos"];
            case 'TIPO-03': return ["Medicina general y consulta externa", "Cirugía y quirofanos", "Farmacia hospitalaria"];
            case 'TIPO-04': return ["Laboratorio clínico"];
            default: return [];
        }
    }, [usuarioSeleccionado]);

    const handleUsuarioSelect = (colegio: string) => {
        setSelectedColegio(colegio);
        
        const usuario = usuarios.find(u => u.numero_colegio === colegio);
        if (usuario) {
            switch (usuario.tipo) {
                case 'TIPO-01': setSelectedDeptTexto("Medicina general y consulta externa"); break;
                case 'TIPO-02': setSelectedDeptTexto("Cirugía y quirofanos"); break;
                case 'TIPO-03': setSelectedDeptTexto("Medicina general y consulta externa"); break;
                case 'TIPO-04': setSelectedDeptTexto("Laboratorio clínico"); break;
                default: setSelectedDeptTexto('');
            }
        } else {
            setSelectedDeptTexto('');
        }
    };

    const mapearDepartamento = (actual: string) => {
        const mapa: { [key: string]: string } = {
            "Medicina general y consulta externa": "DEP-MED",
            "Cirugía y quirofanos": "DEP-CIR",
            "Laboratorio clínico": "DEP-LAB",
            "Farmacia hospitalaria": "DEP-FAR"
        };
        return mapa[actual] || "";
    };

    const handleAsignar = async (e: React.FormEvent) => {
        e.preventDefault();
        setMensaje(null);

        if (!selectedColegio || !selectedDeptTexto) {
            setMensaje({ texto: 'Seleccione un usuario y un departamento válido.', tipo: 'error' });
            return;
        }

        try {
            const response = await fetch('http://127.0.0.1:3000/asignar-departamento', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    numero_colegio: selectedColegio,
                    departamento: mapearDepartamento(selectedDeptTexto)
                })
            });

            if (response.ok) {
                setMensaje({ texto: 'Departamento asignado/reasignado exitosamente.', tipo: 'exito' });
                await obtenerUsuarios(); 
                setSelectedColegio('');
                setSelectedDeptTexto('');
            } else {
                const data = await response.json();
                setMensaje({ texto: data.mensaje || 'Error al procesar la asignación.', tipo: 'error' });
            }
        } catch (err) {
            setMensaje({ texto: 'Error de conexión con el servidor.' + err, tipo: 'error' });
        }
    };

    return (
        <div id="asignacion-container">
            <div className="asignacion-card">
                <header className="asignacion-header">
                    <img src={logo} className="asignacion-logo" alt="Logo" />
                    <h1>Gestión de Departamentos</h1>
                    <button onClick={() => navigate(-1)} className="btn-back">⬅ Volver al Panel</button>
                </header>

                <section className="seccion-pendientes">
                    <h2>Panel de usuarios pendientes de asignación</h2>
                    <p className="instruccion">Haz clic en un usuario para seleccionarlo en el formulario.</p>
                    <div className="table-container-asignacion">
                        <table className="tabla-pendientes">
                            <thead>
                                <tr>
                                    <th>No. Colegio</th>
                                    <th>Nombre Completo</th>
                                    <th>Tipo</th>
                                    <th>Especialidad</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                {usuariosPendientes.length > 0 ? (
                                    usuariosPendientes.map(u => (
                                        <tr 
                                            key={u.numero_colegio} 
                                            onClick={() => handleUsuarioSelect(u.numero_colegio)}
                                            className={selectedColegio === u.numero_colegio ? 'fila-seleccionada' : ''}
                                        >
                                            <td>{u.numero_colegio}</td>
                                            <td>{u.username}</td>
                                            <td>{u.tipo}</td>
                                            <td>{u.especialidad || 'N/A'}</td>
                                            <td className="badge-pendiente">Pendiente</td>
                                        </tr>
                                    ))
                                ) : (
                                    <tr>
                                        <td colSpan={5} style={{ textAlign: 'center' }}>No hay usuarios pendientes de asignación.</td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </section>

                <hr className="divider" />

                <section className="seccion-formulario">
                    <h2>Asignación o reasignación de departamento</h2>
                    {mensaje && (
                        <div className={`mensaje-alerta ${mensaje.tipo}`}>
                            {mensaje.texto}
                        </div>
                    )}
                    
                    <form className="form-asignacion" onSubmit={handleAsignar}>
                        <div className="form-grupo">
                            <label>Usuario a asignar/reasignar</label>
                            <select 
                                value={selectedColegio} 
                                onChange={(e) => handleUsuarioSelect(e.target.value)} 
                                required
                            >
                                <option value="">-- Seleccione un usuario --</option>
                                {usuarios.map(u => (
                                    <option key={u.numero_colegio} value={u.numero_colegio}>
                                        {u.numero_colegio} - {u.username} ({u.departamento === 'null' || !u.departamento ? 'Sin Asignar' : u.departamento})
                                    </option>
                                ))}
                            </select>
                        </div>

                        <div className="form-grupo">
                            <label>Nuevo Departamento</label>
                            <select 
                                value={selectedDeptTexto} 
                                onChange={(e) => setSelectedDeptTexto(e.target.value)} 
                                required
                                disabled={!usuarioSeleccionado || departamentosDisponibles.length === 0}
                            >
                                {departamentosDisponibles.length === 0 ? (
                                    <option value="">Seleccione un usuario primero</option>
                                ) : (
                                    departamentosDisponibles.map((dep, index) => (
                                        <option key={index} value={dep}>{dep}</option>
                                    ))
                                )}
                            </select>
                            {usuarioSeleccionado && (
                                <small className="nota-tipo">
                                    Opciones limitadas por el cargo: <strong>{usuarioSeleccionado.tipo}</strong>
                                </small>
                            )}
                        </div>

                        <div className="form-acciones">
                            <button type="submit" className="btn-asignar">Guardar Asignación</button>
                        </div>
                    </form>
                </section>
            </div>
        </div>
    );
};

export default Asignacion;