<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.w3.org/1999/xhtml">

    <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />

    <xsl:strip-space elements="*" />

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="*[normalize-space(.) = '' and not(*) and not(self::hr or self::br or self::img)]" />

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

    <xsl:template match="a[starts-with(@id, '_idTextAnchor') and .='']" />

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

</xsl:stylesheet>