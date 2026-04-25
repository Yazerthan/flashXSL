import { useState, useCallback } from 'react';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';
import { useToast } from '../hooks/useToast';
import { GripVertical, Trash2, Plus, ChevronUp, ChevronDown, Loader2, Zap, Link, PackageSearch } from 'lucide-react';
import { generateUUID } from '../utils/id';

export default function XslPipeline({ pipeline, setPipeline }) {
  const [isDragOver, setIsDragOver] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const { addToast } = useToast();

  const uploadXslFiles = useCallback(async (files) => {
    if (!files || files.length === 0) return;
    setIsLoading(true);
    try {
      const formData = new FormData();
      Array.from(files).forEach(f => formData.append('files', f));

      const sessionId = localStorage.getItem('xsl-session-id') || generateUUID();
      localStorage.setItem('xsl-session-id', sessionId);

      const res = await fetch('/api/upload/xsl', {
        method: 'POST',
        headers: { 'x-session-id': sessionId },
        body: formData
      });

      if (!res.ok) throw new Error('Erreur upload XSL');
      const data = await res.json();

      setPipeline(prev => {
        const names = new Set(prev.map(p => p.name));
        const newFiles = data.files.filter(f => !names.has(f.name));
        return [...prev, ...newFiles];
      });
      addToast(`${data.files.length} fichier(s) XSL ajouté(s)`, 'success');
    } catch (err) {
      addToast(`Erreur : ${err.message}`, 'error');
    } finally {
      setIsLoading(false);
    }
  }, [setPipeline, addToast]);

  const handleDrop = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(false);
    const files = e.dataTransfer.files;
    uploadXslFiles(files);
  }, [uploadXslFiles]);

  const handleChange = (e) => {
    uploadXslFiles(e.target.files);
    e.target.value = '';
  };

  const removeItem = (id) => {
    setPipeline(prev => prev.filter(p => p.id !== id));
  };

  const moveItem = (idx, dir) => {
    setPipeline(prev => {
      const next = [...prev];
      const target = idx + dir;
      if (target < 0 || target >= next.length) return prev;
      [next[idx], next[target]] = [next[target], next[idx]];
      return next;
    });
  };

  const onDragEnd = (result) => {
    if (!result.destination) return;
    const items = Array.from(pipeline);
    const [removed] = items.splice(result.source.index, 1);
    items.splice(result.destination.index, 0, removed);
    setPipeline(items);
  };

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      {/* Drop zone XSL */}
      <div className="p-4" style={{ borderBottom: '1px solid var(--border)' }}>
        <label
          className={`drop-zone${isDragOver ? ' drag-over' : ''}`}
          style={{ padding: '20px', display: 'block', cursor: 'pointer' }}
          onDragOver={(e) => { e.preventDefault(); setIsDragOver(true); }}
          onDragLeave={() => setIsDragOver(false)}
          onDrop={handleDrop}
        >
          <input
            type="file"
            accept=".xsl,.xslt"
            multiple
            style={{ display: 'none' }}
            onChange={handleChange}
          />
          {isLoading ? (
            <>
              <div className="drop-zone-icon pulse">
                <Loader2 size={32} className="spin" style={{ color: 'var(--accent-primary)' }} />
              </div>
              <h3 style={{ fontSize: '0.8rem' }}>Chargement…</h3>
            </>
          ) : (
            <>
              <div className="drop-zone-icon">
                <Zap size={32} style={{ color: 'var(--accent-primary)' }} />
              </div>
              <h3 style={{ fontSize: '0.82rem' }}>Ajouter des XSL</h3>
              <p style={{ fontSize: '0.7rem' }}>Glissez vos fichiers .xsl / .xslt<br/>ou cliquez pour parcourir</p>
            </>
          )}
        </label>
      </div>

      {/* Pipeline list */}
      {pipeline.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">
            <Link size={40} style={{ opacity: 0.5 }} />
          </div>
          <p>Aucune feuille XSL<br/>dans le pipeline</p>
        </div>
      ) : (
        <DragDropContext onDragEnd={onDragEnd}>
          <Droppable droppableId="pipeline">
            {(provided) => (
              <div
                className="pipeline-container"
                ref={provided.innerRef}
                {...provided.droppableProps}
              >
                {pipeline.map((item, idx) => (
                  <div key={item.id}>
                    <Draggable draggableId={item.id} index={idx}>
                      {(prov, snapshot) => (
                        <div
                          ref={prov.innerRef}
                          {...prov.draggableProps}
                          className={`pipeline-item${snapshot.isDragging ? ' dragging' : ''}`}
                        >
                          {/* Drag handle */}
                          <span {...prov.dragHandleProps} className="pipeline-drag-handle">
                            <GripVertical size={14} />
                          </span>

                          {/* Step number */}
                          <span className="pipeline-step-num">{idx + 1}</span>

                          {/* Name */}
                          <span className="pipeline-item-name" title={item.name}>
                            {item.name}
                          </span>

                          {/* Controls */}
                          <div className="flex gap-2">
                            <button
                              className="btn btn-icon"
                              style={{ padding: '3px' }}
                              onClick={() => moveItem(idx, -1)}
                              disabled={idx === 0}
                              title="Monter"
                            >
                              <ChevronUp size={12} />
                            </button>
                            <button
                              className="btn btn-icon"
                              style={{ padding: '3px' }}
                              onClick={() => moveItem(idx, 1)}
                              disabled={idx === pipeline.length - 1}
                              title="Descendre"
                            >
                              <ChevronDown size={12} />
                            </button>
                            <button
                              className="btn btn-icon"
                              style={{ padding: '3px', color: 'var(--accent-danger)' }}
                              onClick={() => removeItem(item.id)}
                              title="Supprimer"
                            >
                              <Trash2 size={12} />
                            </button>
                          </div>
                        </div>
                      )}
                    </Draggable>
                    {/* Connector arrow */}
                    {idx < pipeline.length - 1 && (
                      <div className="pipeline-connector" />
                    )}
                  </div>
                ))}
                {provided.placeholder}
              </div>
            )}
          </Droppable>
        </DragDropContext>
      )}
    </div>
  );
}
