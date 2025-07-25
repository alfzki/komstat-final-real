# Project Architecture Overview

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                          │
│                     (Browser/Client)                           │
└─────────────────────┬───────────────────────────────────────────┘
                      │
              ┌───────▼────────┐
              │   Nginx Proxy  │
              │  (Port 80/443) │
              └───┬─────┬──────┘
                  │     │
         ┌────────▼─┐ ┌─▼──────────┐
         │ Frontend │ │ Statistics │
         │ (React)  │ │  (Shiny)   │
         │Port 3000 │ │ Port 3838  │
         └────┬─────┘ └────────────┘
              │
              │ API Calls
              │
         ┌────▼─────┐
         │   API    │
         │(Plumber) │
         │Port 8000 │
         └────┬─────┘
              │
              │ Data Access
              │
         ┌────▼─────┐
         │   Data   │
         │  Files   │
         │(CSV/JSON)│
         └──────────┘
```

## 📁 Detailed Project Structure

```
komstat-dashboard-final-banget/
├── 📋 README.md                          # Main project documentation
├── 📋 DEPLOYMENT.md                      # Deployment troubleshooting guide
├── 🔧 .env.example                       # Environment variables template
├── 🚫 .gitignore                         # Git ignore patterns
├── 🐳 docker-compose.yml                 # Local development orchestration
├── ☁️ render.yaml                        # Render.com deployment blueprint
├── 🧪 test-deployment.ps1                # Windows deployment test script
├── 🧪 test-deployment.sh                 # Linux deployment test script
├── 🚀 dev-start.ps1                      # Windows quick start script
│
├── 🎨 frontend/                          # React.js Frontend Application
│   ├── 📦 package.json                   # Node.js dependencies and scripts
│   ├── 🐳 Dockerfile                     # Frontend container configuration
│   ├── 🚫 .dockerignore                  # Docker build exclusions
│   ├── ⚙️ tsconfig.json                  # TypeScript configuration
│   │
│   ├── 🌍 public/                        # Static assets and HTML template
│   │   ├── 📄 index.html                 # Main HTML template
│   │   └── 🖼️ assets/                    # Images and media files
│   │       ├── factory.jpg
│   │       └── profile_video_c.mp4
│   │
│   └── 📂 src/                           # React source code
│       ├── 🎯 App.tsx                    # Main application component
│       ├── 📊 Dashboard.jsx              # Dashboard container component
│       ├── 🎨 index.css                  # Global styles
│       ├── 🚀 index.tsx                  # Application entry point
│       ├── ⚙️ config.js                  # API endpoint configuration
│       │
│       ├── 🧩 components/                # Reusable UI components
│       │   ├── 📊 ChartUserByCountry.tsx
│       │   ├── 🗺️ MapScatterHeatChartandOther.jsx
│       │   ├── 📈 PageViewsBarChart.jsx
│       │   ├── 🔍 Search.tsx
│       │   ├── 📋 CustomizedDataGrid.tsx
│       │   ├── 🌍 useCountries.ts
│       │   └── 👁️ views/                 # Page-level components
│       │       ├── 📊 TahunAreaView.jsx
│       │       └── 📈 AnalisisNonParametrikView.jsx
│       │
│       ├── 🎭 contexts/                  # React context providers
│       │   └── 🌙 ShinyDarkModeContext.jsx
│       │
│       ├── 🎣 hooks/                     # Custom React hooks
│       │   └── 🌙 useShinyDarkMode.js
│       │
│       ├── 🎨 theme/                     # Material-UI theme configuration
│       │   ├── 🎨 AppTheme.tsx
│       │   ├── 🌈 themePrimitives.ts
│       │   └── ✨ customizations/
│       │
│       ├── 🛠️ utils/                     # Utility functions
│       │   ├── 🖨️ print.js
│       │   └── 🔐 sessionManager.js
│       │
│       └── 🏗️ internals/                 # Internal components and data
│           ├── 🧩 components/
│           └── 📊 data/
│               └── 📋 gridData.jsx       # Data grid management
│
├── 🖥️ server/                           # R Backend Services
│   ├── 🔌 api.R                         # Plumber API endpoints
│   ├── 🚀 start-api.R                   # API startup script
│   ├── 🐳 Dockerfile.plumber            # API container configuration
│   ├── 🐳 Dockerfile.shiny              # Shiny container configuration
│   ├── 🚫 .dockerignore                 # Docker build exclusions
│   ├── ⚠️ run_both.R                    # Legacy runner (not used in containers)
│   │
│   ├── 📱 app/                          # R Shiny Application
│   │   ├── 📱 app.R                     # Main Shiny application
│   │   ├── 📋 README.md                 # Shiny app documentation
│   │   │
│   │   ├── 🧩 modules/                  # Shiny modules
│   │   │   ├── 📥 input_panel_module.R
│   │   │   └── 📊 results_panel_module.R
│   │   │
│   │   └── 🛠️ utils/                    # Shiny utility functions
│   │       ├── 📊 csv_utils.R
│   │       ├── 🌍 emission_utils.R
│   │       ├── 🔔 notification_helpers.R
│   │       ├── 📈 plot_utils.R
│   │       ├── 📊 stat_tests.R
│   │       └── 🎨 ui_helpers.R
│   │
│   └── 📊 data/                         # Dataset files
│       ├── 🌍 countries.geojson         # Geographic country data
│       ├── 🆔 country-code-and-numeric.json # Country code mappings
│       ├── 📊 global_complete_data.json # Complete emissions dataset
│       ├── 📋 README_variabel_data_emisi.md # Data documentation
│       │
│       ├── 💨 CH4-excluding-LULUCF/     # Methane emissions data
│       │   ├── 📊 CH4-global.csv
│       │   ├── 📊 data_ch4.csv
│       │   └── 📋 Metadata_*.csv
│       │
│       ├── 💨 CO2-excluding-LULUCF/     # Carbon dioxide emissions data
│       │   ├── 📊 CO2-global.csv
│       │   ├── 📊 data_co2.csv
│       │   └── 📋 Metadata_*.csv
│       │
│       ├── 💨 N2O-excluding-LULUCF/     # Nitrous oxide emissions data
│       │   ├── 📊 data_n2o.csv
│       │   └── 📋 Metadata_*.csv
│       │
│       └── 💨 TOTAL-Greenhouse-Gases/   # Total emissions data
│           ├── 📊 data_total_greenhouse.csv
│           └── 📋 Metadata_*.csv
```

## 🔗 Service Dependencies

### Frontend Dependencies
- **React 18+**: Core framework
- **Material-UI (MUI)**: UI component library
- **React Router**: Client-side routing
- **Plotly.js**: Interactive charts
- **Country Flag Icons**: Country representations

### API Dependencies  
- **R 4.3+**: Runtime environment
- **Plumber**: REST API framework
- **jsonlite**: JSON processing
- **dplyr**: Data manipulation
- **readr**: Data reading

### Shiny Dependencies
- **R 4.3+**: Runtime environment  
- **Shiny**: Web application framework
- **bslib**: Bootstrap themes
- **DT**: Data tables
- **Plotly**: Interactive visualizations

## 🌐 Network Communication

### Development (Docker Compose)
```
Frontend (3000) ──GET───→ API (8000)
Frontend (3000) ──IFRAME─→ Shiny (3838)
```

### Production (Render.com)
```
Frontend (HTTPS) ──GET───→ API (HTTPS)
Frontend (HTTPS) ──IFRAME─→ Shiny (HTTPS)
```

## 📊 Data Flow

1. **Data Storage**: CSV/JSON files in `server/data/`
2. **API Layer**: R Plumber exposes REST endpoints
3. **Frontend**: React fetches data via API calls
4. **Analytics**: Shiny app processes data for statistical analysis
5. **Visualization**: Charts rendered in browser using Plotly.js

## 🚀 Deployment Environments

### Local Development
- **Orchestration**: Docker Compose
- **Hot Reload**: Volume mounts for live editing
- **Networking**: Internal Docker network
- **Access**: localhost ports

### Production (Render.com)
- **Orchestration**: Render's container platform
- **Scaling**: Automatic with load balancing
- **Networking**: HTTPS with custom domains
- **Monitoring**: Built-in health checks and logging

## 🔧 Configuration Management

### Environment Variables
- **Development**: `.env` file (gitignored)
- **Production**: Render.com environment variables
- **Template**: `.env.example` (version controlled)

### Build-time Configuration
- **Frontend**: React environment variables (`REACT_APP_*`)
- **Backend**: R environment variables (`Sys.getenv()`)
- **Containers**: Dockerfile ENV instructions

This architecture ensures scalability, maintainability, and easy deployment across different environments while keeping the codebase production-ready.
