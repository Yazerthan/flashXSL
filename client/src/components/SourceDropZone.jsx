import { useState, useCallback } from 'react';
import { useToast } from '../hooks/useToast';
import { UploadCloud, FileText, Loader2, CheckCircle2, FileCode } from 'lucide-react';
import { generateUUID } from '../utils/id';

export default function SourceDropZone({ onFileLoaded }) {
  const [isDragOver, setIsDragOver] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [file, setFile] = useState(null);
  const { addToast } = useToast();

  const processFile = useCallback(async (f) => {
    if (!f) return;
    setIsLoading(true);
    try {
      const formData = new FormData();
      formData.append('file', f);

      const sessionId = localStorage.getItem('xsl-session-id') || generateUUID();
      localStorage.setItem('xsl-session-id', sessionId);

      const res = await fetch('/api/upload/source', {
        method: 'POST',
        headers: { 'x-session-id': sessionId },
        body: formData
      });

      if (!res.ok) throw new Error('Erreur upload');
      const data = await res.json();
      setFile({ name: f.name, size: f.size });
      onFileLoaded(data);
      addToast('Fichier source chargé', 'success');
    } catch (err) {
      addToast(`Erreur : ${err.message}`, 'error');
    } finally {
      setIsLoading(false);
    }
  }, [onFileLoaded, addToast]);

  const handleDrop = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(false);
    const f = e.dataTransfer.files[0];
    if (f) processFile(f);
  }, [processFile]);

  const handleChange = (e) => {
    const f = e.target.files[0];
    if (f) processFile(f);
  };

  return (
    <div className="p-4" style={{ borderBottom: '1px solid var(--border)' }}>
      <label
        className={`drop-zone${isDragOver ? ' drag-over' : ''}`}
        onDragOver={(e) => { e.preventDefault(); setIsDragOver(true); }}
        onDragLeave={() => setIsDragOver(false)}
        onDrop={handleDrop}
        style={{ cursor: 'pointer', display: 'block' }}
      >
        <input
          type="file"
          accept=".xml,.html,.xhtml,.htm"
          style={{ display: 'none' }}
          onChange={handleChange}
        />
        {isLoading ? (
          <>
            <div className="drop-zone-icon" style={{ display: 'flex', justifyContent: 'center' }}>
              <Loader2 size={42} className="spin" style={{ color: 'var(--accent-primary)' }} />
            </div>
            <h3>Chargement…</h3>
          </>
        ) : file ? (
          <>
            <div className="drop-zone-icon" style={{ display: 'flex', justifyContent: 'center' }}>
              <CheckCircle2 size={42} style={{ color: 'var(--accent-success)' }} />
            </div>
            <h3 className="font-mono" style={{ fontSize: '0.78rem', wordBreak: 'break-all' }}>{file.name}</h3>
            <p style={{ marginTop: 4 }}>{(file.size / 1024).toFixed(1)} Ko · Cliquer pour changer</p>
          </>
        ) : (
          <>
            <div className="drop-zone-icon" style={{ display: 'flex', justifyContent: 'center' }}>
              <FileText size={42} style={{ color: 'var(--accent-primary)', opacity: 0.8 }} />
            </div>
            <h3>Fichier source</h3>
            <p>Glissez un fichier XML / HTML / XHTML<br />ou cliquez pour parcourir</p>
          </>
        )}
      </label>
    </div>
  );
}
