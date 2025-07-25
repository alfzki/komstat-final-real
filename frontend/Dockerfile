# Multi-stage build for React app
# Stage 1: Build the React application
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Set build-time environment variables
ARG REACT_APP_API_URL
ARG REACT_APP_SHINY_URL
ENV REACT_APP_API_URL=${REACT_APP_API_URL}
ENV REACT_APP_SHINY_URL=${REACT_APP_SHINY_URL}

# Build the application dengan memory limit dan skip ESLint
ENV NODE_OPTIONS="--max_old_space_size=8192"
ENV DISABLE_ESLINT_PLUGIN=true
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the build output to Nginx's serve directory
COPY --from=build /app/build /usr/share/nginx/html

# Create optimized Nginx configuration for React SPA
RUN echo 'server { \
    listen 80; \
    server_name _; \
    \
    # Gzip compression \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript; \
    \
    # Security headers \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
    \
    # Handle React Router (SPA routing) \
    location / { \
    root /usr/share/nginx/html; \
    index index.html; \
    try_files $uri $uri/ /index.html; \
    } \
    \
    # Cache static assets \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ { \
    root /usr/share/nginx/html; \
    expires 1y; \
    add_header Cache-Control "public, immutable"; \
    } \
    \
    # Health check endpoint \
    location /health { \
    access_log off; \
    return 200 "healthy\\n"; \
    add_header Content-Type text/plain; \
    } \
    }' > /etc/nginx/conf.d/default.conf

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf.dpkg-dist 2>/dev/null || true

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]