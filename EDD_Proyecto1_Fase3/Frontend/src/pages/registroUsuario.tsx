import { useState, useMemo } from 'react'; 
import { useNavigate } from 'react-router-dom'; 
import logo from '../assets/logo.png';
import './registroUsuario.css';

const RegistroUsuario = () => {
  const navigate = useNavigate(); 
  const [formData, setFormData] = useState({
    numero_colegio: '',
    nombre_completo: '',
    tipo_usuario: '', 
    departamento_texto: 'Sin departamento asignado', 
    especialidad: '',
    contrasena: '',
    confirmar_contrasena: ''
  });

  const [error, setError] = useState('');

  const departamentosDisponibles = useMemo(() => {
    const base = ["Sin departamento asignado"];
    
    switch (formData.tipo_usuario) {
      case 'TIPO-01': return [...base, "Medicina general y consulta externa"];
      case 'TIPO-02': return [...base, "Cirugía y quirofanos"];
      case 'TIPO-03': return [...base, "Medicina general y consulta externa", "Cirugía y quirofanos", "Farmacia hospitalaria"];
      case 'TIPO-04': return [...base, "Laboratorio clínico"];
      default: return [];
    }
  }, [formData.tipo_usuario]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    
    if (name === 'tipo_usuario') {
        setFormData(prev => ({
            ...prev,
            tipo_usuario: value,
            departamento_texto: "Sin departamento asignado"
        }));
    } else {
        setFormData(prev => ({ ...prev, [name]: value }));
    }
  };

  const mapearDepartamento = (actual: string) => {
    const mapa: { [key: string]: string } = {
        "Medicina general y consulta externa": "DEP-MED",
        "Cirugía y quirofanos": "DEP-CIR",
        "Laboratorio clínico": "DEP-LAB",
        "Farmacia hospitalaria": "DEP-FAR",
        "Sin departamento asignado": "null"
    };
    return mapa[actual] || "null";
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (formData.contrasena !== formData.confirmar_contrasena) {
        setError("Las contraseñas no coinciden.");
        return;
    }

    if (!/^COL-\d{5}$/.test(formData.numero_colegio)) {
        setError("Formato incorrecto (COL-XXXXX).");
        return;
    }

    try {
      const response = await fetch('http://127.0.0.1:3000/registro', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          numero_colegio: formData.numero_colegio,
          nombre_completo: formData.nombre_completo,
          tipo_usuario: formData.tipo_usuario,
          departamento: mapearDepartamento(formData.departamento_texto),
          especialidad: formData.especialidad,
          contrasena: formData.contrasena
        })
      });

      if (response.ok) {
        alert("Usuario registrado exitosamente.");
        navigate('/'); 
      } else {
        const data = await response.json();
        setError(data.mensaje || 'Error al registrar');
      }
    } catch (err) {
      setError('No se pudo conectar con el servidor.' + (err instanceof Error ? err.message : ""));
    }
  };

  return (
    <div id="center-register">
      <div className="main-card-register">
        <div className="header-text">
          <img src={logo} className="medtrack-logo" alt="Logo" />
          <h1>Registro de Personal</h1>
        </div>

        <form className="register-form" onSubmit={handleRegister}>
          {error && <p className="error-msg">{error}</p>}

          <div className="form-grid">
            <div className="input-group">
              <label>Nombre Completo</label>
              <input type="text" name="nombre_completo" required onChange={handleChange} />
            </div>

            <div className="input-group">
              <label>Número de Colegio</label>
              <input type="text" name="numero_colegio" placeholder="COL-XXXXX" required onChange={handleChange} />
            </div>

            <div className="input-group">
              <label>Tipo de Personal</label>
              <select name="tipo_usuario" value={formData.tipo_usuario} required onChange={handleChange}>
                <option value="">Seleccione...</option>
                <option value="TIPO-01">TIPO-01 - Médico General</option> 
                <option value="TIPO-02">TIPO-02 - Médico Especialista</option> 
                <option value="TIPO-03">TIPO-03 - Enfermero/a</option> 
                <option value="TIPO-04">TIPO-04 - Técnico de Lab</option> 
              </select>
            </div>

            <div className="input-group">
              <label>Departamento</label>
              <select 
                name="departamento_texto" 
                value={formData.departamento_texto} 
                required 
                onChange={handleChange}
                disabled={departamentosDisponibles.length === 0}
              >
                {departamentosDisponibles.length === 0 ? (
                    <option value="">Seleccione tipo primero...</option>
                ) : (
                    departamentosDisponibles.map((dep, index) => (
                        <option key={index} value={dep}>{dep}</option>
                    ))
                )}
              </select>
            </div>

            <div className="input-group">
              <label>Especialidad</label>
              <input type="text" name="especialidad" required onChange={handleChange} />
            </div>

            <div className="input-group">
              <label>Contraseña</label>
              <input type="password" name="contrasena" required onChange={handleChange} />
            </div>

            <div className="input-group confirmar">
              <label>Confirmar Contraseña</label>
              <input type="password" name="confirmar_contrasena" required onChange={handleChange} />
            </div>
          </div>

          <div className="button-container">
            <button type="submit" className="btn-main">Registrar</button>
            <button type="button" className="btn-secondary" onClick={() => navigate(-1)}>Regresar</button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RegistroUsuario;