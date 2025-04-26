import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="app-container">
      <header class="header">
        <div class="logo">
          <h1>Angular App</h1>
        </div>
        <nav>
          <ul>
            <li><a routerLink="/" routerLinkActive="active" [routerLinkActiveOptions]="{exact: true}">Home</a></li>
            <li><a routerLink="/about" routerLinkActive="active">About</a></li>
            <li><a routerLink="/contact" routerLinkActive="active">Contact</a></li>
          </ul>
        </nav>
      </header>
      <main class="content">
        <router-outlet></router-outlet>
      </main>
      <footer class="footer">
        <p>&copy; 2025 Angular App Example</p>
      </footer>
    </div>
  `,
  styles: [`
    .app-container {
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    
    .header {
      background-color: #3f51b5;
      color: white;
      padding: 1rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .logo h1 {
      margin: 0;
      font-size: 1.5rem;
    }
    
    nav ul {
      list-style-type: none;
      display: flex;
      margin: 0;
      padding: 0;
    }
    
    nav li {
      margin-left: 1rem;
    }
    
    nav a {
      color: white;
      text-decoration: none;
      padding: 0.5rem;
    }
    
    nav a.active {
      border-bottom: 2px solid white;
    }
    
    .content {
      flex: 1;
      padding: 2rem;
    }
    
    .footer {
      background-color: #f5f5f5;
      padding: 1rem;
      text-align: center;
    }
  `]
})
export class AppComponent {
  title = 'angular-app-example';
}