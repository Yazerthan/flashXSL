export const NATHAN_DEFAULT_CSS = `/* --- Variables & Configuration --- */
:root {
    --blanc: #ffffff;
    --noir: #000000;
    --gris-clair: #f2f2f2; /* Pour l'alternance des lignes */
    --vert-nathan: #006747;
    --police-principale: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
}

/* --- Reset & Base --- */
* { box-sizing: border-box; }

body {
    font-family: var(--police-principale);
    line-height: 1.5;
    color: var(--noir);
    background-color: var(--blanc);
    margin: 2rem auto;
    padding: 0 1rem;
    max-width: 1000px;
}

/* --- Titres --- */
h3, h4, h5, h6, 
.•1_TITRE-ARTICLE_h3, 
.•7_INTER-1_h4, 
.•7_INTER-1-suivant-un-INTER-2_h4, 
.•8_INTER-2_h5, 
.•8_INTER-3_h6, 
.•8_INTER-2-suivant-INTER-3_h5 {
    color: var(--vert-nathan);
    margin-top: 1.8rem;
    margin-bottom: 0.8rem;
}

.•1_TITRE-ARTICLE_h3 {
    font-size: 1.8rem;
    border-bottom: 2px solid var(--vert-nathan);
    padding-bottom: 0.5rem;
}

/* --- Texte et Listes --- */
.•6_TEXTE-COURANT {
    text-align: justify;
    margin-bottom: 1rem;
}

.•2_NOMS-D-AUTEURS {
    font-style: italic;
    color: #555;
    margin-bottom: 2rem;
}

ul, ol {
    padding-left: 25px;
    margin-bottom: 1rem;
}

li { margin-bottom: 0.5rem; }

/* --- Gestion des Tableaux --- */
table {
    width: 100%;
    border-collapse: collapse;
    margin: 1.5rem 0;
}

/* Entêtes de tableaux */
thead tr, th, 
.PointCl-s_T-ti-re, 
.Tableau_T-ti-re, 
.SituationClinique_T-ti-re {
    background-color: var(--vert-nathan);
    color: var(--blanc);
    padding: 12px;
    text-align: left;
}

th { display: flex; }

/* Lignes de tableau : alternance gris/blanc */
tbody tr:nth-child(even) {
    background-color: var(--gris-clair);
}

td {
    padding: 10px;
    border: 1px solid #ddd;
    vertical-align: top;
}

/* --- Gestion des IMAGES --- */

/* 1. Filet vert par défaut sur les images sémantiques (hors tableaux) */
img {
    border: 1px solid var(--vert-nathan);
    padding: 2px;
    max-width: 100%;
    height: auto;
    display: block;
    margin: 1rem 0;
}

/* 2. EXCLUSION : Pas de bordure pour les icônes dans les tableaux ou titres */
table img, 
th img, 
td img, 
h3 img, 
h4 img, 
h5 img,
.Paragraphe-standard img {
    border: none !important;
    padding: 0 !important;
    margin: 0;
    display: inline-block;
    vertical-align: middle;
}

/* --- Blocs Spécifiques (Nathan Gabarit) --- */

/* Points clés */
.PointCl-s {
    border: 2px solid var(--vert-nathan);
}

.•3_POINTS-CL-S-TITRE-NEW {
    font-weight: bold;
    text-transform: uppercase;
    display: inline-block;
    margin-left: 5px;
}

/* Situations cliniques */
.SituationClinique {
    border: 2px solid var(--vert-nathan);
    margin-bottom: 2.5rem;
}

.•12_SITUATION-CLINIQUE-TITRE {
    font-weight: bold;
    font-size: 1.1rem;
    margin: 0;
}

.•13_SITUATION-CLINIQUE-QUESTION-BOLD-NOIR {
    font-weight: bold;
}

.•14_SITUATION-CLINIQUE-INTER-VERT, .•14-1_SITUATION-CLINIQUE-INTER-VERT {
    color: var(--vert-nathan);
    font-weight: bold;
    margin-top: 15px;
    display: block;
}

/* Mots-clés & Références */
.•9_MOTS-CL-S {
    background-color: var(--gris-clair);
    padding: 1rem;
    border-left: 5px solid var(--vert-nathan);
    margin-top: 2rem;
    font-size: 0.9rem;
}

.•10_REFERENCES-TITRE {
    margin-top: 2rem;
    font-weight: bold;
    color: var(--vert-nathan);
    border-bottom: 1px solid #ddd;
}

.•11_REFERENCES-1-CHIFFRE-TEXTE {
    font-size: 0.85rem;
    margin-bottom: 8px;
    padding-left: 10px;
}

/* --- Divers & Overrides --- */
.Appel, ._idGenCharOverride-1, .Texte-courant-exposant, ._idGenCharOverride-2 {
    font-size: 0.75em;
    vertical-align: super;
    line-height: 0;
}

a {
    color: var(--vert-nathan);
    text-decoration: underline;
}

.Ancrage {
    text-align: center;
}

/* --- Responsive --- */
@media (max-width: 768px) {
    body { margin: 1rem auto; }
    table { display: block; overflow-x: auto; }
}`;
