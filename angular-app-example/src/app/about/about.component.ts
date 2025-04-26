import { Component } from '@angular/core';

@Component({
  selector: 'app-about',
  template: `
    <div class="about-container">
      <h1>About This Angular Application</h1>
      <div class="about-content">
        <div class="about-text">
          <h2>Our Story</h2>
          <p>
            This is a sample Angular application created to demonstrate deployment with Nginx.
            The application showcases Angular's component-based architecture, routing capabilities,
            and how it can be effectively deployed to production using Nginx as a web server.
          </p>
          <p>
            Angular provides a robust framework for building modern web applications with features like:
          </p>
          <ul>
            <li>Component-based architecture</li>
            <li>Powerful routing system</li>
            <li>Dependency injection</li>
            <li>Reactive forms</li>
            <li>HTTP client for API communication</li>
          </ul>
        </div>
        <div class="about-image">
          <div class="image-placeholder">
            <span>Angular Logo</span>
          </div>
        </div>
      </div>
      <div class="team-section">
        <h2>Our Technology Stack</h2>
        <div class="technologies">
          <div class="tech-card">
            <h3>Angular</h3>
            <p>Frontend framework for building dynamic single-page applications</p>
          </div>
          <div class="tech-card">
            <h3>Nginx</h3>
            <p>High-performance web server and reverse proxy for serving Angular apps</p>
          </div>
          <div class="tech-card">
            <h3>TypeScript</h3>
            <p>Typed superset of JavaScript that compiles to plain JavaScript</p>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .about-container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 1rem;
    }
    
    h1 {
      color: #3f51b5;
      margin-bottom: 2rem;
    }
    
    h2 {
      color: #3f51b5;
      margin: 1.5rem 0 1rem;
    }
    
    .about-content {
      display: grid;
      grid-template-columns: 3fr 2fr;
      gap: 2rem;
      margin-bottom: 2rem;
    }
    
    @media (max-width: 768px) {
      .about-content {
        grid-template-columns: 1fr;
      }
    }
    
    .about-text ul {
      margin-left: 1.5rem;
      margin-top: 1rem;
    }
    
    .about-text li {
      margin-bottom: 0.5rem;
    }
    
    .image-placeholder {
      background-color: #f5f5f5;
      height: 300px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 8px;
      font-size: 1.5rem;
      color: #3f51b5;
    }
    
    .technologies {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1.5rem;
      margin-top: 1.5rem;
    }
    
    .tech-card {
      background-color: #f5f5f5;
      padding: 1.5rem;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
    
    .tech-card h3 {
      color: #3f51b5;
      margin-top: 0;
      margin-bottom: 0.5rem;
    }
  `]
})
export class AboutComponent {
}