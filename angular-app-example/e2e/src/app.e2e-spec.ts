import { browser, logging } from 'protractor';
import { AppPage } from './app.po';

describe('workspace-project App', () => {
  let page: AppPage;

  beforeEach(() => {
    page = new AppPage();
  });

  it('should display welcome message', async () => {
    await page.navigateTo();
    expect(await page.getTitleText()).toEqual('Angular App Example');
  });

  it('should navigate to about page', async () => {
    await page.navigateTo();
    await page.getAboutLink().click();
    expect(await browser.getCurrentUrl()).toContain('/about');
  });

  it('should navigate to contact page', async () => {
    await page.navigateTo();
    await page.getContactLink().click();
    expect(await browser.getCurrentUrl()).toContain('/contact');
  });

  afterEach(async () => {
    // Assert that there are no errors emitted from the browser
    const logs = await browser.manage().logs().get(logging.Type.BROWSER);
    expect(logs).not.toContain(jasmine.objectContaining({
      level: logging.Level.SEVERE,
    } as logging.Entry));
  });
});