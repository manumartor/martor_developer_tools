const puppeteer = require('puppeteer');

function escapeSelector(selector){
  return JSON.stringify(selector);
}

(async () => {
    let initUrl = "http://www.google.es";

    let identation = 0;
    const output = [];
    const addLineToPuppeteerScript = (line) => {
        const data = '   '.repeat(identation) + line;
        output.push(data);
    };

    // setup initial output script
    addLineToPuppeteerScript(`const puppeteer = require('puppeteer');
//const { expect } = require('chai');

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    await page.goto('${initUrl}');`);
    identation ++;

    // Inicia el navegador de grabación
    const browser = await puppeteer.launch({
        headless: false, // Muestra el navegador al usuario
        //args: ['--start-maximized'] // Maximiza la ventana del navegador
    });
    const page = await browser.newPage();

    // Navega a la página que quieres que el usuario interactúe
    await page.goto(initUrl);

    // Escuchar y registrar eventos de clic
    page.on('click', async event => {
        console.log('click', event);
    });

    // Escuchar y registrar eventos de entrada de teclado
    page.on('keydown', async event => {
        console.log('keydown', event);
    });

    // Escuchar y registrar eventos de consola
    page.on('console', async event => {
        console.log(`ConsoleMessage type: ${event.type()}, text: ${event.type}, location: ${JSON.stringify(event.location())}, stackTrace: ${JSON.stringify(event.stackTrace())}, arg: ${event.args()}}`);
    });

    // Add expectations for mainframe navigations
    /*page.on('framenavigated', async frame => {
        if (frame.parentFrame()) return;
        addLineToPuppeteerScript(`expect(page.url()).resolves.toBe(${escapeSelector(frame.url())});`);
    });*/


    //Define close event function
    async function close() {    
        addLineToPuppeteerScript(`
    await browser.close();
})();`);
        identation--;
        await browser.close();

        console.log("\n\n", output.join("\n"));
    }
    
    // Finish the puppeteer script when the page is closed
    page.on('close', close);

    // Or if the user stops the script
    process.on('SIGINT', async () => {
        await close();
        process.exit();
    });
})();