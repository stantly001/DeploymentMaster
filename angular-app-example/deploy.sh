#!/bin/bash
# Deployment script for Angular application to Nginx

# Display usage information
function show_usage {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -e, --environment     Environment to deploy to (dev|staging|prod) [default: dev]"
  echo "  -s, --server          Server address to deploy to [default: localhost]"
  echo "  -p, --port            SSH port to use [default: 22]"
  echo "  -u, --user            SSH user [default: ubuntu]"
  echo "  -d, --dir             Remote directory to deploy to [default: /var/www/html]"
  echo "  -h, --help            Show this help message"
  exit 1
}

# Default values
ENVIRONMENT="dev"
SERVER="localhost"
SSH_PORT="22"
SSH_USER="ubuntu"
REMOTE_DIR="/var/www/html"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -s|--server)
      SERVER="$2"
      shift 2
      ;;
    -p|--port)
      SSH_PORT="$2"
      shift 2
      ;;
    -u|--user)
      SSH_USER="$2"
      shift 2
      ;;
    -d|--dir)
      REMOTE_DIR="$2"
      shift 2
      ;;
    -h|--help)
      show_usage
      ;;
    *)
      echo "Unknown option: $1"
      show_usage
      ;;
  esac
done

# Display deployment information
echo "===== Angular App Deployment ====="
echo "Environment: $ENVIRONMENT"
echo "Server: $SERVER"
echo "SSH Port: $SSH_PORT"
echo "SSH User: $SSH_USER"
echo "Remote Directory: $REMOTE_DIR"
echo "=================================="

# Confirm deployment
read -p "Continue with deployment? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Deployment aborted."
  exit 0
fi

# Build the application for the specified environment
echo "Building Angular application for $ENVIRONMENT environment..."
if [ "$ENVIRONMENT" == "prod" ]; then
  npm run build:prod
else
  npm run build
fi

# Check if build was successful
if [ $? -ne 0 ]; then
  echo "Build failed! Aborting deployment."
  exit 1
fi

# Create a timestamp for backup
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Deploy to server
echo "Deploying to $SERVER..."
if [ "$SERVER" == "localhost" ]; then
  # Local deployment
  echo "Deploying locally..."
  
  # Backup existing deployment
  if [ -d "$REMOTE_DIR" ]; then
    echo "Backing up existing deployment..."
    sudo cp -r $REMOTE_DIR "${REMOTE_DIR}_backup_${TIMESTAMP}"
  fi
  
  # Copy new build
  echo "Copying new build to $REMOTE_DIR..."
  sudo mkdir -p $REMOTE_DIR
  sudo cp -r dist/angular-app-example/* $REMOTE_DIR
  
  # Set correct permissions
  echo "Setting permissions..."
  sudo chown -R www-data:www-data $REMOTE_DIR
  sudo chmod -R 755 $REMOTE_DIR
else
  # Remote deployment
  echo "Deploying to remote server $SERVER..."
  
  # Check if we can connect to the server
  ssh -p $SSH_PORT $SSH_USER@$SERVER "echo 'Connection successful'" || { echo "Failed to connect to $SERVER"; exit 1; }
  
  # Create remote directory if it doesn't exist
  ssh -p $SSH_PORT $SSH_USER@$SERVER "sudo mkdir -p $REMOTE_DIR"
  
  # Backup existing deployment
  echo "Backing up existing deployment on remote server..."
  ssh -p $SSH_PORT $SSH_USER@$SERVER "if [ -d \"$REMOTE_DIR\" ] && [ \"\$(ls -A $REMOTE_DIR)\" ]; then sudo cp -r $REMOTE_DIR ${REMOTE_DIR}_backup_${TIMESTAMP}; fi"
  
  # Copy new build
  echo "Copying new build to remote server..."
  scp -P $SSH_PORT -r dist/angular-app-example/* $SSH_USER@$SERVER:/tmp/angular-deploy
  
  # Move to final location and set permissions
  ssh -p $SSH_PORT $SSH_USER@$SERVER "sudo cp -r /tmp/angular-deploy/* $REMOTE_DIR && sudo rm -rf /tmp/angular-deploy && sudo chown -R www-data:www-data $REMOTE_DIR && sudo chmod -R 755 $REMOTE_DIR"
fi

# Configure Nginx
echo "Configuring Nginx..."
if [ "$SERVER" == "localhost" ]; then
  # Local Nginx configuration
  sudo cp nginx.conf /etc/nginx/conf.d/angular-app.conf
  sudo nginx -t
  if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    echo "Nginx configuration updated and reloaded."
  else
    echo "Nginx configuration test failed. Please check the configuration."
    exit 1
  fi
else
  # Remote Nginx configuration
  scp -P $SSH_PORT nginx.conf $SSH_USER@$SERVER:/tmp/angular-app.conf
  ssh -p $SSH_PORT $SSH_USER@$SERVER "sudo cp /tmp/angular-app.conf /etc/nginx/conf.d/angular-app.conf && sudo nginx -t && sudo systemctl reload nginx"
  if [ $? -ne 0 ]; then
    echo "Remote Nginx configuration failed. Please check the configuration."
    exit 1
  fi
fi

echo "======================================"
echo "Deployment completed successfully!"
echo "Application deployed to: $SERVER:$REMOTE_DIR"
echo "======================================"