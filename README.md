# XSL Pipeline App – SaxonHE 12.9J

Application React de transformation XML/HTML via des pipelines XSL.

---

## 🐳 Démarrage avec Docker (recommandé)

### Prérequis
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installé et démarré

### 1. Placer le JAR Saxon
```
server/
└── saxon/
    └── saxon-he-12.9.jar   ← télécharger depuis sourceforge
```
> Téléchargement : https://sourceforge.net/projects/saxon/files/Saxon-HE/12/Java/

### 2. Lancer
```bash
docker compose up --build
```

L'application est disponible sur **http://localhost** (port 80, URL fixe).

### 3. Arrêter
```bash
docker compose down
```

### Rebuild après modification du code
```bash
docker compose up --build
```

---

## Prérequis

- **Node.js** ≥ 18
- **Java** ≥ 11 (dans le PATH)
- **SaxonHE 12.9J** : téléchargez `saxon-he-12.9.jar` depuis https://sourceforge.net/projects/saxon/files/Saxon-HE/12/Java/ et placez-le dans `server/saxon/`

## Installation

```bash
# Backend
cd server
npm install

# Frontend
cd ../client
npm install
```

## Démarrage

Ouvrez **deux terminaux** :

```bash
# Terminal 1 – Backend (port 3001)
cd server
node index.js

# Terminal 2 – Frontend (port 5173)
cd client
npm run dev
```

Puis ouvrez http://localhost:5173

## Utilisation

1. **Glissez** votre fichier XML/HTML source dans la zone de gauche
2. **Glissez** vos fichiers XSL dans la zone pipeline et **réordonnez-les** par drag & drop
3. Cliquez **▶ Lancer le pipeline**
4. Visualisez le résultat en code source, rendu HTML brut ou **rendu stylé** avec votre CSS personnalisé
5. Téléchargez en **XML brut** ou **HTML avec styles**

## Structure

```
applicationXSL/
├── client/          # React (Vite)
│   └── src/
│       ├── components/
│       │   ├── SourceDropZone.jsx
│       │   ├── XslPipeline.jsx
│       │   └── ResultPanel.jsx
│       ├── hooks/
│       │   └── useToast.jsx
│       ├── App.jsx
│       └── index.css
└── server/          # Node.js + Express
    ├── index.js
    ├── saxon/
    │   └── saxon-he-12.9.jar   ← à placer ici
    └── workdir/                ← fichiers temporaires
```
