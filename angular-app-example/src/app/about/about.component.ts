import { Component } from '@angular/core';

@Component({
  selector: 'app-about',
  template: `
    <div class="about-container">
      <h1>About This Project</h1>
      
      <div class="content-section">
        <h2>Angular Deployment with Nginx</h2>
        <p>
          This example project demonstrates how to deploy an Angular application using Nginx as a web server.
          Nginx is a powerful, efficient, and widely-used web server that works extremely well with single-page 
          applications like those built with Angular.
        </p>
        
        <h3>Why Nginx?</h3>
        <ul class="feature-list">
          <li>
            <strong>High Performance:</strong> Nginx is designed to handle many concurrent connections with low memory usage
          </li>
          <li>
            <strong>Static File Serving:</strong> Extremely efficient at serving static assets (HTML, CSS, JavaScript)
          </li>
          <li>
            <strong>Load Balancing:</strong> Can distribute traffic across multiple servers
          </li>
          <li>
            <strong>Reverse Proxy:</strong> Can proxy requests to backend services
          </li>
          <li>
            <strong>Caching:</strong> Implements efficient caching to improve performance
          </li>
          <li>
            <strong>SSL/TLS Termination:</strong> Handles HTTPS connections securely
          </li>
        </ul>
      </div>
      
      <div class="content-section">
        <h2>Key Deployment Features</h2>
        
        <div class="deployment-features">
          <div class="feature">
            <h3>HTML5 Routing Support</h3>
            <p>
              Configured to work with Angular's HTML5 routing by redirecting all routes to index.html
              when no matching file is found, enabling client-side routing.
            </p>
          </div>
          
          <div class="feature">
            <h3>Compression & Performance</h3>
            <p>
              Gzip compression is enabled for text-based assets, dramatically reducing transfer sizes
              and improving load times for users. Static asset caching is also configured for optimal performance.
            </p>
          </div>
          
          <div class="feature">
            <h3>Security Headers</h3>
            <p>
              Security is enhanced with HTTP headers like Content-Security-Policy, X-XSS-Protection,
              and X-Frame-Options to protect against common web vulnerabilities.
            </p>
          </div>
          
          <div class="feature">
            <h3>SSL/TLS Ready</h3>
            <p>
              The configuration includes commented sections for SSL/TLS setup, allowing for easy HTTPS 
              implementation when certificates are available.
            </p>
          </div>
        </div>
      </div>
      
      <div class="cta-section">
        <h2>Ready to Deploy Your Own Angular App?</h2>
        <p>Check out the deployment script and Dockerfile included in this example.</p>
        <button class="btn primary" routerLink="/contact">Contact Us</button>
      </div>
    </div>
  `,
  styles: [`
    .about-container {
      max-width: 100%;
      padding: 0 1rem;
    }
    
    h1 {
      margin-bottom: 2rem;
      color: #3f51b5;
      font-size: 2.5rem;
      font-weight: 700;
      border-bottom: 2px solid #f0f0f0;
      padding-bottom: 0.5rem;
    }
    
    .content-section {
      margin-bottom: 3rem;
    }
    
    h2 {
      color: #333;
      font-size: 1.8rem;
      margin-bottom: 1.5rem;
    }
    
    h3 {
      color: #3f51b5;
      font-size: 1.4rem;
      margin: 1.5rem 0 1rem;
    }
    
    p {
      line-height: 1.7;
      margin-bottom: 1.5rem;
      color: #444;
    }
    
    .feature-list {
      padding-left: 1.5rem;
      margin-bottom: 2rem;
    }
    
    .feature-list li {
      margin-bottom: 1rem;
      line-height: 1.6;
    }
    
    .deployment-features {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 2rem;
      margin-top: 1.5rem;
    }
    
    .feature {
      background-color: #f9f9f9;
      padding: 1.5rem;
      border-radius: 8px;
      border-left: 4px solid #3f51b5;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
      transition: transform 0.3s, box-shadow 0.3s;
    }
    
    .feature:hover {
      transform: translateY(-5px);
      box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
    }
    
    .feature h3 {
      margin-top: 0;
      font-size: 1.3rem;
    }
    
    .feature p {
      margin-bottom: 0;
      font-size: 0.95rem;
    }
    
    .cta-section {
      background: linear-gradient(135deg, #3f51b5, #7e57c2);
      color: white;
      padding: 2.5rem;
      border-radius: 8px;
      text-align: center;
      margin-bottom: 2rem;
    }
    
    .cta-section h2 {
      color: white;
      margin-bottom: 1rem;
    }
    
    .cta-section p {
      color: rgba(255, 255, 255, 0.9);
      margin-bottom: 1.5rem;
      font-size: 1.1rem;
    }
    
    .btn {
      padding: 0.75rem 1.5rem;
      border-radius: 4px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.3s;
      border: none;
      display: inline-block;
    }
    
    .primary {
      background-color: white;
      color: #3f51b5;
    }
    
    .primary:hover {
      background-color: #f5f5f5;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    
    @media (max-width: 768px) {
      .deployment-features {
        grid-template-columns: 1fr;
      }
      
      h1 {
        font-size: 2rem;
      }
      
      .cta-section {
        padding: 1.5rem;
      }
    }
  `]
})
export class AboutComponent {
}