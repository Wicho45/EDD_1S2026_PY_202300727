import { useState } from 'react'
import { Routes, Route, useNavigate } from 'react-router-dom'
import RegistroUsuario from './pages/registroUsuario.tsx'
import Administrador from './pages/administrador.tsx' 
import logo from './assets/logo.png' 
import './App.css'

function Login() {
  const [usuario, setUsuario] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const navigate = useNavigate(); 

  const handleLogin = async () => {
    setError('');
    
    if (usuario === 'AdminHospital' && password === 'MedTrack2026') {
        console.log("Acceso concedido como Administrador");
        navigate('/administrador');
        return;
    }

    try {
      const response = await fetch('http://localhost:3000/login', {
        method: 'POST', 
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: usuario, password: password })
      });

      const data = await response.json();

      if (response.ok) {
        console.log("Login exitoso. Rol:", data.tipo_usuario);
      } else {
        setError(data.mensaje || 'Credenciales incorrectas');
      }
    } catch (err) {
      setError('Error de conexión con el servidor Mojolicious');
    }
  };

  return (
    <section id="center">
      <div className="main-card">
        <div className="hero">
          <img src={logo} className="medtrack-logo" alt="MedTrack Logo" />
        </div>
        <div className="header-text">
          <h1>EDD MedTrack F3</h1>
        </div>
        <div className="login-form">
          {error && <p className="error-msg">{error}</p>}
          <div className="input-group">
            <label>Número de Colegio / Usuario</label>
            <input 
              type="text" 
              placeholder="COL-XXXXX " 
              value={usuario}
              onChange={(e) => setUsuario(e.target.value)}
            />
          </div>
          <div className="input-group">
            <label>Contraseña</label>
            <input 
              type="password" 
              placeholder="••••••••" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <button className="btn" onClick={handleLogin}>Iniciar sesión</button>
          <button className="btn btn-secondary" onClick={() => navigate('/registro')}>
            Registrar
          </button>
        </div>
      </div>
    </section>
  );
}

function App() {
  return (
    <>
      <Routes>
        <Route path="/" element={<Login />} />
        
        <Route path="/registro" element={<RegistroUsuario />} />
        <Route path="/administrador" element = {<Administrador />} />
      </Routes>

      <footer className="footer-global">
        <p><strong>Estructuras de Datos - USAC 2026</strong></p>
        <p>Luis Cornelio Marroquín López | 202300727</p>
      </footer>
    </>
  )
}

export default App