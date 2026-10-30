<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml">

    <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />

    <xsl:strip-space elements="*" />
    <!-- Les espaces seules contenues dans un <span> sont significatives :
         on les conserve (sinon "1b." + " " + "Les..." donne "1b.Les..."). -->
    <xsl:preserve-space elements="*:span" />

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Suppression des éléments vides. Un <span> qui contient une espace
         n'est PAS vide : on le garde (sinon l'espace disparaît). -->
    <xsl:template
        match="*[normalize-space(.) = '' and not(*) and not(self::hr or self::br or self::img)
                 and not(self::span and string-length(.) &gt; 0)]" />

    <xsl:template match="div">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="*[span[@class='marqueur_page_web']]">
        <xsl:apply-templates select="span[@class='marqueur_page_web']" mode="extraction" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="node()[not(self::span[@class='marqueur_page_web'])]" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="span[@class='marqueur_page_web']" mode="extraction">
        <xsl:variable name="numeroSaut">
            <xsl:number level="any" count="span[@class='marqueur_page_web']" />
        </xsl:variable>
        <xsl:variable name="pageReelle" select="$numeroSaut + 1" />
        <hr role="doc-pagebreak" aria-label="page-{$pageReelle}" id="page-{$pageReelle}"
            class="page-marker" />
    </xsl:template>

    <xsl:template match="span[@class='marqueur_page_web']">
        <xsl:variable name="numeroSaut">
            <xsl:number level="any" count="span[@class='marqueur_page_web']" />
        </xsl:variable>
        <xsl:variable name="pageReelle" select="$numeroSaut + 1" />
        <hr role="doc-pagebreak" aria-label="page-{$pageReelle}" id="page-{$pageReelle}"
            class="page-marker" />
    </xsl:template>

    <!-- Suppression des ancres InDesign vides (_idTextAnchor…),           -->
    <!-- SAUF celles qui sont la cible d'un lien du sommaire.              -->
    <!-- Ces ancres référencées servent de fallback quand le titre         -->
    <!-- correspondant n'a pas de <h3> généré.                             -->
    <xsl:template match="a[starts-with(@id, '_idTextAnchor') and .='']">
        <xsl:variable name="ancre" select="concat('#', @id)" />
        <!-- On conserve l'ancre si elle est pointée par au moins un lien du sommaire -->
        <xsl:if test="//p[contains(@class, '•0_TITRE-ARTICLE-Sommaire')]//a[@href = $ancre]">
            <xsl:copy>
                <xsl:apply-templates select="@*" />
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <!-- Nettoyage des liens pour garder uniquement l'ancre relative (#id) -->
    <xsl:template match="@href">
        <xsl:attribute name="href">
            <xsl:choose>
                <xsl:when test="contains(., '#')">
                    <xsl:value-of select="concat('#', substring-after(., '#'))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- ================================================================ -->
    <!-- Gestion des listes imbriquées Tiret / Puce                       -->
    <!-- Un <ul> Enum-Puce qui suit directement un <ul> Enum-Tiret        -->
    <!-- est imbriqué dans le dernier <li> de ce <ul> Enum-Tiret.         -->
    <!-- Les listes isolées sont copiées sans modification.               -->
    <!-- ================================================================ -->

    <!-- Supprime les <ul> Puce directement précédés d'un <ul> Tiret :
         ils seront réémis depuis la template du <ul> Tiret. -->
    <xsl:template
        match="ul[li[1][contains(@class, '•6-2_TEXTE-COURANT-Enum-Puce')]]
                  [preceding-sibling::*[1]
                      [self::ul[li[1][contains(@class, '•6-1_TEXTE-COURANT-Enum-Tiret')]]]]" />

    <!-- Template pour le <ul> Enum-Tiret.
         Copie tous les <li> normalement, sauf le dernier dans lequel
         on injecte le(s) <ul> Puce qui suivent immédiatement. -->
    <xsl:template
        match="ul[li[1][contains(@class, '•6-1_TEXTE-COURANT-Enum-Tiret')]]">
        <xsl:variable name="ul-puce-suivant"
            select="following-sibling::*[1]
                        [self::ul[li[1][contains(@class, '•6-2_TEXTE-COURANT-Enum-Puce')]]]" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <!-- Tous les li sauf le dernier : copie normale -->
            <xsl:apply-templates select="li[position() != last()]" />
            <!-- Dernier li : on y injecte le ul Puce subordonné -->
            <xsl:apply-templates select="li[last()]" mode="dernier-tiret">
                <xsl:with-param name="ul-puce-suivant" select="$ul-puce-suivant" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- Mode "dernier-tiret" : copie le <li> puis ajoute le <ul> Puce à la fin. -->
    <xsl:template match="li" mode="dernier-tiret">
        <xsl:param name="ul-puce-suivant" />
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
            <!-- Injection du ul Puce imbriqué (copie identity via mode imbrique) -->
            <xsl:if test="$ul-puce-suivant">
                <xsl:apply-templates select="$ul-puce-suivant" mode="imbrique" />
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- Mode "imbrique" : copie le <ul> Puce avec son contenu normal. -->
    <xsl:template match="ul" mode="imbrique">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================ -->
    <!-- Suppression des u2026/u2026 isoles                               -->
    <!-- Correspond a un <p> dont normalize-space(.) = 'u2026/u2026'     -->
    <!-- ================================================================ -->
    <xsl:template match="p[normalize-space(.) = '…/…']" />

    <!-- ================================================================ -->
    <!-- Fusion des spans adjacents de même classe                        -->
    <!-- Dans h3.•1_TITRE-ARTICLE_h3 et p.•9_MOTS-CLES, InDesign coupe     -->
    <!-- parfois un style imbriqué en deux spans (ancre, balise XML...),   -->
    <!-- l'un ne contenant qu'une espace (ou rien). On les réunit.         -->
    <!-- ================================================================ -->

    <xsl:variable name="paragraphes-fusion"
        select="('•1_TITRE-ARTICLE_h3', '•9_MOTS-CLES')" />
    <xsl:variable name="spans-fusion"
        select="('•-NUMERO-TITRE-PRINCIPAL', '•-TITRE-PRINCIPAL',
                 '•-TITRE-MOTS-CLES', '•-TEXTE-MOTS-CLES')" />
    <!-- Spans qui doivent toujours commencer par une espace
         quand ils suivent le span précédent (numéro ou "Mots clés :"). -->
    <xsl:variable name="spans-espace-avant"
        select="('•-TITRE-PRINCIPAL', '•-TEXTE-MOTS-CLES')" />

    <xsl:template priority="2"
        match="*[tokenize(@class, '\s+') = $paragraphes-fusion]
                /span[@class = $spans-fusion]">
        <xsl:variable name="precedent" select="preceding-sibling::node()[1]" />
        <xsl:choose>
            <!-- Span déjà absorbé par le span de même classe qui le précède -->
            <xsl:when test="$precedent/self::span/@class = @class" />
            <xsl:otherwise>
                <!-- Contenu de ce span + des spans de même classe qui suivent -->
                <xsl:variable name="contenu">
                    <xsl:apply-templates select="." mode="fusion" />
                </xsl:variable>
                <!-- Espace manquante après le span précédent (ex. "Mots clés :") -->
                <xsl:variable name="espace-manquante" as="xs:boolean"
                    xmlns:xs="http://www.w3.org/2001/XMLSchema"
                    select="@class = $spans-espace-avant
                            and exists($precedent/self::span[@class = $spans-fusion])
                            and not(matches(string($precedent), '[\s&#xA0;]$'))
                            and not(matches(string($contenu), '^[\s&#xA0;]'))
                            and string($contenu) != ''" />
                <xsl:if test="$contenu/node()">
                    <xsl:copy>
                        <xsl:apply-templates select="@*" />
                        <xsl:if test="$espace-manquante">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:copy-of select="$contenu" />
                    </xsl:copy>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Mode "fusion" : sort le contenu du span, puis enchaîne sur le
         span suivant s'il est directement adjacent et de même classe. -->
    <xsl:template match="span" mode="fusion">
        <xsl:apply-templates select="node()" />
        <xsl:apply-templates mode="fusion"
            select="following-sibling::node()[1][self::span][@class = current()/@class]" />
    </xsl:template>

    <!-- ================================================================ -->
    <!-- Titre de chapitre : tout élément de classe __TitreChapitre       -->
    <!-- devient un <h2> (les attributs et le contenu sont conservés).    -->
    <!-- Priorité 3 : passe avant la règle des marqueurs de page et la    -->
    <!-- suppression des <div>, d'où la gestion du marqueur ici aussi.    -->
    <!-- ================================================================ -->
    <xsl:template priority="3"
        match="*[tokenize(@class, '\s+') = '__TitreChapitre'][not(self::h2)]">
        <xsl:apply-templates select="span[@class='marqueur_page_web']" mode="extraction" />
        <xsl:element name="h2" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="node()[not(self::span[@class='marqueur_page_web'])]" />
        </xsl:element>
    </xsl:template>

    <!-- ================================================================ -->
    <!-- Chemins d'images : ".../images/nom.jpg" devient "./images/nom.jpg" -->
    <!-- et ".../image/nom.png" devient "./image/nom.png" (export InDesign). -->
    <!-- (accepte aussi les séparateurs Windows "\").                     -->
    <!-- ================================================================ -->
    <xsl:template match="img/@src[matches(., '[/\\]image?[/\\]')]">
        <xsl:attribute name="src"
            select="replace(replace(., '^.*[/\\](image?)[/\\]', './$1/'), '\\', '/')" />
    </xsl:template>

</xsl:stylesheet>