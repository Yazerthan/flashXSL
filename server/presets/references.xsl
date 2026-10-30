<?xml version="1.0" encoding="UTF-8"?>
<!-- ==================================================================== -->
<!-- references.xsl                                                        -->
<!-- À exécuter APRÈS nettoyage.xsl (et images.xsl si applicable).         -->
<!--                                                                       -->
<!-- Objectif : relier les entrées du sommaire (p.•0_TITRE-ARTICLE-Sommaire)-->
<!-- aux titres correspondants (h3.•1_TITRE-ARTICLE_h3) dans le document.  -->
<!--                                                                       -->
<!-- Fonctionnement :                                                      -->
<!--  1. Chaque <h3> titre-article reçoit un @id déterministe              -->
<!--     (basé sur le texte normalisé du titre).                           -->
<!--  2. Chaque lien <a> dans le sommaire est réécrit pour pointer         -->
<!--     vers le @id du <h3> dont le texte correspond.                     -->
<!-- ==================================================================== -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:local:fonctions"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs f">

    <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />

    <xsl:strip-space elements="*" />
    <xsl:preserve-space elements="*:span" />

    <!-- ================================================================ -->
    <!-- Copie à l'identique                                               -->
    <!-- ================================================================ -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================ -->
    <!-- Clé : indexe les titres h3 par leur texte normalisé               -->
    <!-- ================================================================ -->
    <xsl:key name="titres-par-texte"
        match="h3[contains(@class, '•1_TITRE-ARTICLE_h3')]"
        use="f:normaliser(string(.))" />

    <!-- ================================================================ -->
    <!-- Fonction utilitaire : normalise un texte pour comparaison         -->
    <!-- Supprime les &nbsp; (U+00A0), normalise les espaces, met en      -->
    <!-- minuscules pour une correspondance robuste.                       -->
    <!-- ================================================================ -->
    <xsl:function name="f:normaliser" as="xs:string">
        <xsl:param name="texte" as="xs:string" />
        <xsl:sequence select="lower-case(
            normalize-space(
                translate($texte, '&#xA0;', ' ')
            )
        )" />
    </xsl:function>

    <!-- ================================================================ -->
    <!-- Fonction utilitaire : génère un id valide à partir d'un texte     -->
    <!-- Ex: "1a. Les conditions..." → "titre-1a-les-conditions"           -->
    <!-- ================================================================ -->
    <xsl:function name="f:generer-id" as="xs:string">
        <xsl:param name="texte" as="xs:string" />
        <xsl:variable name="normalise" select="f:normaliser($texte)" />
        <!-- Remplace les caractères non-alphanumériques par des tirets -->
        <xsl:variable name="slug" select="replace($normalise, '[^a-z0-9]+', '-')" />
        <!-- Supprime les tirets en début/fin -->
        <xsl:variable name="slug-propre" select="replace(replace($slug, '^-+', ''), '-+$', '')" />
        <xsl:sequence select="concat('titre-', $slug-propre)" />
    </xsl:function>

    <!-- Numéro en tête d'un titre normalisé : "3. impact…" → "3",
         "1a. les conditions…" → "1a" ; chaîne vide s'il n'y en a pas -->
    <xsl:function name="f:numero-titre" as="xs:string">
        <xsl:param name="texte" as="xs:string" />
        <xsl:sequence select="
            if (matches($texte, '^[0-9]+[a-z]?\.'))
            then replace($texte, '^([0-9]+[a-z]?)\..*$', '$1', 's')
            else ''" />
    </xsl:function>

    <!-- Clé : indexe les titres h3 par leur numéro ("1a", "3"…) -->
    <xsl:key name="titres-par-numero"
        match="h3[contains(@class, '•1_TITRE-ARTICLE_h3')]"
        use="f:numero-titre(f:normaliser(string(.)))" />

    <!-- Id d'un titre h3 : son @id s'il en a un, sinon l'id généré -->
    <xsl:function name="f:id-titre" as="xs:string">
        <xsl:param name="h3" as="element()" />
        <xsl:sequence select="if ($h3/@id) then string($h3/@id) else f:generer-id(string($h3))" />
    </xsl:function>

    <!-- ================================================================ -->
    <!-- Les titres h3 : ajout d'un @id déterministe                       -->
    <!-- Si le h3 a déjà un @id, on le conserve ; sinon on en génère un.  -->
    <!-- ================================================================ -->
    <xsl:template match="h3[contains(@class, '•1_TITRE-ARTICLE_h3')]">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <!-- Ajoute l'id seulement s'il n'en a pas déjà un -->
            <xsl:if test="not(@id)">
                <xsl:attribute name="id" select="f:generer-id(string(.))" />
            </xsl:if>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================ -->
    <!-- Liens du sommaire : réécriture du @href                           -->
    <!-- On cherche le <a> à l'intérieur d'un <p> Sommaire, et on         -->
    <!-- réécrit son href vers le #id du h3 correspondant.                 -->
    <!-- ================================================================ -->
    <xsl:template match="p[contains(@class, '•0_TITRE-ARTICLE-Sommaire')]//a">
        <!-- Texte de l'entrée du sommaire (extrait du span enfant ou du lien) -->
        <xsl:variable name="texte-sommaire" select="f:normaliser(string(.))" />
        <!-- Cherche le h3 de même numéro ("3."), sinon de même texte normalisé :
             le numéro résiste aux coquilles de l'export (ex. "le vHazard Score") -->
        <xsl:variable name="numero" select="f:numero-titre($texte-sommaire)" />
        <xsl:variable name="titre-cible" select="
            (if ($numero != '') then key('titres-par-numero', $numero) else (),
             key('titres-par-texte', $texte-sommaire))[1]" />
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name() = 'href')]" />
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$titre-cible">
                        <!-- Pointe vers l'id du titre (existant ou généré) -->
                        <xsl:value-of select="concat('#', f:id-titre($titre-cible))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Pas de titre trouvé : on laisse le href d'origine -->
                        <xsl:value-of select="@href" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================ -->
    <!-- LIENS VIDES (href="" dès l'export InDesign)                       -->
    <!--  - texte = une URL ("https://…", "www.…") : le texte devient href  -->
    <!--  - "chapitre N, texte M" avec N = chapitre courant : lien vers    -->
    <!--    le sous-chapitre M                                             -->
    <!--  - sinon (autre chapitre, noms d'auteurs…) : laissé tel quel      -->
    <!-- ================================================================ -->

    <!-- Numéro du chapitre courant ("Chapitre 1") -->
    <xsl:variable name="chapitre-courant"
        select="normalize-space((//span[@class = 'Numchapitre'])[1])" />

    <xsl:template priority="2"
        match="a[@href = ''][not(ancestor::p[contains(@class, '•0_TITRE-ARTICLE-Sommaire')])]">
        <!-- Texte sans espaces : les URL longues sont coupées par des retours à la ligne -->
        <xsl:variable name="url" select="replace(string(.), '\s+', '')" />
        <xsl:variable name="renvoi" select="f:normaliser(string(.))" />
        <xsl:variable name="regex-renvoi" select="'^chapitre ([0-9]+) ?, ?texte ([0-9]+[a-z]?)$'" />
        <xsl:variable name="cible" as="xs:string?" select="
            if (matches($url, '^(https?://|www\.)[^\s]+$'))
            then (if (starts-with($url, 'www.')) then concat('https://', $url) else $url)
            else if (matches($renvoi, $regex-renvoi)
                     and replace($renvoi, $regex-renvoi, '$1') = $chapitre-courant)
            then (for $h3 in key('titres-par-numero', replace($renvoi, $regex-renvoi, '$2'))[1]
                  return concat('#', f:id-titre($h3)))
            else ()" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:if test="exists($cible)">
                <xsl:attribute name="href" select="$cible" />
            </xsl:if>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================ -->
    <!-- RÉFÉRENCES BIBLIOGRAPHIQUES PAR SOUS-CHAPITRE                     -->
    <!-- Chaque sous-chapitre (h3 titre-article) a sa propre numérotation  -->
    <!-- et sa liste <ol> après le paragraphe "Références".                -->
    <!--  1. Chaque <li> de cette liste reçoit un @id :                    -->
    <!--     ref-<numéro du sous-chapitre>-<rang>  (ex. "ref-1a-2")         -->
    <!--  2. Chaque appel en exposant <a href="#_idTextAnchor…">N</a>      -->
    <!--     (ancres InDesign supprimées par nettoyage.xsl) est réécrit    -->
    <!--     vers la Nᵉ référence de son sous-chapitre.                    -->
    <!-- ================================================================ -->

    <!-- Sous-chapitre d'un nœud : le dernier h3 titre-article qui le précède -->
    <xsl:function name="f:sous-chapitre" as="element()?">
        <xsl:param name="n" as="node()" />
        <xsl:sequence select="$n/preceding::h3[contains(@class, '•1_TITRE-ARTICLE_h3')][1]" />
    </xsl:function>

    <!-- Vrai si ce <ol> est la liste suivant un titre "Références"
         (et non "Pour aller plus loin", etc.) -->
    <xsl:function name="f:est-liste-references" as="xs:boolean">
        <xsl:param name="ol" as="element()" />
        <xsl:sequence select="exists($ol/preceding-sibling::*[1]
            [self::p[contains(@class, 'REFERENCES-TITRE')]]
            [f:normaliser(string(.)) = 'références'])" />
    </xsl:function>

    <!-- Liste des références d'un sous-chapitre (la première trouvée) -->
    <xsl:function name="f:liste-references" as="element()?">
        <xsl:param name="h3" as="element()" />
        <xsl:sequence select="$h3/following::ol
            [f:est-liste-references(.)]
            [f:sous-chapitre(.) is $h3][1]" />
    </xsl:function>

    <!-- Préfixe des ids : "ref-1a" d'après le numéro du titre ("1a."),
         ou le rang du sous-chapitre si le titre n'a pas de numéro -->
    <xsl:function name="f:prefixe-ref" as="xs:string">
        <xsl:param name="h3" as="element()" />
        <xsl:variable name="numero" select="replace(f:normaliser(string(
            $h3/span[contains(@class, 'NUMERO-TITRE-PRINCIPAL')][1])), '[^a-z0-9]+', '')" />
        <xsl:sequence select="concat('ref-',
            if ($numero != '') then $numero
            else string(count($h3/preceding::h3[contains(@class, '•1_TITRE-ARTICLE_h3')]) + 1))" />
    </xsl:function>

    <!-- Lignes de la liste des références : ajout de l'@id -->
    <xsl:template match="ol[f:est-liste-references(.)][exists(f:sous-chapitre(.))]/li">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:attribute name="id" select="concat(
                f:prefixe-ref(f:sous-chapitre(..)), '-',
                count(preceding-sibling::li) + 1)" />
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Appels en exposant : lien vers la référence du même sous-chapitre.
         Si la référence n'existe pas, le lien est laissé tel quel. -->
    <xsl:template match="a[starts-with(@href, '#_idTextAnchor')]
                          [matches(normalize-space(.), '^[0-9]+$')]">
        <xsl:variable name="h3" select="f:sous-chapitre(.)" />
        <xsl:variable name="liste" select="if ($h3) then f:liste-references($h3) else ()" />
        <xsl:variable name="rang" select="xs:integer(normalize-space(.))" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:if test="$liste and $rang le count($liste/li)">
                <xsl:attribute name="href" select="concat('#', f:prefixe-ref($h3), '-', $rang)" />
            </xsl:if>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
