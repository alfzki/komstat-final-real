# Quick development setup script
# This script creates a .env file and starts the development environment

Write-Host "🚀 Setting up development environment..." -ForegroundColor Green

# Create .env file if it doesn't exist
if (!(Test-Path ".env")) {
    Write-Host "📝 Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created. You can edit it if needed." -ForegroundColor Green
}
else {
    Write-Host "📝 .env file already exists" -ForegroundColor Blue
}

# Build and start services
Write-Host "🐳 Starting Docker services..." -ForegroundColor Yellow
docker-compose up --build

# Note: This will block until you press Ctrl+C
Write-Host "🛑 Press Ctrl+C to stop all services" -ForegroundColor Red
