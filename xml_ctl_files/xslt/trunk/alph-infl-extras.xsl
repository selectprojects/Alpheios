<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:exsl="http://exslt.org/common"
  version="1.0">
  <xsl:import href="beta-uni-util.xsl"/>
  <xsl:import href="normalize-greek.xsl"/>

  <xsl:template name="make-ref-link">
    <xsl:param name="a_target"/>
    <xsl:if test="$a_target">
      <xsl:variable name="linkElem">
        <xsl:element name="reflink">
          <xsl:attribute name="xmlns:xlink">http://www.w3.org/1999/xlink</xsl:attribute>
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="substring-before($a_target,'|')"/>
          </xsl:attribute>
          <xsl:value-of select="substring-after($a_target,'|')"/>
        </xsl:element>
      </xsl:variable>
      <xsl:apply-templates select="exsl:node-set($linkElem)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="reflink">
    <a href="{@xlink:href}" class="alph-reflink"><xsl:value-of select="."/></a>
  </xsl:template>

  <xsl:template name="add-footnote">
    <xsl:param name="a_item"/>
    <xsl:if test="$a_item/@footnote">
      <xsl:call-template name="footnote-tokens">
        <xsl:with-param name="a_list" select="$a_item/@footnote"/>
        <xsl:with-param name="a_delimiter" select="' '"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add-dialect">
    <xsl:param name="a_item"/>
    <xsl:if test="$a_item/@dialects">
      <a href="#dialect" class="footnote">D</a>
      <span class="footnote-text"><xsl:value-of select="$a_item/@dialects"/></span>
      <xsl:if test="$a_item/@footnote">
        <span class="footnote-delimiter">,</span>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="footnote-tokens">
    <xsl:param name="a_list" />
    <xsl:param name="a_delimiter" />
    <xsl:variable name="newlist">
      <xsl:choose>
        <xsl:when test="contains($a_list, $a_delimiter)">
          <xsl:value-of select="normalize-space($a_list)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(normalize-space($a_list), $a_delimiter)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="first"
                  select="substring-before($newlist, $a_delimiter)" />
    <xsl:variable name="remaining"
                  select="substring-after($newlist, $a_delimiter)" />
    <xsl:variable name="num" select="substring-after($first,'-')"/>
    <a href="#{$first}" class="footnote"><xsl:value-of select="$num"/></a>
    <span class="footnote-text"><xsl:apply-templates select="key('s_footnotes',$first)"/></span>
    <xsl:if test="$remaining">
      <span class="footnote-delimiter">,</span>
      <xsl:call-template name="footnote-tokens">
        <xsl:with-param name="a_list" select="$remaining" />
        <xsl:with-param name="a_delimiter">
          <xsl:value-of select="$a_delimiter"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ul">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- template to produce header for stem header row -->
  <xsl:template name="stem-header">
    <xsl:param name="a_header"/>
    <xsl:if test="$a_header='decl' or $a_header='conj'">
      <br/><span class="header-text">stem</span>
    </xsl:if>
  </xsl:template>

  <!-- template to produce data for stem header row -->
  <xsl:template name="stem-data" match="order-item[@attname='decl' or @attname='conj']">
    <xsl:call-template name="add-footnote">
      <xsl:with-param name="a_item" select="."/>
    </xsl:call-template>
    <br/>
    <xsl:variable name="thistext" select="text()"/>
    <xsl:apply-templates select="/infl-data/stem-table/stem[@decl=$thistext or @conj=$thistext]"/>
  </xsl:template>

  <xsl:template name="no-sub" match="order-item">
    <xsl:call-template name="add-footnote">
      <xsl:with-param name="a_item" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="stem">
    <span class="stem"><xsl:value-of select="text()"/></span>
    <xsl:if test="stem-class">
      <ul class="stem-class-block">
        <li class="stem-class-toggle header-text">stem-classes</li>
        <ul class="stem-classes">
          <xsl:apply-templates select="stem-class"/>
        </ul>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="stem-class">
    <li id="{@id}" class="{@type}"><span class="stem-class-desc"><xsl:apply-templates select="reflink"/></span></li>
  </xsl:template>

  <!-- caption containing the selected form and the stem/suffixes from the selected
     endings parameter
  -->
  <xsl:template name="form-caption">
    <xsl:param name="a_selectedEndings"/>
    <xsl:param name="a_form"/>
    <xsl:param name="a_hasData"/>
    <div class="alph-infl-form">
      <xsl:value-of select="$a_form"/>
      <xsl:if test="$a_selectedEndings//*[@class='alph-term']">
        (
        <xsl:for-each select="$a_selectedEndings//*[@class='alph-term']">
          <xsl:if test="position() &gt; 1">
            ,
          </xsl:if>
          <div class="alph-infl-term"><xsl:copy-of select="current()"/></div>
        </xsl:for-each>
        )

      </xsl:if>
      <xsl:if test="$a_hasData and $a_selectedEndings and ($e_normalizeGreek or $e_translitEndingTableMatch)">
        <div class="alpheios-hint">Highlighted matches may ignore some vowel accents.</div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- pull the text from the selected endings out for matching -->
  <xsl:template name="text-for-match">
    <xsl:param name="a_selectedEndings"/>
    <xsl:param name="a_normalizeGreek"/>
    <xsl:param name="a_matchForm"/>
    <xsl:for-each select="$a_selectedEndings//*[contains(@class,'alph-term')]">
      <xsl:variable name="toStrip">
        <xsl:choose>
          <xsl:when test="$a_matchForm != ''"><xsl:value-of select="$a_matchForm"/></xsl:when>
           <xsl:when test="*[contains(@class,'alph-suff')]/text() != ''">
             <xsl:value-of select="*[contains(@class,'alph-suff')]/text()"/>
           </xsl:when>
           <xsl:otherwise>_</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text>|</xsl:text>
      <xsl:choose>
        <xsl:when test="$a_normalizeGreek and not($toStrip='_')">
          <xsl:call-template name="normalize-greek">
            <xsl:with-param name="a_in" select="normalize-space($toStrip)"/>
            <xsl:with-param name="a_strip">/\^_=</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space($toStrip)"/></xsl:otherwise>
      </xsl:choose>
      <xsl:text>|</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="disclaimer">
    <div id="alph-infl-disclaimer" class="alpheios-hint">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
