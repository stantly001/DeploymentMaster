# Multi-stage Dockerfile for Angular application

###############
# BUILD STAGE #
###############
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Build the Angular application with production configuration
RUN npm run build -- --configuration production

###############
# TEST STAGE  #
###############
FROM build AS test

# Run tests
RUN npm run test -- --browsers=ChromeHeadless --watch=false

##################
# SECURITY SCAN  #
##################
FROM build AS security-scan

# Install security scanning tools
RUN npm install -g snyk
# Run security scan (commented out as it requires authentication)
# RUN snyk test

###############
# FINAL STAGE #
###############
FROM nginx:alpine

# Copy custom nginx config
COPY nginx-prod.conf /etc/nginx/nginx.conf

# Copy the build output from the build stage
COPY --from=build /app/dist/angular-app /usr/share/nginx/html

# Copy SSL configuration if needed
# COPY ssl/ /etc/nginx/ssl/

# Set permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/nginx.conf && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

# Expose ports
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]