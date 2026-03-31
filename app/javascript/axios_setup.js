import "axios";

// Configuración global de Axios
window.axios = axios;

// Incluir token CSRF para proteger las solicitudes en Rails
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
window.axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;

// Configuración de encabezados adicionales (opcional)
window.axios.defaults.headers.common['Accept'] = 'application/json';
