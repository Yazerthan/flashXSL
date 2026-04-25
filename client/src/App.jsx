import { useState, useEffect, useCallback } from 'react';
import { ToastProvider, useToast } from './hooks/useToast';
import SourceDropZone from './components/SourceDropZone';
import XslPipeline from './components/XslPipeline';
import ResultPanel from './components/ResultPanel';
import { Play, Zap, Settings, AlertCircle, CheckCircle, Loader2, FileCode, Link, Info, Palette } from 'lucide-react';
import DEFAULT_RESULT_CSS from './assets/result-default.css?raw';

function AppInner() {
  const { addToast } = useToast();

  // État global
  const [source, setSource] = useState(null);          // { name, path, content }
  const [pipeline, setPipeline] = useState([]);         // [{ id, name, path }]
  const [result, setResult] = useState(null);           // string XML/HTML
  const [steps, setSteps] = useState([]);
  const [resultPath, setResultPath] = useState(null);
  const [customCss, setCustomCss] = useState(DEFAULT_RESULT_CSS);
  const [isRunning, setIsRunning] = useState(false);
  const [progress, setProgress] = useState(0);
  const [systemStatus, setSystemStatus] = useState({ java: null, saxon: null });
  const [sourcePreviewOpen, setSourcePreviewOpen] = useState(false);

  // Vérification Java / Saxon au démarrage
  useEffect(() => {
    fetch('/api/check')
      .then(r => r.json())
      .then(d => setSystemStatus(d))
      .catch(() => setSystemStatus({ java: false, saxon: false }));
  }, []);

  // Pré-chargement du XSL de nettoyage si le pipeline est vide
  useEffect(() => {
    if (pipeline.length === 0) {
      const sessionId = localStorage.getItem('xsl-session-id');
      fetch('/api/presets/nettoyage', {
        headers: { 'x-session-id': sessionId || '' }
      })
        .then(r => r.json())
        .then(data => {
          if (data.path) {
            setPipeline([{ id: data.id, name: data.name, path: data.path }]);
          }
        })
        .catch(err => console.error('Erreur chargement preset:', err));
    }
  }, []); // Ne s'exécute qu'au montage initial

  const handleSourceLoaded = useCallback((data) => {
    setSource(data);
    setResult(null);
    setSteps([]);
  }, []);

  const runPipeline = useCallback(async () => {
    if (!source) {
      addToast('Chargez un fichier source avant de lancer', 'warn');
      return;
    }
    if (pipeline.length === 0) {
      addToast('Ajoutez au moins une feuille XSL au pipeline', 'warn');
      return;
    }

    setIsRunning(true);
    setProgress(10);

    try {
      const sessionId = localStorage.getItem('xsl-session-id') || 'default';
      setProgress(30);

      const res = await fetch('/api/transform', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          sessionId,
          sourcePath: source.path,
          xslFiles: pipeline.map(p => ({ name: p.name, path: p.path }))
        })
      });

      setProgress(80);
      const data = await res.json();

      if (!res.ok || !data.success) {
        throw new Error(data.error || 'Erreur de transformation');
      }

      setResult(data.result);
      setSteps(data.steps);
      setResultPath(data.resultPath);
      setProgress(100);
      addToast(`Pipeline exécuté (${data.steps.length} étape(s))`, 'success');

      setTimeout(() => setProgress(0), 800);
    } catch (err) {
      addToast(`Erreur : ${err.message}`, 'error');
      setProgress(0);
    } finally {
      setIsRunning(false);
    }
  }, [source, pipeline, addToast]);

  // Statut Java/Saxon
  const javaOk = systemStatus.java;
  const saxonOk = systemStatus.saxon;

  return (
    <div className="app-layout">
      {/* ── Header ──────────────────────────────────────────── */}
      <header className="app-header">
        <div className="logo">
          <div className="logo-icon"><Zap size={18} fill="currentColor" /></div>
          <div className="logo-text">
            DESK<span>Pipeline</span>
          </div>
        </div>

        <span style={{
          fontSize: '0.7rem',
          color: 'var(--text-muted)',
          marginLeft: 8,
          fontFamily: 'JetBrains Mono, monospace'
        }}>
          SaxonHE 12.9J
        </span>

        {/* Run button */}
        <button
          className="btn btn-primary"
          style={{ marginLeft: 20 }}
          onClick={runPipeline}
          disabled={isRunning || !source || pipeline.length === 0}
          id="btn-run-pipeline"
        >
          {isRunning ? (
            <><Loader2 size={14} className="spin" /> Transformation…</>
          ) : (
            <><Play size={14} /> Lancer le pipeline</>
          )}
        </button>

        {/* System status */}
        <div className="header-status">
          <span className={`status-dot ${javaOk === null ? '' : javaOk ? 'ok' : 'err'}`} />
          <span>Java</span>
          <span className={`status-dot ${saxonOk === null ? '' : saxonOk ? 'ok' : 'warn'}`} />
          <span>Saxon</span>
          {!saxonOk && saxonOk !== null && (
            <span style={{ color: 'var(--accent-warning)', fontSize: '0.68rem', maxWidth: 220 }}>
              → Placez saxon-he-12.9.jar dans <code style={{ background: 'rgba(255,255,255,0.06)', padding: '1px 4px', borderRadius: 3 }}>server/saxon/</code>
            </span>
          )}
        </div>
      </header>

      {/* ── Sidebar left : source + pipeline ───────────────── */}
      <aside className="app-sidebar-left">
        <div className="section-header">
          <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}><FileCode size={14} /> Fichier source</span>
        </div>
        <SourceDropZone onFileLoaded={handleSourceLoaded} />

        {/* Source preview toggle */}
        {source && (
          <div style={{ padding: '8px 16px', borderBottom: '1px solid var(--border)' }}>
            <button
              className="btn btn-secondary btn-sm w-full"
              onClick={() => setSourcePreviewOpen(v => !v)}
              style={{ justifyContent: 'center' }}
            >
              {sourcePreviewOpen ? '▲ Masquer l\'aperçu' : '▼ Aperçu source'}
            </button>
            {sourcePreviewOpen && (
              <div className="code-viewer" style={{ marginTop: 8 }}>
                <div className="code-viewer-content" style={{ maxHeight: 180, fontSize: '0.68rem' }}>
                  {source.content}
                </div>
              </div>
            )}
          </div>
        )}

        <div className="section-header" style={{ marginTop: 0 }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}><Link size={14} /> Pipeline XSL</span>
          <span style={{ fontSize: '0.65rem', color: 'var(--accent-primary)' }}>
            {pipeline.length} feuille{pipeline.length !== 1 ? 's' : ''}
          </span>
        </div>
        <XslPipeline pipeline={pipeline} setPipeline={setPipeline} />

        {/* Pipeline actions */}
        {pipeline.length > 0 && (
          <div style={{ padding: '12px 16px', borderTop: '1px solid var(--border)' }}>
            <button
              className="btn btn-danger btn-sm w-full"
              onClick={() => {
                setPipeline([]);
                addToast('Pipeline vidé', 'info');
              }}
              style={{ justifyContent: 'center' }}
            >
              Vider le pipeline
            </button>
          </div>
        )}
      </aside>

      {/* ── Main : résultat ────────────────────────────────── */}
      <main className="app-main" style={{ padding: 0 }}>
        {/* Progress bar */}
        {progress > 0 && (
          <div className="progress-bar" style={{ margin: 0, borderRadius: 0, height: 4 }}>
            <div className="progress-fill" style={{ width: `${progress}%` }} />
          </div>
        )}

        <ResultPanel
          source={source}
          result={result}
          steps={steps}
          resultPath={resultPath}
          customCss={customCss}
          onCssChange={setCustomCss}
        />
      </main>

      {/* ── Sidebar right : infos + CSS ─────────────────────── */}
      <aside className="app-sidebar-right">
        <div className="section-header">
          <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}><Info size={14} /> Informations</span>
        </div>

        <div style={{ padding: 16, borderBottom: '1px solid var(--border)' }}>
          {/* Pipeline summary */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <InfoRow label="Source" value={source ? source.name : '—'} />
            <InfoRow label="Étapes XSL" value={pipeline.length || '—'} />
            <InfoRow label="Résultat"
              value={result ? `${result.length.toLocaleString()} chars` : '—'}
              highlight={!!result}
            />
          </div>
        </div>

        {/* Pipeline order summary */}
        {pipeline.length > 0 && (
          <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--border)' }}>
            <p className="text-xs text-secondary" style={{ marginBottom: 8 }}>Ordre d'application :</p>
            {pipeline.map((p, i) => (
              <div key={p.id} style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                <span style={{
                  width: 16, height: 16, borderRadius: '50%',
                  background: 'var(--accent-primary)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: '0.55rem', fontWeight: 700, color: '#fff', flexShrink: 0
                }}>{i + 1}</span>
                <span className="text-xs font-mono" style={{ color: 'var(--text-secondary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {p.name}
                </span>
              </div>
            ))}
          </div>
        )}

        <div className="section-header">
          <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}><Palette size={14} /> Feuille de style</span>
        </div>

        <div className="style-editor" style={{ flex: 1 }}>
          <p className="text-xs text-secondary">
            CSS injecté dans l'onglet <strong style={{ color: 'var(--accent-primary)' }}>Rendu stylé</strong> pour la prévisualisation et le téléchargement HTML.
          </p>
          <textarea
            value={customCss}
            onChange={e => setCustomCss(e.target.value)}
            placeholder="body { }"
            spellCheck={false}
            style={{ flex: 1, minHeight: 280 }}
          />
          <p className="text-xs text-muted">
            Le CSS est aussi inclus dans le téléchargement HTML stylé.
          </p>
        </div>
      </aside>
    </div>
  );
}

function InfoRow({ label, value, highlight }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
      <span className="text-xs text-secondary">{label}</span>
      <span className="text-xs font-mono"
        style={{
          color: highlight ? 'var(--accent-success)' : 'var(--text-primary)',
          maxWidth: 160, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap'
        }}>
        {value}
      </span>
    </div>
  );
}

export default function App() {
  return (
    <ToastProvider>
      <AppInner />
    </ToastProvider>
  );
}
