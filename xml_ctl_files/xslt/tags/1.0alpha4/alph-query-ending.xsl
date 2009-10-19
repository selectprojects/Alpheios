<?xml version="1.0" encoding="UTF-8"?>
<!-- produces table cells to hold the endings in inflection ending set, grouped by ending
   type (e.g. regular, irregular). Each type gets its own cell.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="alph-infl-extras.xsl"/>
  <xsl:import href="beta-uni-util.xsl"/>
  <xsl:import href="uni2ascii.xsl"/>

  <xsl:template name="ending-cell">
    <xsl:param name="a_inflEndings"/>
    <xsl:param name="a_selectedEndings"/>
    <xsl:param name="a_selected"/>
    <xsl:param name="a_translitEndingTableMatch" />
    <xsl:param name="a_dedupeBy"/>
    <xsl:param name="a_showOnlyMatches"/>
    <xsl:param name="a_matchForm"/>

    <xsl:element name="td"><!-- start new cell -->
      <xsl:attribute name="class">ending-group</xsl:attribute>
      <xsl:if test="$a_inflEndings/@pers">
        <xsl:attribute name="alph-pers">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@pers,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@gend">
        <xsl:attribute name="alph-gend">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@gend,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@num">
        <xsl:attribute name="alph-num">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@num,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@case">
        <xsl:attribute name="alph-case">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@case,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@voice">
        <xsl:attribute name="alph-voice">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@voice,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@tense">
        <xsl:attribute name="alph-tense">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@tense,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@mood">
        <xsl:attribute name="alph-mood">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@mood,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@conj">
        <xsl:attribute name="alph-conj">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@conj,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$a_inflEndings/@hdwd">
        <xsl:attribute name="alph-hdwd">
          <xsl:value-of select="concat('|', translate($a_inflEndings/@hdwd,' ','|'), '|')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:variable name="cellgroup" select="$a_inflEndings/infl-ending"/>
      <xsl:if test="count($cellgroup) = 0">
        <span class="emptycell"/>
      </xsl:if>
    <xsl:for-each select="$cellgroup">
      <!-- if we have primary endings identified, then include only the primary endings, otherwise
         include them all -->
      <xsl:variable name="hasPrimary" select="count(../infl-ending[contains(@type,'primary')])"/>
      <xsl:if test="($hasPrimary &gt; 0 and contains(@type,'primary')) or not($hasPrimary)">
        <xsl:variable name="strippedEnding">
          <xsl:choose>
            <!-- if requested, transliterate the ending in the table for matching -->
            <xsl:when test="$a_translitEndingTableMatch">
              <xsl:call-template name="uni-to-ascii">
                <xsl:with-param name="a_in" select="."/>
              </xsl:call-template>
            </xsl:when>
            <!-- otherwise use the ending as-is -->
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- underscore and hyphen in the declension tables match on no ending -->
        <xsl:variable name="endingMatch">
          <xsl:choose>
            <xsl:when test="$strippedEnding = '_' or $strippedEnding = '-'">_</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($strippedEnding)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="notfirst">
          <xsl:if test="position() &gt; 1">notfirst</xsl:if>
        </xsl:variable>
        <xsl:variable name="thisCase" select="../@case"/>
        <xsl:variable name="thisNum" select="../@num"/>
        <xsl:variable name="thisGend" select="../@gend"/>
        <xsl:element name="span">
          <xsl:attribute name="class">
            <xsl:value-of select="concat('ending ', @type, ' ',' ', $notfirst)"/>
          </xsl:attribute>
          <xsl:attribute name="stem-class">
            <xsl:value-of select="@stem-class"/>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
