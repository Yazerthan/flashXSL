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

</xsl:stylesheet>