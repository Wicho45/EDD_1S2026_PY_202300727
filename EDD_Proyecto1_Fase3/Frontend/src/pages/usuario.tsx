import { useState } from 'react';
import { useNavigate } from 'react-router-dom'; 
import logo from '../assets/logo.png';

const Usuario = () => {


    return (
<div id="center-register">
      <div className="main-card-register">
        <div className="header-text">
          <img src={logo} className="medtrack-logo" alt="Logo" />
          <h1>Registro de Personal</h1>
        </div>
            

        <footer className="footer-card">
          <p><strong>Estructuras de Datos - USAC 2026</strong></p>
          <p>Luis Cornelio Marroquín López | 202300727</p>
        </footer>
      </div>
    </div>
    );

};

export default Usuario;
