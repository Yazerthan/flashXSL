const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// ── Répertoires de travail ────────────────────────────────────────────────────
const WORK_DIR = path.join(__dirname, 'workdir');
const SAXON_JAR = path.join(__dirname, 'saxon', 'saxon-he-12.9.jar');
const PRESETS_DIR = path.join(__dirname, 'presets');

if (!fs.existsSync(WORK_DIR)) fs.mkdirSync(WORK_DIR, { recursive: true });
if (!fs.existsSync(PRESETS_DIR)) fs.mkdirSync(PRESETS_DIR, { recursive: true });

// ── Multer : stockage des fichiers uploadés ────────────────────────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const sessionDir = path.join(WORK_DIR, req.sessionId || 'default');
    if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir, { recursive: true });
    cb(null, sessionDir);
  },
  filename: (req, file, cb) => {
    // Conserver le nom d'origine (important pour les imports relatifs dans les XSL)
    cb(null, file.originalname);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 } // 50 Mo
});

// Middleware pour créer un sessionId unique par requête
app.use((req, res, next) => {
  req.sessionId = req.headers['x-session-id'] || uuidv4();
  next();
});

// ── Vérification Java ─────────────────────────────────────────────────────────
app.get('/api/check', (req, res) => {
  exec('java -version', (err, stdout, stderr) => {
    const javaOutput = err ? (stderr || 'Java non trouvé') : (stderr || stdout);
    const saxonExists = fs.existsSync(SAXON_JAR);
    res.json({
      java: !err,
      javaVersion: javaOutput.split('\n')[0],
      saxon: saxonExists,
      saxonPath: SAXON_JAR
    });
  });
});

// ── Upload du fichier source (HTML/XML) ───────────────────────────────────────
app.post('/api/upload/source', (req, res, next) => {
  req.sessionId = req.headers['x-session-id'] || uuidv4();
  next();
}, upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Aucun fichier reçu' });

  const content = fs.readFileSync(req.file.path, 'utf-8');
  res.json({
    name: req.file.originalname,
    path: req.file.path,
    content,
    sessionId: req.sessionId
  });
});

// ── Upload de fichiers XSL ────────────────────────────────────────────────────
app.post('/api/upload/xsl', (req, res, next) => {
  req.sessionId = req.headers['x-session-id'] || uuidv4();
  next();
}, upload.array('files'), (req, res) => {
  if (!req.files || req.files.length === 0)
    return res.status(400).json({ error: 'Aucun fichier XSL reçu' });

  const files = req.files.map(f => ({
    id: uuidv4(),
    name: f.originalname,
    path: f.path,
    sessionId: req.sessionId
  }));

  res.json({ files, sessionId: req.sessionId });
});

// ── Exécuter le pipeline de transformations ───────────────────────────────────
app.post('/api/transform', async (req, res) => {
  const { sessionId, sourcePath, xslFiles } = req.body;
  // xslFiles : [{ name, path }] dans l'ordre souhaité

  if (!sourcePath || !xslFiles || xslFiles.length === 0) {
    return res.status(400).json({ error: 'Paramètres manquants' });
  }

  if (!fs.existsSync(SAXON_JAR)) {
    return res.status(500).json({
      error: `Saxon JAR introuvable : ${SAXON_JAR}. Placez saxon-he-12.9.jar dans server/saxon/`
    });
  }

  const sessionDir = path.join(WORK_DIR, sessionId || 'default');
  if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir, { recursive: true });

  let currentInput = sourcePath;
  const steps = [];

  try {
    for (let i = 0; i < xslFiles.length; i++) {
      const xsl = xslFiles[i];
      const outputFile = path.join(sessionDir, `step_${i + 1}_output.xml`);

      await runSaxon(currentInput, xsl.path, outputFile);

      const outputContent = fs.readFileSync(outputFile, 'utf-8');
      steps.push({
        step: i + 1,
        xslName: xsl.name,
        outputPath: outputFile,
        outputPreview: outputContent.substring(0, 500),
        fullOutput: outputContent // Contenu complet pour le plein écran
      });

      currentInput = outputFile;
    }

    const finalContent = fs.readFileSync(currentInput, 'utf-8');

    res.json({
      success: true,
      steps,
      result: finalContent,
      resultPath: currentInput
    });
  } catch (err) {
    res.status(500).json({ error: err.message, details: err.stderr });
  }
});

// ── Télécharger le résultat ───────────────────────────────────────────────────
app.get('/api/download', (req, res) => {
  const { filePath, filename } = req.query;
  if (!filePath || !fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'Fichier introuvable' });
  }
  res.download(filePath, filename || 'result.xml');
});

// ── Nettoyer la session ───────────────────────────────────────────────────────
app.delete('/api/session/:id', (req, res) => {
  const sessionDir = path.join(WORK_DIR, req.params.id);
  if (fs.existsSync(sessionDir)) {
    fs.rmSync(sessionDir, { recursive: true, force: true });
  }
  res.json({ success: true });
});

// ── Charger le preset de nettoyage ──────────────────────────────────────────
app.get('/api/presets/nettoyage', (req, res) => {
  const sessionId = req.headers['x-session-id'] || uuidv4();
  const sessionDir = path.join(WORK_DIR, sessionId);
  const presetSource = path.join(PRESETS_DIR, 'nettoyage.xsl');
  const presetDest = path.join(sessionDir, 'nettoyage.xsl');

  if (!fs.existsSync(presetSource)) {
    return res.status(404).json({ error: 'Preset introuvable' });
  }

  if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir, { recursive: true });

  // Copier le preset dans le dossier de session pour qu'il soit utilisable
  fs.copyFileSync(presetSource, presetDest);

  res.json({
    id: uuidv4(),
    name: 'nettoyage.xsl',
    path: presetDest,
    sessionId: sessionId
  });
});

// ── Helper : exécuter Saxon ───────────────────────────────────────────────────
function runSaxon(sourceFile, xslFile, outputFile) {
  return new Promise((resolve, reject) => {
    // Normaliser les chemins pour Java
    const cmd = `java -jar "${SAXON_JAR}" -s:"${sourceFile}" -xsl:"${xslFile}" -o:"${outputFile}"`;

    exec(cmd, { timeout: 60000 }, (err, stdout, stderr) => {
      if (err) {
        const errorObj = new Error(stderr || err.message || 'Erreur Saxon inconnue');
        errorObj.stderr = stderr;
        return reject(errorObj);
      }
      resolve({ stdout, stderr });
    });
  });
}

// ── Démarrage ────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🔧 XSL Pipeline Server démarré sur http://localhost:${PORT}`);
  console.log(`📁 Répertoire de travail : ${WORK_DIR}`);
  console.log(`⚡ Saxon JAR : ${SAXON_JAR}`);
  console.log(`   → Placez saxon-he-12.9.jar dans server/saxon/ si absent\n`);
});
