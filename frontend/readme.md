# Frontend - React Dashboard

## 🚀 Quick Start with Docker (Recommended)

```bash
# From project root directory
docker-compose up --build frontend
```

The frontend will be available at http://localhost:3000

## 📦 Manual Installation

**Install dependencies:**
```bash
npm install
```

**Run development server:**
```bash
npm start
```

## 🏗️ Building for Production

**Build static files:**
```bash
npm run build
```

**Test production build locally:**
```bash
# After building
npx serve -s build -l 3000
```

## 🔧 Environment Variables

Create a `.env` file in the frontend directory for local configuration:

```bash
REACT_APP_API_URL=http://localhost:8000
REACT_APP_SHINY_URL=http://localhost:3838
```

## 🐳 Docker Configuration

The frontend uses a multi-stage Docker build:
- **Stage 1**: Node.js for building the React application
- **Stage 2**: Nginx for serving static files in production

For local development, use the root-level `docker-compose.yml` file. 