const puppeteer = require('puppeteer');
const { record } = require('puppeteer-recorder');

(async () => {
  const browser = await puppeteer.launch({
    headless: false, // Muestra el navegador al usuario
    args: ['--start-maximized'] // Maximiza la ventana del navegador
});
  const page = await browser.newPage();
  await page.goto('https://www.google.com');

  await record({
    browser, // Optional: a puppeteer Browser instance,
    page, // Optional: a puppeteer Page instance,
    output: 'output.webm',
    fps: 60,
    frames: 60 * 5, // 5 seconds at 60 fps
    prepare: function (browser, page) { /* executed before first capture */ },
    render: function (browser, page, frame) { /* executed before each capture */ }
  });

  //Define close event function
  async function close() {    
    await browser.close();
  }

  // Finish the puppeteer script when the page is closed
  page.on('close', close);

  // Or if the user stops the script
  process.on('SIGINT', async () => {
      await close();
      process.exit();
  });
})();