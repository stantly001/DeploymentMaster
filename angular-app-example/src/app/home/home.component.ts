import { Component } from '@angular/core';

@Component({
  selector: 'app-home',
  template: `
    <div class="home-container">
      <div class="hero-section">
        <h1>Welcome to Angular Application</h1>
        <p class="lead">A demonstration of Angular deployment with Nginx</p>
        <div class="cta-buttons">
          <button class="btn primary" routerLink="/about">Learn More</button>
          <button class="btn secondary" routerLink="/contact">Contact Us</button>
        </div>
      </div>

      <div class="features-section">
        <h2>Features</h2>
        <div class="features-grid">
          <div class="feature-card">
            <div class="icon">🚀</div>
            <h3>Fast Performance</h3>
            <p>Optimized for speed with server-side caching and gzip compression</p>
          </div>
          <div class="feature-card">
            <div class="icon">🛡️</div>
            <h3>Secure Deployment</h3>
            <p>Configured with modern security headers and HTTPS support</p>
          </div>
          <div class="feature-card">
            <div class="icon">📱</div>
            <h3>Responsive Design</h3>
            <p>Works seamlessly across desktop, tablet, and mobile devices</p>
          </div>
          <div class="feature-card">
            <div class="icon">⚙️</div>
            <h3>Easy Configuration</h3>
            <p>Simple deployment process with customizable Nginx settings</p>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .home-container {
      padding: 1rem 0;
    }
    
    .hero-section {
      text-align: center;
      padding: 3rem 1rem;
      background: linear-gradient(135deg, #7e57c2, #3f51b5);
      color: white;
      border-radius: 8px;
      margin-bottom: 3rem;
    }
    
    h1 {
      font-size: 2.5rem;
      margin-bottom: 1rem;
    }
    
    .lead {
      font-size: 1.25rem;
      margin-bottom: 2rem;
      max-width: 600px;
      margin-left: auto;
      margin-right: auto;
    }
    
    .cta-buttons {
      display: flex;
      justify-content: center;
      gap: 1rem;
    }
    
    .btn {
      padding: 0.75rem 1.5rem;
      border-radius: 4px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.3s;
      border: none;
    }
    
    .primary {
      background-color: white;
      color: #3f51b5;
    }
    
    .primary:hover {
      background-color: #f5f5f5;
      transform: translateY(-2px);
    }
    
    .secondary {
      background-color: rgba(255, 255, 255, 0.2);
      color: white;
      border: 1px solid white;
    }
    
    .secondary:hover {
      background-color: rgba(255, 255, 255, 0.3);
      transform: translateY(-2px);
    }
    
    .features-section {
      padding: 2rem 0;
    }
    
    .features-section h2 {
      text-align: center;
      margin-bottom: 2rem;
      color: #333;
    }
    
    .features-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 2rem;
    }
    
    .feature-card {
      padding: 1.5rem;
      border-radius: 8px;
      background-color: #fff;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      transition: transform 0.3s, box-shadow 0.3s;
    }
    
    .feature-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
    }
    
    .icon {
      font-size: 2.5rem;
      margin-bottom: 1rem;
    }
    
    .feature-card h3 {
      margin-bottom: 0.75rem;
      color: #3f51b5;
    }
    
    .feature-card p {
      color: #666;
      line-height: 1.6;
    }
    
    @media (max-width: 768px) {
      .hero-section {
        padding: 2rem 1rem;
      }
      
      h1 {
        font-size: 2rem;
      }
      
      .lead {
        font-size: 1.1rem;
      }
      
      .cta-buttons {
        flex-direction: column;
        gap: 0.75rem;
      }
      
      .features-grid {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class HomeComponent {
}