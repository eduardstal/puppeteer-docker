const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const { createCursor } = require('ghost-cursor');
const UserAgent = require('user-agents');

// Add stealth plugin
puppeteer.use(StealthPlugin());

// Advanced Chrome hardening arguments
const getHardenedArgs = () => [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-blink-features=AutomationControlled',
    '--disable-features=VizDisplayCompositor',
    '--disable-ipc-flooding-protection',
    '--disable-background-timer-throttling',
    '--disable-renderer-backgrounding',
    '--start-maximized',
    '--disable-infobars',
    '--remote-debugging-port=9222',
    '--remote-debugging-address=0.0.0.0',
    '--disable-dev-shm-usage'
];

// Human-like delay function
const humanDelay = (min = 1000, max = 3000) => {
    return new Promise(resolve => {
        const delay = Math.random() * (max - min) + min;
        setTimeout(resolve, delay);
    });
};

(async () => {
    try {
        console.log('Launching hardened browser with advanced anti-detection...');
        
        const userAgent = new UserAgent();
        
        const browser = await puppeteer.launch({
            headless: false,
            defaultViewport: { width: 1920, height: 1080 },
            executablePath: '/usr/bin/chromium',
            args: getHardenedArgs(),
            ignoreDefaultArgs: ['--enable-automation'],
            env: {
                ...process.env,
                REBROWSER_PATCHES_RUNTIME_FIX_MODE: 'alwaysIsolated'
            }
        });

        const page = await browser.newPage();
        
        // Set realistic user agent and headers
        await page.setUserAgent(userAgent.toString());
        await page.setExtraHTTPHeaders({
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br'
        });

        // Advanced fingerprinting evasion (per-page)
        await page.evaluateOnNewDocument(() => {
            Object.defineProperty(navigator, 'webdriver', { get: () => false });
            Object.defineProperty(window, 'chrome', {
                get: () => ({ runtime: { onConnect: null, onMessage: null } })
            });
            
            // Canvas noise injection
            const getImageData = HTMLCanvasElement.prototype.getContext('2d').__proto__.getImageData;
            HTMLCanvasElement.prototype.getContext('2d').__proto__.getImageData = function(...args) {
                const imageData = getImageData.apply(this, args);
                for (let i = 0; i < imageData.data.length; i += 4) {
                    imageData.data[i] += Math.floor(Math.random() * 10) - 5;
                }
                return imageData;
            };
        });

        // Initialize human-like cursor
        const cursor = createCursor(page);

        await humanDelay(500, 1500);
        await page.goto('https://google.com', { waitUntil: 'networkidle2' });
        
        await humanDelay(2000, 4000);
        await cursor.move('input[name="q"]');
        
        console.log('Successfully loaded Google.com with anti-detection (per-page only)');
        console.log('Note: Manual VNC tabs will not have anti-detection features');

        // Keep browser alive
        process.on('SIGINT', async () => {
            await browser.close();
            process.exit(0);
        });

    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
})();