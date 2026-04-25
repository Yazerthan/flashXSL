# ── Dockerfile du backend (Node.js + Java pour Saxon) ──────────────
# Base : Eclipse Temurin JDK 21 avec Node.js installé
FROM eclipse-temurin:21-jdk-jammy

# Installer Node.js 20 LTS
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les dépendances d'abord (cache layer)
COPY package.json ./
RUN npm install --omit=dev

# Copier tout le code source (index.js, dossiers presets, etc.)
COPY . .

# Le JAR Saxon est monté via volume (voir docker-compose.yml)
# Le répertoire de travail sera aussi monté
RUN mkdir -p /app/saxon /app/workdir

EXPOSE 3001

CMD ["node", "index.js"]
