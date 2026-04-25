/**
 * Génère un UUID compatible avec les contextes non-sécurisés (HTTP)
 * Fallback pour crypto.randomUUID() qui n'est disponible que sur localhost ou HTTPS
 */
export const generateUUID = () => {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID();
  }
  // Fallback simple basé sur Math.random et timestamp
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
};
