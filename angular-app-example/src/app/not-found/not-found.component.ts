import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-not-found',
  template: `
    <div class="not-found-container">
      <div class="not-found-content">
        <div class="error-code">404</div>
        <h1>Page Not Found</h1>
        <p>The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.</p>
        <button class="btn primary" (click)="navigateToHome()">Go to Homepage</button>
      </div>
    </div>
  `,
  styles: [`
    .not-found-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 80vh;
      padding: 2rem;
    }
    
    .not-found-content {
      text-align: center;
      max-width: 600px;
    }
    
    .error-code {
      font-size: 8rem;
      font-weight: 900;
      color: #3f51b5;
      line-height: 1;
      margin-bottom: 1rem;
      background: linear-gradient(135deg, #3f51b5 0%, #7e57c2 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      text-shadow: 0 5px 15px rgba(63, 81, 181, 0.2);
    }
    
    h1 {
      font-size: 2.5rem;
      margin-bottom: 1.5rem;
      color: #333;
    }
    
    p {
      font-size: 1.2rem;
      color: #666;
      margin-bottom: 2rem;
      line-height: 1.6;
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
      background-color: #3f51b5;
      color: white;
    }
    
    .primary:hover {
      background-color: #303f9f;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    
    @media (max-width: 768px) {
      .error-code {
        font-size: 6rem;
      }
      
      h1 {
        font-size: 2rem;
      }
      
      p {
        font-size: 1.1rem;
      }
    }
  `]
})
export class NotFoundComponent {
  constructor(private router: Router) {}
  
  navigateToHome() {
    this.router.navigate(['/']);
  }
}