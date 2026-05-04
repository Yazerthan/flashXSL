<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times" xmlns:str="http://exslt.org/strings"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:tbx="urn:iso:std:iso:30042:ed-1"
  version="2.0" exclude-result-prefixes="date str xsl tbx" extension-element-prefixes="date str">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes" />

  <xsl:template match="standard">
    <html>
      <xsl:if test="@xml:lang">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="@xml:lang" />
        </xsl:attribute>
      </xsl:if>
      <xsl:comment>
        <xsl:text>generated at : </xsl:text>
        <xsl:value-of select="current-dateTime()"/>
      </xsl:comment>
      <!-- <xsl:apply-templates select="front" mode="header"/> -->
      <xsl:apply-templates select="." mode="body" />
    </html>
  </xsl:template>

  <!-- <xsl:template match="front" mode="header"> -->
  <!-- <head> -->
  <!-- <link rel="stylesheet" type="text/css" href="desk.css" /> -->
  <!-- <xsl:apply-templates select="std-meta[@std-meta-type='afnor']" mode="header"/> -->
  <!-- odd case where std-meta[@std-meta-type='afnor'] is missing -->
  <!-- <xsl:if test="count(std-meta[@std-meta-type='afnor'])=0"> -->
  <!-- <xsl:apply-templates select="std-meta[@std-meta-type='desk']" mode="header"/> -->
  <!-- </xsl:if> -->
  <!-- </head> -->
  <!-- </xsl:template> -->

  <!-- <xsl:template match="std-meta" mode="header">
    <xsl:apply-templates select="title-wrap[@xml:lang='fr']" mode="header"/>
  </xsl:template> -->

  <!-- <xsl:template match="title-wrap" mode="header">
    <title>
      <xsl:apply-templates select="title-wrap" mode="header"/>
    </title>
  </xsl:template> -->

  <xsl:template match="standard" mode="body">
    <body>
      <xsl:apply-templates select="front" mode="body" />
      <xsl:apply-templates select="body" />
      <xsl:apply-templates select="back" />
    </body>
  </xsl:template>

  <xsl:template match="front" mode="body">
    <xsl:apply-templates select="std-meta[@std-meta-type='afnor']" mode="body" />
    <xsl:apply-templates select="std-meta[@std-meta-type='european']" mode="body" />
    <!-- <xsl:apply-templates select="sec[@sec-type='endorsement']"/> -->
    <xsl:apply-templates select="sec[@sec-type='afnor_foreword']" />
    <xsl:apply-templates select="sec[@sec-type='foreword']" />
    <xsl:apply-templates select="sec[@sec-type='intro']" />
    <xsl:apply-templates select="sec[@sec-type='european_foreword']" />
    <!-- <xsl:apply-templates select="std-meta[@std-meta-type='afnor']/title-wrap[@xml:lang='fr']"
    mode="title" /> -->
    <!-- <xsl:apply-templates
    select="sec[not(@sec-type='european_foreword')][not(@sec-type='endorsement')][not(@sec-type='afnor_foreword')][not(@sec-type='foreword')][not(@sec-type='intro')]"/> -->
  </xsl:template>

  <xsl:template match="body">
    <div class="body">
      <xsl:apply-templates select="sec" />
    </div>
  </xsl:template>

  <xsl:template match="back">
    <div class="back">
      <xsl:apply-templates />
    </div>
  </xsl:template>


  <xsl:template match="std-meta" mode="body">
    <div class="std-meta">
      <!-- <xsl:apply-templates select="ics-wrap"/> -->
      <xsl:apply-templates select="title-wrap[@xml:lang='fr']" mode="title" />
      <xsl:apply-templates select="title-wrap[not(@xml:lang='fr')]" mode="subtitle" />
      <xsl:apply-templates select="custom-meta-group/custom-meta[@id='status']" />
      <xsl:apply-templates select="std-org-group" />
      <!-- <xsl:apply-templates select="permissions" /> -->
    </div>
  </xsl:template>

  <!-- <xsl:template match="*" mode="debug"> -->
  <!--   <xsl:comment> -->
  <!--     <xsl:value-of select="name()" /> -->
  <!--     <xsl:if test="@id"> -->
  <!-- 	<xsl:text> id: </xsl:text> -->
  <!-- 	<xsl:value-of select="@id" /> -->
  <!--     </xsl:if> -->
  <!--     <xsl:if test="@std-meta-type"> -->
  <!-- 	<xsl:text> std-meta-type: </xsl:text> -->
  <!-- 	<xsl:value-of select="@std-meta-type" /> -->
  <!--     </xsl:if> -->
  <!--   </xsl:comment> -->
  <!-- </xsl:template> -->
  <!-- <xsl:template match="sec" mode="debug"> -->
  <!--   <div> -->
  <!--      <xsl:if test="@id"> -->
  <!-- 	<xsl:attribute name="id"> -->
  <!-- 	  <xsl:value-of select="@id" /> -->
  <!-- 	</xsl:attribute> -->
  <!--     </xsl:if> -->
  <!--     <xsl:attribute name="class"> -->
  <!-- 	<xsl:value-of select="meta-name/text()" /> -->
  <!--     </xsl:attribute> -->
  <!--   </div> -->
  <!-- </xsl:template> -->

  <!-- <xsl:template match="ics-wrap">
    <div class="ics-wrap">
      <xsl:text>ICS : </xsl:text>
      <xsl:apply-templates select="ics[1]" mode="first"/>
    </div>
  </xsl:template> -->

  <xsl:template match="ics" mode="first">
    <p class="ics">
      <xsl:apply-templates select="../ics" />
    </p>
  </xsl:template>

  <xsl:template match="ics">
    <xsl:if test="preceding-sibling::ics">
      <xsl:text> ; </xsl:text>
    </xsl:if>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="title-wrap" mode="title">
    <h1>
      <xsl:if test="@xml:lang">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="@xml:lang" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="title" />
    </h1>
  </xsl:template>

  <!-- <xsl:template match="main" mode="title"> -->
  <!-- <xsl:apply-templates/> -->
  <!-- </xsl:template> -->

  <!-- <xsl:template match="subtitle" mode="title">
    <xsl:if test="preceding-sibling::main[text()]">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template> -->

  <xsl:template match="full" mode="title">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="title-wrap" mode="subtitle">
    <h2>
      <!-- <xsl:if test="@xml:lang"> -->
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="@xml:lang" />
      </xsl:attribute>
      <!-- </xsl:if> -->
      <xsl:apply-templates mode="subtitle" />
    </h2>
  </xsl:template>

  <xsl:template match="main" mode="subtitle">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="subtitle" mode="subtitle">
    <xsl:if test="preceding-sibling::main[text()]">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="full" mode="subtitle">
    <!-- <xsl:if test="count(preceding-sibling::*[text()])=0"> -->
    <xsl:apply-templates />
    <!-- </xsl:if> -->
  </xsl:template>

  <xsl:template match="custom-meta">
    <div class="custom-meta">
      <xsl:apply-templates select="." mode="id" />
      <xsl:attribute name="class">
        <xsl:value-of select="meta-name/text()" />
      </xsl:attribute>
      <xsl:apply-templates select="meta-value" />
    </div>
  </xsl:template>

  <xsl:template match="meta-value">
    <p class="meta-value">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <!-- std-org -->

  <xsl:template match="std-org-grp">
    <div class="std-org-group">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="std-org">
    <div class="std-org">
      <xsl:attribute name="class">
        <xsl:text>std-org</xsl:text>
        <xsl:if test="@std-org-role">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@std-org-role" />
        </xsl:if>
        <xsl:if test="@std-org-type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@std-org-type" />
        </xsl:if>
        <xsl:if test="@std-org-level">
          <xsl:text> std-org-level-</xsl:text>
          <xsl:value-of select="@std-org-level" />
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="std-org-name">
    <p class="std-org-name">
      <xsl:value-of select="." />
    </p>
  </xsl:template>

  <xsl:template match="std-org-abbrev">
    <p class="std-org-abbrev">
      <xsl:value-of select="." />
    </p>
  </xsl:template>

  <xsl:template match="std-org-log">
    <address class="std-org-loc">
      <xsl:apply-templates />
    </address>
  </xsl:template>

  <xsl:template match="addr-line">
    <span class="addr-line">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <xsl:template match="city">
    <span class="city">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <xsl:template match="state">
    <span class="state">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <xsl:template match="postal-code">
    <span class="postal-code">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <xsl:template match="uri">
    <span class="uri">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <!-- permissions -->
  <!-- <xsl:template match="permissions"> -->
  <!-- <div class="permissions"> -->
  <!-- <xsl:apply-templates/> -->
  <!-- </div> -->
  <!-- </xsl:template> -->

  <!-- <xsl:template match="copyright-statement">
    <p class="copyright-statement">
      <xsl:value-of select="." />
    </p>
  </xsl:template>

  <xsl:template match="copyright-year">
    <p class="copyright-year">
      <xsl:value-of select="." />
    </p>
  </xsl:template>

  <xsl:template match="copyright-holder">
    <p class="copyright-holder">
      <xsl:value-of select="." />
    </p>
  </xsl:template> -->

  <!-- <xsl:template match="label">
    <label>
      <xsl:apply-templates select="." mode="id"/>
      <xsl:apply-templates/>
    </label>
  </xsl:template> -->

  <!-- sec -->
  <xsl:template match="sec">
    <div>
      <xsl:apply-templates select="." mode="id" />
      <xsl:if test="@sec-type">
        <xsl:attribute name="class">
          <xsl:text>sec </xsl:text>
          <xsl:value-of select="@sec-type" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="sec/title">
    <h3 class="sec-title">
      <xsl:apply-templates />
    </h3>
  </xsl:template>


  <!-- on masque le label s'il est le premier fils -->
  <xsl:template match="sec/label[count(preceding-sibling::*)=0]" />

  <!-- si le premier title est précédé d'un label -->
  <xsl:template match="sec/title[count(preceding-sibling::*)=1][count(preceding-sibling::label)=1]">
    <h3 class="sec-title">
      <xsl:apply-templates select="preceding-sibling::label[1]" mode="sec" />
      <xsl:apply-templates />
    </h3>
  </xsl:template>

  <xsl:template
    match="sec/sec/label[count(preceding-sibling::*)=0]|sec/sec/sec/label[count(preceding-sibling::*)=0]|sec/sec/sec/sec/label[count(preceding-sibling::*)=0]" />
  <!--   <strong> -->
  <!--     <xsl:apply-templates/> -->
  <!--   </strong> -->
  <!-- </xsl:template> -->

  <!-- si le premier p est précédé d'un label -->
  <xsl:template match="sec/p[count(preceding-sibling::*)=1][count(preceding-sibling::label)=1]">
    <p>
      <xsl:apply-templates select="preceding-sibling::label[1]" mode="sec" />
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="sec/sec/title">
    <h4 class="sec-sec-title">
      <xsl:apply-templates select="preceding-sibling::label[1]" mode="sec" />
      <xsl:apply-templates />
    </h4>
  </xsl:template>

  <xsl:template match="sec/sec/sec/title">
    <h5 class="sec-sec-sec-title">
      <xsl:apply-templates select="preceding-sibling::label[1]" mode="sec" />
      <xsl:apply-templates />
    </h5>
  </xsl:template>

  <!-- sinon il y a un conflit avec la regle premier fils -->
  <xsl:template match="label" mode="sec">
    <label class="label-sec">
      <xsl:apply-templates />
      <xsl:text> </xsl:text>
    </label>
  </xsl:template>

  <!-- appendix -->
  <xsl:template match="app-group">
    <br style="break-after: always;" />

    <div class="appendix">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="app">
    <div class="app">
      <xsl:attribute name="class">
        <xsl:text>app</xsl:text>
        <xsl:if test="@content-type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@content-type" />
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="id" />
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="app[title]/label[count(preceding-sibling::*)=0]" />

  <xsl:template match="app/title">
    <h2 class="app-title">
      <xsl:if test="preceding-sibling::label[count(preceding-sibling::*)=0]">
        <strong>
          <xsl:value-of select="preceding-sibling::label[count(preceding-sibling::*)=0]" />
        </strong>
      </xsl:if>
      <xsl:apply-templates />
    </h2>
  </xsl:template>
  <!-- note -->
  <!-- <xsl:template match="non-normative-note" mode="p"> -->
  <!--   <xsl:apply-templates select="." /> -->
  <!-- </xsl:template> -->

  <xsl:template match="non-normative-note | non-normative-example">
    <p class="Note" style="font-size: 10pt">
      <xsl:apply-templates select="." mode="id" />
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <!-- on masque le label s'il est le premier fils -->
  <!-- <xsl:template match="non-normative-note/label[count(preceding-sibling::*)=0] |
  non-normative-example/label[count(preceding-sibling::*)=0]" /> -->

  <!-- si le premier p est précédé d'un label -->
  <xsl:template
    match="non-normative-note/p | non-normative-example/p">
    <xsl:if test="preceding-sibling::p[normalize-space(.) or *]">
      <br />
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>

  <!-- sinon il y a un conflit avec la regle premier fils -->
  <xsl:template match="label" mode="note">
    <label>
      <xsl:apply-templates />
      <xsl:text> </xsl:text>
    </label>
  </xsl:template>


  <!-- img -->
  <xsl:template match="fig">
    <div class="figure">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="graphic|inline-graphic">
    <img style="max-width:100%; height:auto;" alt="">
      <xsl:attribute name="src">
        <xsl:text>./</xsl:text>
        <xsl:value-of select="@xlink:href" />
        <xsl:text>.png</xsl:text>
      </xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template match="caption">
    <div class="caption">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="caption/title">
    <h4 class="caption-title">
      <xsl:apply-templates />
    </h4>
  </xsl:template>

  <!-- p -->
  <xsl:template match="p">
    <p>
      <xsl:apply-templates />
    </p>
  </xsl:template>


  <!-- split on p on several p -->
  <!-- <xsl:template match="p[table-wrap]|p[list]|p[non-normative-note]"> -->
  <!--   <xsl:apply-templates mode="p"/> -->
  <!-- </xsl:template> -->

  <!-- <xsl:template match="*" mode="p"> -->
  <!--   <p> -->
  <!--     <xsl:apply-templates select="." /> -->
  <!--   </p> -->
  <!-- </xsl:template> -->

  <!-- fn -->
  <!-- <xsl:template match="fn">
    <p class="footnote" style="float:footnote;">
      <xsl:apply-templates select="." mode="id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template> -->

  <!-- on masque le label s'il est le premier fils -->
  <!-- <xsl:template match="fn/label[count(preceding-sibling::*)=0]" /> -->

  <!-- si le premier p est précédé d'un label -->
  <!-- <xsl:template match="fn/p[count(preceding-sibling::*)=1][count(preceding-sibling::label)=1]">
    <p>
      <xsl:apply-templates select="preceding-sibling::label[1]" mode="footnote"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template> -->

  <!-- sinon il y a un conflit avec la regle premier fils -->
  <xsl:template match="label" mode="footnote">
    <label>
      <xsl:apply-templates />
      <xsl:text> </xsl:text>
    </label>
  </xsl:template>

  <!-- table -->
  <!-- <xsl:template match="table-wrap" mode="p"> -->
  <!--   <xsl:apply-templates select="." /> -->
  <!-- </xsl:template> -->

  <xsl:template match="table-wrap">
    <div class="table-wrap">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="table">
    <table>
      <xsl:apply-templates />
    </table>
  </xsl:template>

  <xsl:template match="colgroup">
    <colgroup>
      <xsl:apply-templates />
    </colgroup>
  </xsl:template>

  <xsl:template match="col">
    <col>
      <xsl:apply-templates />
    </col>
  </xsl:template>

  <xsl:template match="thead">
    <thead>
      <xsl:apply-templates />
    </thead>
  </xsl:template>

  <xsl:template match="tbody">
    <tbody>
      <xsl:apply-templates />
    </tbody>
  </xsl:template>

  <xsl:template match="tfoot">
    <tfoot>
      <xsl:apply-templates />
    </tfoot>
  </xsl:template>

  <xsl:template match="tr">
    <tr>
      <xsl:apply-templates />
    </tr>
  </xsl:template>

  <xsl:template match="th">
    <th>
      <xsl:apply-templates select="." mode="cell-attributes" />
      <xsl:apply-templates />
    </th>
  </xsl:template>

  <xsl:template match="td">
    <td>
      <xsl:apply-templates select="." mode="cell-attributes" />
      <xsl:apply-templates />
    </td>
  </xsl:template>

  <xsl:template match="th|td" mode="cell-attributes">
    <xsl:if test="@rowspan">
      <xsl:attribute name="rowspan">
        <xsl:value-of select="@rowspan" />
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@align">
      <xsl:attribute name="align">
        <xsl:value-of select="@align" />
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@valign">
      <xsl:attribute name="valign">
        <xsl:value-of select="@valign" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- On cache le label pour ne pas qu'il apparaisse en double -->
  <xsl:template match="term-sec/label"> </xsl:template>

  <xsl:template match="tbx:termEntry">
    <div class="termentry">
      <!-- <xsl:apply-templates select="." mode="id"/> -->
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tbx:langSet">
    <dl>
      <!-- <xsl:if test="@xml:lang">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="@xml:lang" />
        </xsl:attribute>
      </xsl:if> -->
      <xsl:apply-templates select="tbx:tig" />
      <xsl:apply-templates select="tbx:definition" />
      <xsl:apply-templates select="tbx:note" />
    </dl>
  </xsl:template>

  <xsl:template match="tbx:tig">
    <dt>
      <xsl:variable name="label" select="normalize-space(ancestor::term-sec[1]/label)" />
      <xsl:variable name="nombreDePoints"
        select="string-length($label) - string-length(translate($label, '.', ''))" />

      <xsl:choose>
        <xsl:when test="$nombreDePoints = 1">
          <h3>
            <xsl:value-of select="$label" />
            <xsl:apply-templates select="tbx:term" />
          </h3>
        </xsl:when>

        <xsl:when test="$nombreDePoints = 2">
          <h4>
            <xsl:value-of select="$label" />
            <xsl:apply-templates select="tbx:term" />
          </h4>
        </xsl:when>

        <xsl:when test="$nombreDePoints = 3">
          <h5>
            <xsl:value-of select="$label" />
            <xsl:apply-templates select="tbx:term" />
          </h5>
        </xsl:when>

        <xsl:otherwise>
          <h2>
            <xsl:value-of select="$label" />
            <xsl:apply-templates select="tbx:term" />
          </h2>
        </xsl:otherwise>
      </xsl:choose>

    </dt>
  </xsl:template>

  <xsl:template match="tbx:term">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tbx:definition">
    <dd>
      <xsl:apply-templates />
    </dd>
  </xsl:template>

  <xsl:template match="tbx:note">
    <p class="Note" style="font-size: 10pt"> NOTE <xsl:if
        test="following-sibling::tbx:note or preceding-sibling::tbx:note">
        <xsl:text> </xsl:text>
        <xsl:value-of select="count(preceding-sibling::tbx:note) + 1" />
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:value-of
        select="." />
    </p>
  </xsl:template>

  <xsl:template match="term-display/title">
    <xsl:variable name="label" select="normalize-space(ancestor::term-sec[1]/label)" />
    <xsl:variable name="nombreDePoints"
      select="string-length($label) - string-length(translate($label, '.', ''))" />
    <dl>
      <dt>
        <xsl:choose>
          <xsl:when test="$nombreDePoints = 1">
            <h3>
              <xsl:value-of select="$label" />
              <xsl:text> </xsl:text>
              <strong>
                <xsl:apply-templates />
              </strong>
            </h3>
          </xsl:when>

          <xsl:when test="$nombreDePoints = 2">
            <h4>
              <xsl:value-of select="$label" />
              <xsl:text> </xsl:text>
              <strong>
                <xsl:apply-templates />
              </strong>
            </h4>
          </xsl:when>

          <xsl:when test="$nombreDePoints = 3">
            <h5>
              <xsl:value-of select="$label" />
              <xsl:text> </xsl:text>
              <strong>
                <xsl:apply-templates />
              </strong>
            </h5>
          </xsl:when>

          <xsl:otherwise>
            <h2>
              <xsl:value-of select="$label" />
              <xsl:text> </xsl:text>
              <strong>
                <xsl:apply-templates />
              </strong>
            </h2>
          </xsl:otherwise>
        </xsl:choose>
      </dt>
    </dl>
  </xsl:template>

  <!-- list -->
  <!-- <xsl:template match="list" mode="p"> -->
  <!--   <xsl:apply-templates select="."/> -->
  <!-- </xsl:template> -->

  <xsl:template match="list">
    <ul>
      <xsl:apply-templates />
    </ul>
  </xsl:template>

  <xsl:template match="list[@list-type='bullet']">
    <ul class="bullet">
      <xsl:apply-templates />
    </ul>
  </xsl:template>

  <xsl:template match="list[@list-type='simple']">
    <ul class="simple">
      <xsl:apply-templates />
    </ul>
  </xsl:template>


  <xsl:template match="list-item">
    <li>
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <!-- on masque le label s'il est le premier fils -->
  <xsl:template match="list-item/label[count(preceding-sibling::*)=0]" />

  <!-- si le premier list-item est précédé d'un label -->
  <xsl:template
    match="list-item/p[count(preceding-sibling::*)=1][count(preceding-sibling::label)=1]">
    <p>
      <xsl:apply-templates select="preceding-sibling::label[1]" mode="list-item" />
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <!-- sinon il y a un conflit avec la regle premier fils -->
  <xsl:template match="label" mode="list-item">
    <label>
      <xsl:apply-templates />
      <xsl:text> </xsl:text>
    </label>
  </xsl:template>

  <!-- std formating -->
  <xsl:template match="std">
    <xsl:apply-templates />
  </xsl:template>

  <!-- si il a std-id c'est une redite donc on n'affiche pas -->
  <xsl:template match="std[@std-id]" />

  <xsl:template match="std-ref">
    <xsl:text> </xsl:text>
    <span style="font-style: normal;">
      <xsl:attribute name="class">
        <xsl:text>std-ref </xsl:text>
        <xsl:text>std-ref-</xsl:text>
        <xsl:value-of select="@type" />
      </xsl:attribute>
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="ref-list">
    <div>
      <xsl:attribute name="class">
        <xsl:text>ref-list</xsl:text>
        <xsl:if test="@content-type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@content-type" />
        </xsl:if>
      </xsl:attribute>

      <xsl:apply-templates select="." mode="id" />
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="ref-list/ref">
    <div class="ref">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="ref-list/ref/std">
    <p style="font-style: italic ; font-weight: normal" class="normal-ref">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="ref/std/title|ref/title">

    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="ref-list/title">
    <h2 class="ref-list-title">
      <xsl:apply-templates />
    </h2>
  </xsl:template>

  <!-- Notes de bas de page -->
  <xsl:template match="fn[ancestor::ref]">


    <span class="ref_to_fn">
      <xsl:apply-templates select="label" mode="footnote" />
    </span>
    <p class="footnote">
      <xsl:apply-templates select="label" mode="footnote" />
      <!-- <xsl:apply-templates select="p"/> -->
      <em>
        <xsl:value-of select="p" />
      </em>
    </p>
    <!-- <p class="footnote">
      <xsl:apply-templates/>
    </p> -->
  </xsl:template>

  <!-- mathml -->
  <xsl:template match="mml:math">
    <div class="math-figure">
      <img alt="Formula">
        <xsl:attribute name="src">
          <xsl:text>./</xsl:text>
          <xsl:value-of select="@id" />
          <xsl:text>.png</xsl:text>
        </xsl:attribute>
      </img>
    </div>
  </xsl:template>

  <!-- Formatting -->


  <xsl:template match="bold">

    <!-- <xsl:variable name="elementPrecedent" select="../."></xsl:variable>
    <xsl:variable name="caracterePrecedent" select="substring($elementPrecedent,
    string-length($elementPrecedent))"></xsl:variable>
    <xsl:value-of select="$caracterePrecedent"/> -->
    <!-- <xsl:if test="$caracterePrecedent != ʼ">
      <xsl:text> </xsl:text>
    </xsl:if> -->
    <xsl:text> </xsl:text>
    <strong>
      <xsl:apply-templates />
    </strong>
  </xsl:template>


  <xsl:template match="sup">
    <sup>
      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <xsl:template match="sub">
    <sub>
      <xsl:apply-templates />
    </sub>
  </xsl:template>

  <xsl:template match="italic">
    <em class="italic">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="fixed-case">
    <em class="fixed-case" style="font-style: normal;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="monospace">
    <em class="monospace" style="font-style: normal; font-family: monospace;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="num">
    <em class="num" style="font-style: normal;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="overline">
    <em class="overline" style="font-style: normal;text-decoration: overline ;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="roman">
    <em class="roman" style="font-style: normal;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="sans-serif">
    <em class="sans-serif" style="font-style: normal;font-family: sans-serif;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="sc">
    <em class="sc" style="font-style: normal;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="strike">
    <em class="strike" style="font-style: normal;text-decoration: strike;">
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="underline">
    <em class="underline" style="font-style: normal; font-family: underline;">
      <xsl:apply-templates />
    </em>
  </xsl:template>


  <xsl:template match="ruby">
    <xsl:copy-of select="." />
  </xsl:template>


  <xsl:template match="abbrev">
    <abbr>
      <xsl:apply-templates select="." mode="id" />
      <xsl:apply-templates />
    </abbr>
  </xsl:template>


  <!-- empty tag -->
  <xsl:template match="label[not(.//text())]|title[not(.//text())]" />

  <!-- generic id -->
  <xsl:template match="*" mode="id">
    <xsl:if test="@id">
      <xsl:attribute name="id">
        <xsl:value-of select="@id" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <!-- helpers -->
  <xsl:template match="processing-instruction()">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="processing-instruction('nontrouve')">
    <xsl:comment>
      not found !!!
      <xsl:value-of select="."/>
      <xsl:text> </xsl:text>
    </xsl:comment>
  </xsl:template>
</xsl:stylesheet>