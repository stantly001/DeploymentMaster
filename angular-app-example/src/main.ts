import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

import { AppModule } from './app/app.module';
import { environment } from './environments/environment';

if (environment.production) {
  enableProdMode();
}

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));

function enableProdMode() {
  // Production mode is enabled through a call to Angular's enableProdMode function
  // We're simulating this function here as it would be imported from @angular/core
  console.log('Production mode enabled');
}