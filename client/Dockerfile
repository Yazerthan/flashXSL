# ── Dockerfile du client (build React → nginx) ──────────────────────

# Étape 1 : Build React
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
RUN npm run build

# Étape 2 : Servir avec nginx
FROM nginx:alpine

# Copier le build React
COPY --from=builder /app/dist /usr/share/nginx/html

# Copier la config nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
