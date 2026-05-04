import { useState, useRef, useEffect } from 'react';
import { Download, Code2, Eye, Palette, RefreshCw, AlertTriangle, Target, Check, FileCode, Maximize2, X, Copy, Terminal } from 'lucide-react';
import { useToast } from '../hooks/useToast';
import format from 'xml-formatter';
import FormattedCode from './FormattedCode';
import deskIcon from '../assets/desk_white.svg';

const TABS = [
  { id: 'source', label: 'Source', icon: <Code2 size={13} /> },
  { id: 'preview', label: 'Rendu HTML', icon: <Eye size={13} /> },
  { id: 'styled', label: 'Rendu stylé', icon: <Palette size={13} /> },
  { id: 'steps', label: 'Étapes', icon: <RefreshCw size={13} /> },
  { id: 'console', label: 'Console', icon: <Terminal size={13} /> },
];

export default function ResultPanel({ source, result, steps, resultPath, customCss, onCssChange, error, theme }) {
  const [activeTab, setActiveTab] = useState('source');
  const iframeRef = useRef(null);
  const styledRef = useRef(null);
  const sourceRef = useRef(null);
  const scrollPosRef = useRef(0); // Stocke le % de scroll (0 à 1)
  const [expandedStep, setExpandedStep] = useState(null); // { title, content }
  const { addToast } = useToast();
  
  // Auto-switch vers l'onglet console en cas d'erreur
  useEffect(() => {
    if (error) {
      setActiveTab('console');
    }
  }, [error]);

  // Fonction pour synchroniser le scroll vers un élément/iframe
  const applyScroll = (target, percentage) => {
    if (!target) return;
    const scrollContainer = target.contentDocument?.documentElement || target.contentDocument?.body || target;
    if (scrollContainer) {
      const maxScroll = scrollContainer.scrollHeight - scrollContainer.clientHeight;
      scrollContainer.scrollTop = maxScroll * percentage;
    }
  };

  // Capturer le scroll depuis la source
  const handleSourceScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const maxScroll = scrollHeight - clientHeight;
    if (maxScroll > 0) {
      scrollPosRef.current = scrollTop / maxScroll;
    }
  };

  // Capturer le scroll depuis les iframes
  const attachIframeScroll = (iframe) => {
    if (!iframe) return;
    const win = iframe.contentWindow;
    if (!win) return;

    const onScroll = () => {
      const doc = win.document;
      const body = doc.documentElement || doc.body;
      const maxScroll = body.scrollHeight - body.clientHeight;
      if (maxScroll > 0) {
        scrollPosRef.current = body.scrollTop / maxScroll;
      }
    };

    // On attache aux deux pour être sûr (selon le navigateur)
    win.addEventListener('scroll', onScroll);
    win.document.addEventListener('scroll', onScroll);
    
    return () => {
      win.removeEventListener('scroll', onScroll);
      win.document?.removeEventListener('scroll', onScroll);
    };
  };

  // Appliquer le scroll lors du changement d'onglet
  useEffect(() => {
    const timer = setTimeout(() => {
      if (activeTab === 'source') applyScroll(sourceRef.current, scrollPosRef.current);
      if (activeTab === 'preview') applyScroll(iframeRef.current, scrollPosRef.current);
      if (activeTab === 'styled') applyScroll(styledRef.current, scrollPosRef.current);
    }, 100);
    return () => clearTimeout(timer);
  }, [activeTab]);

  // Injecter le CSS personnalisé dans l'iframe styled
  useEffect(() => {
    let cleanup;
    if (activeTab === 'styled' && styledRef.current && result) {
      const doc = styledRef.current.contentDocument || styledRef.current.contentWindow?.document;
      if (doc) {
        doc.open();
        doc.write(`<!DOCTYPE html><html><head>
<meta charset="utf-8"/>
<style>${customCss}</style>
</head><body>${result}</body></html>`);
        doc.close();
        // Attacher le listener et appliquer le scroll initial
        cleanup = attachIframeScroll(styledRef.current);
        applyScroll(styledRef.current, scrollPosRef.current);
      }
    }
    return () => cleanup && cleanup();
  }, [activeTab, result, customCss]);

  // Iframe pour le preview brut
  useEffect(() => {
    let cleanup;
    if (activeTab === 'preview' && iframeRef.current && result) {
      const doc = iframeRef.current.contentDocument || iframeRef.current.contentWindow?.document;
      if (doc) {
        doc.open();
        doc.write(result);
        doc.close();
        // Attacher le listener et appliquer le scroll initial
        cleanup = attachIframeScroll(iframeRef.current);
        applyScroll(iframeRef.current, scrollPosRef.current);
      }
    }
    return () => cleanup && cleanup();
  }, [activeTab, result]);

  const handleDownload = () => {
    if (!result) return;
    const blob = new Blob([result], { type: 'text/xml;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'result.xml';
    a.click();
    URL.revokeObjectURL(url);
    addToast('Fichier téléchargé', 'success');
  };

  const handleDownloadHtml = () => {
    if (!result) return;
    const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/><style>${customCss}</style></head><body>${result}</body></html>`;
    const blob = new Blob([html], { type: 'text/html;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'result-styled.html';
    a.click();
    URL.revokeObjectURL(url);
    addToast('HTML stylé téléchargé', 'success');
  };

  if (!result && !error) {
    return (
      <div className="preview-panel" style={{ justifyContent: 'center', alignItems: 'center', position: 'relative', overflow: 'hidden' }}>
        {/* Image de fond subtile */}
        <img
          src={deskIcon}
          alt=""
          style={{
            position: 'absolute',
            width: '60%',
            maxWidth: '400px',
            opacity: 0.04,
            pointerEvents: 'none',
            zIndex: 0
          }}
        />
        <div className="empty-state" style={{ position: 'relative', zIndex: 1 }}>
          <div className="empty-state-icon">
            <Target size={40} style={{ opacity: 0.5 }} />
          </div>
          <p style={{ fontSize: '0.85rem' }}>Le résultat de la<br />transformation apparaîtra ici</p>
        </div>
      </div>
    );
  }

  return (
    <div className="preview-panel fade-in">
      {/* Tabs */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        borderBottom: '1px solid var(--border)',
        padding: '0 18px',
        gap: 0,
        background: 'var(--bg-card)'
      }}>
        <div className="preview-tabs" style={{ flex: 1, padding: 0 }}>
          {TABS.map(t => (
            <button
              key={t.id}
              className={`preview-tab${activeTab === t.id ? ' active' : ''}`}
              onClick={() => setActiveTab(t.id)}
            >
               {t.id === 'console' && error && <span className="tab-error-dot" />}
               {t.icon}
               {t.label}
            </button>
          ))}
        </div>

        {/* Download buttons */}
        <div className="flex gap-2" style={{ marginLeft: 'auto' }}>
          <button 
            className="btn btn-secondary btn-sm" 
            onClick={handleDownload} 
            disabled={!result}
            title="Télécharger XML brut"
          >
            <Download size={13} /> XML
          </button>
          <button 
            className="btn btn-success btn-sm" 
            onClick={handleDownloadHtml} 
            disabled={!result}
            title="Télécharger HTML stylé"
          >
            <Download size={13} /> HTML stylé
          </button>
        </div>
      </div>

      {/* Tab contents */}
      <div className="preview-body" style={{ padding: activeTab === 'preview' || activeTab === 'styled' ? '12px' : '18px' }}>

        {activeTab === 'source' && (
          <div className="code-viewer">
            <div className="code-viewer-header">
              <span className="text-xs text-secondary font-mono">result.xml</span>
              <span className="text-xs text-muted">{result ? result.length.toLocaleString() : 0} caractères</span>
            </div>
            <div className="code-viewer-content-prism">
              <FormattedCode
                ref={sourceRef}
                code={result}
                onScroll={handleSourceScroll}
                maxHeight="600px"
                theme={theme}
              />
            </div>
          </div>
        )}

        {activeTab === 'preview' && (
          <div className="preview-iframe-wrap" style={{ minHeight: 400 }}>
            <iframe
              ref={iframeRef}
              className="preview-iframe"
              title="preview"
              sandbox="allow-same-origin allow-scripts allow-popups"
            />
          </div>
        )}

        {activeTab === 'styled' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div className="style-editor">
              <label className="text-xs text-secondary" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <Palette size={12} />
                CSS personnalisé appliqué au résultat
              </label>
              <textarea
                value={customCss}
                onChange={e => onCssChange(e.target.value)}
                placeholder="body { font-family: Arial; }\nh1 { color: #333; }"
                spellCheck={false}
              />
            </div>
            <div className="preview-iframe-wrap" style={{ minHeight: 340 }}>
              <iframe
                ref={styledRef}
                className="preview-iframe"
                title="styled-preview"
                sandbox="allow-same-origin allow-scripts allow-popups"
              />
            </div>
          </div>
        )}

        {activeTab === 'steps' && (
          <div className="steps-list">
            {source && (
              <div className="original-step-card fade-in" style={{ marginBottom: 12 }}>
                <div className="original-card-header">
                  <span className="original-badge">Source</span>
                  <span className="text-xs font-mono" style={{ color: 'var(--accent-secondary)', display: 'flex', alignItems: 'center', gap: 6 }}>
                    <FileCode size={12} /> {source.name}
                  </span>
                  <button
                    className="btn-icon btn-sm"
                    style={{ marginLeft: 'auto', padding: 2 }}
                    onClick={() => setExpandedStep({ title: source.name, content: source.content })}
                    title="Plein écran"
                  >
                    <Maximize2 size={12} />
                  </button>
                </div>
                <div className="code-viewer-content-prism" style={{ maxHeight: 150, opacity: 0.8 }}>
                  <FormattedCode code={source.content} maxHeight="150px" theme={theme} />
                </div>
              </div>
            )}
            {steps && steps.length > 0 ? steps.map((s, i) => (
              <div key={i} className="step-card fade-in">
                <div className="step-card-header">
                  <span className="step-badge">Étape {s.step}</span>
                  <span className="text-xs font-mono" style={{ color: 'var(--accent-secondary)' }}>{s.xslName}</span>
                  <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span className="text-xs text-muted" style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Check size={12} style={{ color: 'var(--accent-success)' }} /> OK
                    </span>
                    <button
                      className="btn-icon btn-sm"
                      style={{ padding: 2 }}
                      onClick={() => setExpandedStep({ title: `Étape ${s.step} : ${s.xslName}`, content: s.fullOutput })}
                      title="Plein écran"
                    >
                      <Maximize2 size={12} />
                    </button>
                  </div>
                </div>
                <div className="code-viewer-content-prism" style={{ maxHeight: 120 }}>
                  <FormattedCode code={s.outputPreview + '…'} maxHeight="120px" theme={theme} />
                </div>
              </div>
            )) : (
              <div className="empty-state">
                <p>Aucune étape à afficher</p>
              </div>
            )}
          </div>
        )}

        {activeTab === 'console' && (
          <div className="console-view fade-in">
            {error ? (
              <div className="error-console-card">
                <div className="error-console-header">
                  <AlertTriangle size={16} />
                  <span>{error.message}</span>
                </div>
                <div className="error-console-body">
                  <FormattedCode 
                    code={error.details} 
                    language="bash" 
                    maxHeight="500px" 
                    theme={theme}
                  />
                </div>
              </div>
            ) : (
              <div className="empty-state">
                <Terminal size={40} style={{ opacity: 0.2, marginBottom: 16 }} />
                <p>Aucune erreur ou log à afficher</p>
                <p className="text-xs text-muted" style={{ marginTop: 8 }}>
                  Les erreurs Saxon apparaîtront ici en cas d'échec du pipeline.
                </p>
              </div>
            )}
          </div>
        )}

        {/* Modal plein écran pour les étapes */}
        {expandedStep && (
          <div className="fullscreen-overlay fade-in" onClick={() => setExpandedStep(null)}>
            <div className="fullscreen-card" onClick={e => e.stopPropagation()}>
              <div className="fullscreen-header">
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Code2 size={16} className="text-accent" />
                  <span className="font-mono text-sm">{expandedStep.title}</span>
                </div>
                <button className="btn-icon" onClick={() => setExpandedStep(null)}>
                  <X size={20} />
                </button>
              </div>
              <div className="fullscreen-content-prism">
                <FormattedCode code={expandedStep.content} theme={theme} />
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
