<?xml version="1.0" encoding="UTF-8"?>
<!-- ==================================================================== -->
<!-- remplacement-images.xsl                                              -->
<!-- À exécuter APRÈS nettoyage.xsl.                                      -->
<!-- Remplace des suites EXACTES d'éléments frères (pictogrammes          -->
<!-- découpés en morceaux par l'export InDesign) par une seule image.     -->
<!-- ==================================================================== -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:local:fonctions"
    xmlns:m="urn:local:motifs"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs f m">

    <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />

    <xsl:strip-space elements="*" />
    <xsl:preserve-space elements="*:span" />

    <!-- ================================================================ -->
    <!-- MOTIFS À REMPLACER                                               -->
    <!-- Chaque m:motif contient la suite exacte d'éléments à repérer     -->
    <!-- (même ordre, mêmes attributs, même contenu).                     -->
    <!-- @src / @alt = l'image qui remplace la suite.                     -->
    <!-- @ordre="libre" : les mêmes éléments, mais dans n'importe quel    -->
    <!-- ordre (InDesign n'exporte pas toujours les morceaux pareil).     -->
    <!-- Pour ajouter un motif : copier un bloc m:motif.                  -->
    <!-- ================================================================ -->
    <xsl:variable name="motifs" as="element(m:motif)*">
        <m:motif src="./image/Steto.png" alt="" ordre="libre">
            <img class="_idGenObjectAttribute-1" src="./image/2.png" alt="" />
            <img class="_idGenObjectAttribute-1" src="./image/3.png" alt="" />
            <img class="_idGenObjectAttribute-1" src="./image/4.png" alt="" />
            <img class="_idGenObjectAttribute-1" src="./image/5.png" alt="" />
            <img class="_idGenObjectAttribute-1" src="./image/6.png" alt="" />
            <img class="_idGenObjectAttribute-1" src="./image/7.png" alt="" />
            <img class="_idGenObjectAttribute-1" alt="" />
            <img class="_idGenObjectAttribute-1" src="./image/9.png" alt="" />
            <img class="_idGenObjectAttribute-1" src="./image/10.png" alt="" />
        </m:motif>
        <m:motif src="./image/Bulle.png" alt="">
            <img class="_idGenObjectAttribute-1" src="./image/1.png" alt="" />
            <p class="Paragraphe-standard"><span class="Exclamation">!</span></p>
        </m:motif>
        <!-- Même bulle, exportée sous un autre numéro selon les chapitres -->
        <m:motif src="./image/Bulle.png" alt="">
            <img class="_idGenObjectAttribute-1" src="./image/126.png" alt="" />
            <p class="Paragraphe-standard"><span class="Exclamation">!</span></p>
        </m:motif>
    </xsl:variable>

    <!-- Copie à l'identique de tout le reste -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Début d'une suite reconnue : on la remplace par l'image.
         Aussi en mode "sans-ordo" (thead recopié lors du déplacement
         des ordonnances), sinon le motif n'y serait pas remplacé. -->
    <xsl:template match="*[exists(f:motif-debutant-ici(.))]" priority="3"
        mode="#default sans-ordo">
        <xsl:variable name="motif" select="f:motif-debutant-ici(.)" />
        <img src="{$motif/@src}" alt="{$motif/@alt}" />
    </xsl:template>

    <!-- Éléments suivants de la suite : supprimés -->
    <xsl:template match="node()[f:dans-un-motif(.)]" priority="2"
        mode="#default sans-ordo" />

    <!-- ================================================================ -->
    <!-- Fonctions                                                        -->
    <!-- ================================================================ -->

    <!-- Renvoie le motif dont la suite commence exactement sur $n
         ($n et ses frères suivants immédiats, texte compris :
         un texte non vide intercalé casse la correspondance). -->
    <xsl:function name="f:motif-debutant-ici" as="element(m:motif)?">
        <xsl:param name="n" as="node()" />
        <xsl:sequence select="
            $motifs[
                for $taille in count(*) return
                f:suite-correspond(
                    ($n, $n/following-sibling::node())[position() le $taille],
                    .)
            ][1]" />
    </xsl:function>

    <!-- Vrai si $suite correspond aux éléments du motif :
         à l'identique, ou à l'ordre près si @ordre="libre". -->
    <xsl:function name="f:suite-correspond" as="xs:boolean">
        <xsl:param name="suite" as="node()*" />
        <xsl:param name="motif" as="element(m:motif)" />
        <xsl:sequence select="
            if ($motif/@ordre = 'libre')
            then count($suite) eq count($motif/*)
                 and deep-equal(f:cles-triees($suite), f:cles-triees($motif/*))
            else deep-equal($suite, $motif/*)" />
    </xsl:function>

    <!-- Une clé texte par nœud (nom, attributs triés, contenu), triées :
         deux suites ont les mêmes clés triées si elles contiennent
         les mêmes éléments, quel que soit leur ordre. -->
    <xsl:function name="f:cles-triees" as="xs:string*">
        <xsl:param name="noeuds" as="node()*" />
        <xsl:sequence select="f:trier(
            for $x in $noeuds return
            string-join((
                namespace-uri($x), local-name($x), string($x),
                f:trier(for $a in $x/@* return concat(name($a), '=', $a))
            ), '|'))" />
    </xsl:function>

    <xsl:function name="f:trier" as="xs:string*">
        <xsl:param name="valeurs" as="xs:string*" />
        <xsl:perform-sort select="$valeurs">
            <xsl:sort select="." />
        </xsl:perform-sort>
    </xsl:function>

    <!-- Vrai si $n fait partie d'une suite reconnue, sans en être le début -->
    <xsl:function name="f:dans-un-motif" as="xs:boolean">
        <xsl:param name="n" as="node()" />
        <xsl:variable name="taille-max" select="max($motifs/count(*))" />
        <xsl:sequence select="
            some $i in 1 to $taille-max - 1 satisfies
                (for $debut in $n/preceding-sibling::node()[$i]
                 return exists($debut)
                    and count(f:motif-debutant-ici($debut)/*) gt $i)" />
    </xsl:function>

    <!-- ================================================================ -->
    <!-- Déplacement des images d'ORDONNANCE du thead vers le tbody         -->
    <!-- Seules les <img> dont le @src contient "ordonnance" sont déplacées.-->
    <!-- Les images de design / décoration restent dans le thead.           -->
    <!-- ================================================================ -->

    <!-- Template pour les tables dont le thead contient des images d'ordonnance -->
    <xsl:template match="table[.//thead//img[contains(@src, 'Ordonnance')]]" priority="2">
        <!-- Collecte uniquement les images d'ordonnance du thead -->
        <xsl:variable name="imgs-ordo" select=".//thead//img[contains(@src, 'Ordonnance')]" />
        <!-- Nombre de colonnes (basé sur le max de td/th par tr) -->
        <xsl:variable name="nb-cols"
            select="max((.//*[self::tr]/count(*[self::td or self::th]), 1))" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <!-- Copie le thead en supprimant uniquement les img d'ordonnance -->
            <xsl:apply-templates select="thead" mode="sans-ordo" />
            <!-- Copie le tbody en injectant les ordonnances au début -->
            <xsl:for-each select="tbody">
                <xsl:copy>
                    <xsl:apply-templates select="@*" />
                    <!-- Nouvelle ligne avec les ordonnances déplacées -->
                    <tr class="images-deplacees">
                        <td colspan="{$nb-cols}">
                            <xsl:for-each select="$imgs-ordo">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*" />
                                </xsl:copy>
                            </xsl:for-each>
                        </td>
                    </tr>
                    <!-- Contenu existant du tbody -->
                    <xsl:apply-templates select="node()" />
                </xsl:copy>
            </xsl:for-each>
            <!-- Copie les autres enfants de table (caption, colgroup, tfoot…) -->
            <xsl:apply-templates select="*[not(self::thead or self::tbody)]" />
        </xsl:copy>
    </xsl:template>

    <!-- Mode "sans-ordo" : copie identity, mais supprime les img d'ordonnance -->
    <xsl:template match="@*|node()" mode="sans-ordo">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="sans-ordo" />
        </xsl:copy>
    </xsl:template>

    <!-- Seules les img dont le src contient "ordonnance" sont supprimées -->
    <xsl:template match="img[contains(@src, 'Ordonnance')]" mode="sans-ordo" />

    <!-- Supprime les éléments du thead devenus vides après retrait des ordonnances.
         Une img (ou br/hr) n'a pas de contenu mais n'est pas "vide" : on la garde,
         sinon les images de design (Steto…) disparaissent. -->
    <xsl:template mode="sans-ordo"
        match="*[not(self::thead or self::img or self::br or self::hr)][ancestor-or-self::thead]
                [not(normalize-space()) and not(descendant::*[not(self::img[contains(@src, 'Ordonnance')])])]" />

</xsl:stylesheet>
