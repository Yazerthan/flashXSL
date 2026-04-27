import { forwardRef } from 'react';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { tomorrow as codeTheme } from 'react-syntax-highlighter/dist/esm/styles/prism';
import format from 'xml-formatter';
import { useToast } from '../hooks/useToast';
import { Copy } from 'lucide-react';

/**
 * Helper pour formater et colorer le code XML/HTML
 */
const FormattedCode = forwardRef(({ code, language = 'xml', maxHeight = 'none', onScroll }, ref) => {
  const { addToast } = useToast();

  const formattedCode = typeof code === 'string' ? (() => {
    try {
      return format(code, {
        indentation: '  ',
        collapseContent: true,
        lineSeparator: '\n'
      });
    } catch (e) {
      return code; // Retour au texte brut si erreur de parsing
    }
  })() : '';

  const copyToClipboard = () => {
    navigator.clipboard.writeText(formattedCode);
    addToast('Copié dans le presse-papier', 'info');
  };

  return (
    <div className="formatted-code-container" style={{ position: 'relative', width: '100%', height: maxHeight !== 'none' ? maxHeight : '100%' }}>
      <button
        className="btn-icon copy-btn"
        onClick={copyToClipboard}
        title="Copier le code"
        style={{
          position: 'absolute',
          top: 8,
          right: 24,
          zIndex: 10,
          background: 'rgba(255,255,255,0.05)',
          backdropFilter: 'blur(4px)',
          border: '1px solid rgba(255,255,255,0.1)',
          padding: '4px',
          borderRadius: '4px',
          color: 'var(--text-secondary)'
        }}
      >
        <Copy size={12} />
      </button>

      {/* 
         On utilise une div intermédiaire pour gérer le scroll et la REF.
         C'est beaucoup plus fiable que d'essayer d'attacher la ref au composant tiers.
      */}
      <div
        ref={ref}
        onScroll={onScroll}
        className="scroll-container-prism"
        style={{
          height: '100%',
          maxHeight: maxHeight,
          overflow: 'auto',
          width: '100%',
          background: 'transparent'
        }}
      >
        <SyntaxHighlighter
          language={language}
          style={codeTheme}
          customStyle={{
            margin: 0,
            padding: '16px',
            fontSize: '0.72rem',
            background: 'transparent',
            lineHeight: '1.5',
            width: '100%',
            overflow: 'visible' // Le scroll est géré par la div parente
          }}
          codeTagProps={{
            style: {
              fontFamily: '"JetBrains Mono", monospace'
            }
          }}
        >
          {formattedCode}
        </SyntaxHighlighter>
      </div>
    </div>
  );
});

FormattedCode.displayName = 'FormattedCode';
export default FormattedCode;
