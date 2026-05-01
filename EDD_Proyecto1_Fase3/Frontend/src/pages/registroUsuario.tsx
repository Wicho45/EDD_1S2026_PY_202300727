import { useState } from 'react';
import { useNavigate } from 'react-router-dom'; 
import logo from '../assets/logo.png';
import './registroUsuario.css';

const RegistroUsuario = () => {
  const navigate = useNavigate(); 
  const [formData, setFormData] = useState({
    numero_colegio: '',
    nombre_completo: '',
    tipo_usuario: 'TIPO-01',
    departamento: '',
    especialidad: '',
    contrasena: '',
    confirmar_contrasena: ''
  });

  const [error, setError] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (formData.contrasena !== formData.confirmar_contrasena) {
      setError('Las contraseñas no coinciden');
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
          departamento: formData.departamento === '' ? null : formData.departamento,
          especialidad: formData.especialidad,
          contrasena: formData.contrasena
        })
      });

      if (response.ok) {
        alert("Registro exitoso. Ahora puedes iniciar sesión.");
        navigate('/'); 
      } else {
        const data = await response.json();
        setError(data.mensaje || 'Error al registrar usuario');
      }
    } catch (err) {
      setError('No se pudo conectar con el servidor de MedTrack o problema del servidor' + (err instanceof Error ? `: ${err.message}` : ''));
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
          <p className="form-instruction">Complete la información profesional para su ingreso al sistema</p>
          
          {error && <p className="error-msg">{error}</p>}

          <div className="form-grid">
            <div className="input-group">
              <label>Número de Colegio</label>
              <input type="text" name="numero_colegio" placeholder="COL-XXXXX" required onChange={handleChange} />
            </div>

            <div className="input-group">
              <label>Nombre Completo</label>
              <input type="text" name="nombre_completo" placeholder="Nombre Apellido" required onChange={handleChange} />
            </div>

            <div className="input-group">
              <label>Tipo de Usuario</label>
              <select name="tipo_usuario" value={formData.tipo_usuario} onChange={handleChange}>
                <option value="TIPO-01">Médico General</option> 
                <option value="TIPO-02">Especialista / Cirujano</option> 
                <option value="TIPO-03">Enfermero/a</option> 
                <option value="TIPO-04">Técnico de Laboratorio</option> 
              </select>
            </div>

            <div className="input-group">
              <label>Departamento (Opcional)</label>
              <input type="text" name="departamento" placeholder="Ej: DEP-MED" onChange={handleChange} />
            </div>

            <div className="input-group">
              <label>Especialidad</label>
              <input type="text" name="especialidad" placeholder="Ej: Pediatría" required onChange={handleChange} />
            </div>

            <div className="input-group">
              <label>Contraseña</label>
              <input type="password" name="contrasena" placeholder="••••••••" required onChange={handleChange} />
            </div>

            <div className="input-group confirmar">
              <label>Confirmar Contraseña</label>
              <input type="password" name="confirmar_contrasena" placeholder="••••••••" required onChange={handleChange} />
            </div>
          </div>

          <div className="button-container">
            <button type="submit" className="btn-main">Crear Cuenta</button>
            <button type="button" className="btn-secondary" onClick={() => navigate('/')}>Volver al Login</button>
          </div>
        </form>

        <footer className="footer-card">
          <p><strong>Estructuras de Datos - USAC 2026</strong></p>
          <p>Luis Cornelio Marroquín López | 202300727</p>
        </footer>
      </div>
    </div>
  );
};

export default RegistroUsuario;