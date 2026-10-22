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
        <!-- Cherche le h3 dont le texte normalisé correspond -->
        <xsl:variable name="titre-cible" select="key('titres-par-texte', $texte-sommaire)" />
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name() = 'href')]" />
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$titre-cible">
                        <!-- Pointe vers l'id du titre (existant ou généré) -->
                        <xsl:value-of select="concat('#',
                            if ($titre-cible[1]/@id)
                            then $titre-cible[1]/@id
                            else f:generer-id(string($titre-cible[1]))
                        )" />
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

</xsl:stylesheet>
