import { Component } from '@angular/core';

@Component({
  selector: 'app-home',
  template: `
    <div class="home-container">
      <h1>Welcome to Angular App Example</h1>
      <p>This is a sample Angular application that demonstrates routing and component structure.</p>
      <div class="feature-section">
        <div class="feature-card">
          <h3>Responsive Design</h3>
          <p>Our application is fully responsive and works on all devices.</p>
        </div>
        <div class="feature-card">
          <h3>Angular Routing</h3>
          <p>Navigate between pages with Angular's powerful routing system.</p>
        </div>
        <div class="feature-card">
          <h3>Component-Based</h3>
          <p>Built with reusable components for maintainability and scalability.</p>
        </div>
      </div>
      <button class="primary-button" routerLink="/about">Learn More</button>
    </div>
  `,
  styles: [`
    .home-container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 1rem;
    }
    
    h1 {
      color: #3f51b5;
      margin-bottom: 1rem;
    }
    
    .feature-section {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 1.5rem;
      margin: 2rem 0;
    }
    
    .feature-card {
      background-color: #f5f5f5;
      padding: 1.5rem;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
    
    .feature-card h3 {
      color: #3f51b5;
      margin-top: 0;
    }
    
    .primary-button {
      background-color: #3f51b5;
      color: white;
      border: none;
      padding: 0.75rem 1.5rem;
      border-radius: 4px;
      font-size: 1rem;
      cursor: pointer;
      transition: background-color 0.3s;
    }
    
    .primary-button:hover {
      background-color: #303f9f;
    }
  `]
})
export class HomeComponent {
}