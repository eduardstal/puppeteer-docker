# Use a newer Node.js version based on Debian Buster or Bullseye
FROM node:20

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Install comprehensive system components for realistic fingerprinting
RUN apt-get update && \
    apt-get install -yq \
    # Core Chrome dependencies
    net-tools libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
    libexpat1 libfontconfig1 libgcc-s1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
    libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
    libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
    ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils \
    # X11 and VNC infrastructure
    xvfb x11vnc x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-scalable dbus-x11 x11-apps \
    nginx \
    # Comprehensive font packages for realistic fingerprinting
    fonts-dejavu-core fonts-freefont-ttf fonts-liberation fonts-liberation2 \
    fonts-noto-core fonts-noto-ui-core fonts-noto-color-emoji fonts-noto-cjk \
    fonts-opensymbol fonts-symbola \
    fonts-droid-fallback fonts-arphic-ukai fonts-arphic-uming \
    fonts-ipafont-gothic fonts-ipafont-mincho fonts-unfonts-core \
    # Audio system (for realistic media capabilities)
    pulseaudio pulseaudio-utils alsa-utils libasound2-plugins \
    libpulse0 \
    # Graphics and WebGL support
    mesa-utils libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa \
    libglu1-mesa libxcomposite1 libxdamage1 libxrandr2 \
    # Media codecs (H.264, WebM, etc.)
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-pulseaudio gstreamer1.0-tools libavcodec59 \
    # System utilities that real systems have
    curl wget gnupg2 software-properties-common apt-transport-https \
    # Locale support for geographic consistency
    locales locales-all \
    # Additional system libraries for completeness
    libgtk2.0-0 libxss1 libappindicator3-1 \
    libdbusmenu-glib4 libdbusmenu-gtk3-4 \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium browser with additional font support (ARM64 compatible)
RUN apt-get update && apt-get install -y \
    chromium chromium-driver \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Configure system locales for realistic geographic fingerprinting
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Set up realistic system environment variables
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    TZ=America/New_York

# Configure audio system for realistic media capabilities
RUN echo "autospawn = yes" >> /etc/pulse/client.conf && \
    echo "enable-shm = yes" >> /etc/pulse/client.conf

# Create realistic user structure (but still run as root for Chrome compatibility)
RUN groupadd -g 1001 browser && \
    useradd -u 1001 -g browser -G audio,video,pulse-access browser && \
    mkdir -p /home/browser && \
    chown browser:browser /home/browser

# Use dumb-init to kill zombie processes (install from package manager for correct architecture)
RUN apt-get update && apt-get install -y dumb-init --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["dumb-init", "--"]

ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium"

# Puppeteer is packaged with Chromium, but we can skip the download since we are using system chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN mkdir ~/.vnc

# Set password on VNC server
RUN mkdir -p ~/.vnc && x11vnc -storepasswd password ~/.vnc/passwd

# Expose default port for VNC server
EXPOSE 5900
EXPOSE 9222

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

ARG NODE_ENV

ENV NODE_ENV=$NODE_ENV

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Start Nginx and the application
RUN chmod +x ./container_start.sh

EXPOSE 8000

CMD /bin/sh ./container_start.sh