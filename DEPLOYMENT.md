# Deployment Troubleshooting Guide

## Quick Start

### Local Development
```bash
# 1. Clone the repository
git clone <your-repo-url>
cd komstat-dashboard-final-banget

# 2. Create environment file
cp .env.example .env

# 3. Start with Docker Compose
docker-compose up --build

# 4. Access applications
# Frontend: http://localhost:3000
# API: http://localhost:8000
# Shiny: http://localhost:3838
```

### Windows PowerShell Quick Start
```powershell
# Use the convenience script
.\dev-start.ps1

# Or test deployment
.\test-deployment.ps1
```

## Common Issues and Solutions

### 1. Port Conflicts
**Problem**: "Port already in use" errors
**Solution**: 
- Check what's using the ports: `netstat -ano | findstr :8000`
- Kill the process or change ports in `.env` file
- Update `docker-compose.yml` port mappings if needed

### 2. Data Files Not Found
**Problem**: API fails with "data file not found" errors
**Solution**: 
- Ensure all files exist in `server/data/` directory
- Check file permissions
- Verify DATA_DIR environment variable

### 3. R Package Installation Fails
**Problem**: Docker build fails installing R packages
**Solution**: 
- Clear Docker cache: `docker system prune -a`
- Update R package versions in Dockerfile
- Check network connectivity during build

### 4. Frontend Can't Connect to API
**Problem**: Frontend shows network errors
**Solution**: 
- Verify API is running: `curl http://localhost:8000/health`
- Check REACT_APP_API_URL in environment
- Ensure API CORS is properly configured

### 5. Shiny App Won't Load
**Problem**: Iframe shows connection refused
**Solution**: 
- Check Shiny container logs: `docker-compose logs shiny`
- Verify REACT_APP_SHINY_URL is correct
- Test Shiny directly: `curl http://localhost:3838`

## Environment Variables Reference

### Development (.env file)
```env
# API Configuration
API_PORT=8000
API_HOST=127.0.0.1
DATA_DIR=./server/data

# Shiny Configuration  
SHINY_PORT=3838
SHINY_HOST=127.0.0.1

# Frontend Configuration
REACT_APP_API_URL=http://localhost:8000
REACT_APP_SHINY_URL=http://localhost:3838
```

### Production (Render.com)
- Services automatically get environment variables from `render.yaml`
- URLs are auto-generated based on service names
- No manual configuration needed for basic setup

## Docker Commands Reference

```bash
# Build and start all services
docker-compose up --build

# Start in background
docker-compose up -d

# View logs
docker-compose logs [service-name]

# Stop all services
docker-compose down

# Clean up everything
docker-compose down --volumes --remove-orphans
docker system prune -a

# Rebuild specific service
docker-compose build [service-name]
docker-compose up [service-name]
```

## Render.com Deployment

### Automatic Deployment
1. Push code to GitHub
2. Connect repository to Render.com
3. Render automatically detects `render.yaml` and deploys all services

### Manual Service Setup
If auto-deployment fails, create services manually:

**Frontend Service:**
- Type: Static Site
- Build Command: `cd frontend && npm install && npm run build`
- Publish Directory: `./frontend/build`
- Environment Variables: Set API and Shiny URLs

**API Service:**
- Type: Web Service
- Environment: Docker
- Dockerfile Path: `./server/Dockerfile.plumber`
- Context: `./server`

**Shiny Service:**
- Type: Web Service  
- Environment: Docker
- Dockerfile Path: `./server/Dockerfile.shiny`
- Context: `./server`

## Health Check Endpoints

- **API Health**: `GET /health` - Returns service status and data loading info
- **API Countries**: `GET /countries` - Returns list of available countries
- **Frontend**: Root URL serves React app
- **Shiny**: Root URL serves Shiny application

## Performance Optimization

### Local Development
- Use Docker Compose for consistent environment
- Enable Docker BuildKit for faster builds
- Use volume mounts for live code editing

### Production  
- Services run on Render.com's infrastructure
- Automatic HTTPS and CDN
- Health checks ensure service availability
- Horizontal scaling available on paid plans

## Security Considerations

### Environment Variables
- Never commit `.env` files to git
- Use different values for development vs production
- Sensitive data should use Render's secret management

### CORS Configuration
- API configured to accept requests from frontend domain
- Shiny app embedded in iframe with proper headers
- No authentication required for public dashboard

## Monitoring and Logs

### Local Development
```bash
# View real-time logs
docker-compose logs -f

# Service-specific logs
docker-compose logs -f api
docker-compose logs -f shiny
docker-compose logs -f frontend
```

### Production (Render.com)
- Use Render dashboard for logs and metrics
- Health check endpoints for automated monitoring
- Email notifications for service failures
