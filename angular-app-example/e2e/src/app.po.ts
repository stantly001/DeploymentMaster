import { browser, by, element } from 'protractor';

export class AppPage {
  async navigateTo(): Promise<unknown> {
    return browser.get(browser.baseUrl);
  }

  async getTitleText(): Promise<string> {
    return element(by.css('app-root h1')).getText();
  }
  
  getAboutLink() {
    return element(by.cssContainingText('a', 'About'));
  }
  
  getContactLink() {
    return element(by.cssContainingText('a', 'Contact'));
  }
}