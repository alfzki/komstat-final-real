// Configuration for API endpoints
const config = {
  API_BASE_URL: process.env.REACT_APP_API_URL || 'http://localhost:8000',
  SHINY_BASE_URL: process.env.REACT_APP_SHINY_URL || 'http://127.0.0.1:3838',
};

export default config;
