#!/usr/bin/env node

/**
 * Nginx Configuration Generator for Angular Applications
 * 
 * This script generates Nginx configuration files based on templates and environment variables.
 * It can be used in CI/CD pipelines to customize Nginx configurations for different environments.
 * 
 * Usage:
 *   node nginx-config-generator.js --env=prod --domain=example.com --output=./nginx.conf
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2).reduce((result, arg) => {
  const [key, value] = arg.replace(/^--/, '').split('=');
  result[key] = value;
  return result;
}, {});

// Default values
const env = args.env || 'dev';
const domain = args.domain || 'example.com';
const apiUrl = args.api || 'http://api:8080';
const sslEnabled = args.ssl !== 'false';
const output = args.output || './nginx.conf';

// Read the template file
const templatePath = path.join(__dirname, '..', `nginx-${env}.conf`);
if (!fs.existsSync(templatePath)) {
  console.error(`Template file not found: ${templatePath}`);
  process.exit(1);
}

let template = fs.readFileSync(templatePath, 'utf8');

// Replace variables in the template
template = template.replace(/example\.com/g, domain);
template = template.replace(/http:\/\/api-backend:8080/g, apiUrl);

// Toggle SSL configuration
if (!sslEnabled) {
  // Comment out SSL-specific configuration
  template = template.replace(/(\s*listen 443 ssl.*)/g, '    # $1');
  template = template.replace(/(\s*ssl_certificate .*)/g, '    # $1');
  template = template.replace(/(\s*ssl_certificate_key .*)/g, '    # $1');
  
  // Remove HTTPS redirect
  template = template.replace(/(\s*return 301 https:\/\/\$host\$request_uri;)/g, '    # $1');
  
  // Update security headers that require HTTPS
  template = template.replace(/(add_header Strict-Transport-Security .*)/g, '    # $1');
}

// Write the generated configuration
fs.writeFileSync(output, template);
console.log(`Nginx configuration generated at: ${output}`);

// Additional helper functions
function generateServerBlock(options) {
  const { serverName, root, locations } = options;
  
  let serverBlock = `server {
    listen 80;
    server_name ${serverName};
    root ${root};
    index index.html;
    
`;

  // Add locations
  for (const location of locations) {
    serverBlock += `    location ${location.path} {
${location.config.split('\n').map(line => `        ${line}`).join('\n')}
    }
    
`;
  }

  serverBlock += '}\n';
  return serverBlock;
}

// Export functions for potential programmatic use
module.exports = {
  generateServerBlock
};