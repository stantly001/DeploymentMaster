import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <header class="app-header">
      <div class="container">
        <h1>Angular Application</h1>
        <nav>
          <ul>
            <li><a routerLink="/" routerLinkActive="active" [routerLinkActiveOptions]="{exact: true}">Home</a></li>
            <li><a routerLink="/about" routerLinkActive="active">About</a></li>
            <li><a routerLink="/contact" routerLinkActive="active">Contact</a></li>
          </ul>
        </nav>
      </div>
    </header>

    <main class="container">
      <router-outlet></router-outlet>
    </main>

    <footer>
      <div class="container">
        <p>&copy; 2025 Angular Application Example. All rights reserved.</p>
      </div>
    </footer>
  `,
  styles: [`
    .app-header {
      background-color: #3f51b5;
      color: white;
      padding: 1rem 0;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 1rem;
    }
    
    nav ul {
      display: flex;
      list-style: none;
      padding: 0;
      margin: 1rem 0 0;
    }
    
    nav li {
      margin-right: 1.5rem;
    }
    
    nav a {
      color: white;
      text-decoration: none;
      font-weight: 500;
      padding: 0.5rem 0;
      border-bottom: 2px solid transparent;
      transition: border-color 0.3s;
    }
    
    nav a.active, nav a:hover {
      border-color: white;
    }
    
    main {
      min-height: calc(100vh - 160px);
      padding: 2rem 0;
    }
    
    footer {
      background-color: #f5f5f5;
      padding: 1.5rem 0;
      text-align: center;
      color: #666;
    }
  `]
})
export class AppComponent {
  title = 'angular-app-example';
}