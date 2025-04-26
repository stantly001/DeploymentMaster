import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-not-found',
  template: `
    <div class="not-found-container">
      <h1>404</h1>
      <h2>Page Not Found</h2>
      <p>The page you are looking for does not exist or has been moved.</p>
      <button class="home-button" (click)="navigateToHome()">Go to Homepage</button>
    </div>
  `,
  styles: [`
    .not-found-container {
      max-width: 800px;
      margin: 2rem auto;
      padding: 3rem 1rem;
      text-align: center;
    }
    
    h1 {
      font-size: 6rem;
      margin: 0;
      color: #3f51b5;
    }
    
    h2 {
      font-size: 2rem;
      color: #333;
      margin-top: 0;
      margin-bottom: 1.5rem;
    }
    
    p {
      font-size: 1.2rem;
      color: #666;
      margin-bottom: 2rem;
    }
    
    .home-button {
      background-color: #3f51b5;
      color: white;
      border: none;
      padding: 0.75rem 1.5rem;
      border-radius: 4px;
      font-size: 1rem;
      cursor: pointer;
      transition: background-color 0.3s;
    }
    
    .home-button:hover {
      background-color: #303f9f;
    }
  `]
})
export class NotFoundComponent {
  constructor(private router: Router) {}
  
  navigateToHome() {
    this.router.navigate(['/']);
  }
}