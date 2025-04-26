# Stage 1: Build the Angular application
FROM node:16-alpine as build
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Build the application for production
RUN npm run build:prod

# Stage 2: Serve the app with Nginx
FROM nginx:1.21-alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Angular app from previous stage
COPY --from=build /app/dist/angular-app-example /usr/share/nginx/html

# Expose ports
EXPOSE 80 443

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]