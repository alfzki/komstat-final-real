# Dashboard Mata Kuliah Komputasi Statistik React JS + R

Dashboard ini menampilkan visualisasi gas efek rumah kaca secara global dan juga disertai analisis non parametriknya.  
Bagian frontend dashboard dibangun dengan React JS, sedangkan bagian backend menggunakan R. Bagian tampilan analisis dibuat dengan RShiny.

## 🚀 Quick Start with Docker (Recommended)

### Prerequisites
- Docker and Docker Compose installed on your system
- Git for cloning the repository

### Local Development Setup

1. **Clone the Repository**
```bash
git clone <repository-url>
cd komstat-dashboard-final-banget
```

2. **Create Environment File**
```bash
cp .env.example .env
# Edit .env file with your local configuration if needed
```

3. **Build and Run with Docker Compose**
```bash
docker-compose up --build
```

4. **Access the Applications**
- **Frontend Dashboard**: http://localhost:3000
- **R Plumber API**: http://localhost:8000
- **R Shiny Statistics App**: http://localhost:3838

### Individual Service Commands

```bash
# Build and run only the API
docker-compose up --build api

# Build and run only the Shiny app
docker-compose up --build shiny

# Build and run only the frontend
docker-compose up --build frontend

# Stop all services
docker-compose down
```

### Testing Individual Components

```bash
# Test only the frontend build (Windows)
.\test-frontend-build.ps1

# Test complete deployment
.\test-deployment.ps1
```

## 🌐 Production Deployment on Render.com

This project is configured for one-click deployment on Render.com using the included `render.yaml` blueprint.

### Automatic Deployment
1. Fork or push this repository to GitHub
2. Connect your GitHub repository to Render.com
3. Render will automatically detect the `render.yaml` file and deploy all services

### Manual Service Creation
If you prefer to create services manually:

1. **Frontend (Static Site)**
   - Environment: Static Site
   - Build Command: `cd frontend && npm install && npm run build`
   - Publish Directory: `./frontend/build`

2. **API Service (Web Service)**
   - Environment: Docker
   - Dockerfile Path: `./server/Dockerfile.plumber`
   - Docker Context: `./server`

3. **Shiny Service (Web Service)**
   - Environment: Docker
   - Dockerfile Path: `./server/Dockerfile.shiny`
   - Docker Context: `./server`

## 🛠 Manual Installation (Legacy Method)

### Prerequisites
- Node.js (v16 or higher)
- R (v4.0 or higher)
- Required R packages

### Frontend Setup
```bash
cd frontend
npm install
npm start
```

### Backend Setup
```bash
cd server
Rscript run_both.R
# This will automatically install required R dependencies
```

### Missing R Packages
If any R packages are missing, install them manually:
```r
# Example for missing package "car"
install.packages("car")

# Or use this pattern:
if (!require("car", character.only = TRUE)) {
    install.packages("car")
    library("car")
}
```

## 📁 Project Structure

```
├── frontend/                 # React.js frontend application
│   ├── src/                 # React source code
│   ├── public/              # Static assets
│   ├── package.json         # Node.js dependencies
│   └── Dockerfile           # Frontend container configuration
├── server/                  # R backend services
│   ├── api.R               # Plumber API endpoints
│   ├── app/                # Shiny application
│   ├── data/               # Data files (CSV, JSON)
│   ├── Dockerfile.plumber  # API container configuration
│   └── Dockerfile.shiny    # Shiny container configuration
├── docker-compose.yml      # Local development orchestration
├── render.yaml            # Render.com deployment blueprint
└── .env.example          # Environment variables template
```

## 🔧 Environment Variables

The application uses environment variables for configuration. Copy `.env.example` to `.env` and adjust values as needed:

- `API_PORT`: Port for the R Plumber API (default: 8000)
- `SHINY_PORT`: Port for the Shiny application (default: 3838)
- `DATA_DIR`: Directory containing data files (default: ./server/data)
- `REACT_APP_API_URL`: Frontend API endpoint URL
- `REACT_APP_SHINY_URL`: Frontend Shiny app URL

## 🐳 Docker Services

### API Service (Plumber)
- **Base Image**: `rocker/r-ver:4.3.0`
- **Exposed Port**: 8000
- **Health Check**: `/countries` endpoint

### Shiny Service
- **Base Image**: `rocker/shiny:4.3.0`
- **Exposed Port**: 3838
- **Features**: Statistical analysis and visualization

### Frontend Service
- **Base Image**: `nginx:alpine` (production)
- **Exposed Port**: 80 (production) / 3000 (development)
- **Features**: React SPA with Material-UI

## 🚨 Troubleshooting

### Docker Issues
```bash
# Remove all containers and images to start fresh
docker-compose down --rmi all --volumes --remove-orphans

# Check logs for specific service
docker-compose logs api
docker-compose logs shiny
docker-compose logs frontend
```

### Port Conflicts
If you encounter port conflicts, update the port mappings in `docker-compose.yml` or set different values in your `.env` file.

### Missing Data Files
Ensure all data files are present in the `server/data/` directory before building the Docker containers.

## 📊 Features

- **Interactive Dashboard**: Real-time greenhouse gas emissions visualization
- **Statistical Analysis**: Non-parametric statistical tests via R Shiny
- **Global Coverage**: Country-wise emission data and trends
- **Responsive Design**: Material-UI based responsive interface
- **Containerized Deployment**: Docker-based microservices architecture

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker Compose
5. Submit a pull request

## 📄 License

This project is developed for educational purposes as part of Statistical Computing coursework.
