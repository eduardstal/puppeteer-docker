# Headful Puppeteer in Docker

Designed specifically for n8n users.  

Run Puppeteer with a visible Chrome browser in a Docker container, accessible via VNC.

Useful for precise scripting and debugging.  Allows you to log into websites via the remote viewer and keep persistent sessions as long as you don't close the browser in the container.  Use page.close() instead of browser.close().  You will need to restart the container if you pass a browser.close() command.  

n8n json nodes included, just update the IP addresses and you are good to go.  The script will automatically pull the remote debug port of the chrome instance.  

compatible with any VNC viewer.  

Intended to be used with: https://github.com/conor-is-my-name/n8n-autoscaling

If not using the n8n build linked above, you will need to install and enable puppeteer or playwright in your existing n8n install.  

## Features

- Chrome browser running in headful mode inside Docker
- VNC access to view/interact with the browser
- Chrome remote debugging enabled
- Nginx reverse proxy for debugging interface
- Preconfigured with useful Chrome flags

## Requirements

- Docker
- Docker Compose
- VNC client (for browser interaction)

## Quick Start

1. Build and start the container:
```bash
docker-compose up -d
```

2. Connect to the browser via VNC:
- Host: `localhost`
- Port: `5900`
- Password: `password`

3. Access Chrome remote debugging:
- Open `http://localhost:9223` in your browser

## Configuration

### Environment Variables

- `NODE_ENV`: Set to "production" or "development" (default)

### Ports

- `5900`: VNC server
- `9223`: Nginx proxy for Chrome debugging
- `9222`: Direct Chrome debugging port (inside container)

### Networks

The container connects to:
- Default bridge network
- External "shark" network (must exist)

## How It Works

1. The container starts Xvfb (virtual framebuffer)
2. x11vnc provides VNC access to the virtual display
3. Puppeteer launches Chrome with remote debugging enabled
4. Nginx proxies the debugging interface

## Customizing the Browser

Edit `index.js` to change:
- The starting URL (currently Google)
- Chrome launch options
- Puppeteer automation scripts

## Troubleshooting

- If VNC connection fails, check container logs:
```bash
docker-compose logs
```

- To access a shell in the container:
```bash
docker-compose exec headfulcontainer bash
```

## License

MIT