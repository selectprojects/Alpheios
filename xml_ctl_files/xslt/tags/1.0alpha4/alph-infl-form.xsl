<?xml version="1.0" encoding="UTF-8"?>
<!-- produces table cells to hold the forms in inflection form set -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="alph-infl-extras.xsl"/>
  <xsl:import href="beta-uni-util.xsl"/>
  <xsl:import href="uni2ascii.xsl"/>

  <xsl:template name="ending-cell">
    <xsl:param name="a_inflEndings"/>
    <xsl:param name="a_selectedEndings"/>
    <xsl:param name="a_selected"/>
    <xsl:param name="a_translitEndingTableMatch" />
    <xsl:param name="a_stripGreekVowelLength" />
    <xsl:param name="a_showOnlyMatches"/>
    <xsl:param name="a_context"/>

    <td class="ending-group"> <!-- start new cell -->
      <xsl:if test="count($a_inflEndings/infl-form) = 0">
        <span class="emptycell"
          context="{translate($a_context,' ','_')}">&#160;</span>
      </xsl:if>
      <xsl:for-each select="$a_inflEndings/infl-form">
        <xsl:variable name="strippedEnding">
          <xsl:choose>
          <!-- if requested, transliterate the ending in the table for matching -->
            <xsl:when test="$a_translitEndingTableMatch">
              <xsl:call-template name="uni-to-ascii">
                <xsl:with-param name="a_in" select="."/>
              </xsl:call-template>
            </xsl:when>
            <!-- if we're not transliterating, we may need to
              strip greek vowels -->
            <xsl:when test="$a_stripGreekVowelLength = true()">
              <xsl:call-template name="uni-strip">
                <xsl:with-param name="a_in" select="."/>
                <xsl:with-param name="a_stripVowels" select="true()"/>
                <xsl:with-param name="a_stripCaps" select="false()"/>
              </xsl:call-template>
            </xsl:when>
            <!-- otherwise use the ending as-is -->
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="selectedClass">
          <xsl:choose>
          <!-- if this inflection-set is selected by it's attributes AND
             the ending matches the one supplied in the template params
             then add a 'selected' class to the data element -->
            <xsl:when test="contains($a_selected,concat(',',$strippedEnding,','))">selected</xsl:when>
              <!-- otherwise add the class 'matched' to indicate that the ending matches but
                 the form attributes don't -->
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$a_stripGreekVowelLength = true()
                        and count
                        ($a_selectedEndings//span
                        [@class='alph-suff' and
                        translate(text(),
                        $s_uniWithLength,
                        $s_uniWithoutLength)
                        = $strippedEnding]
                        ) &gt; 0">matched</xsl:when>
                <xsl:when test="$a_stripGreekVowelLength = false()
                        and count
                        ($a_selectedEndings//span
                        [@class='alph-suff' and
                        text() = $strippedEnding]
                        ) &gt; 0">matched</xsl:when>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$a_showOnlyMatches and $selectedClass=''">
            <span class="skipending">&#160;</span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="notfirst">
              <xsl:if test="position() &gt; 1">notfirst</xsl:if>
            </xsl:variable>
            <span class="ending primary {$selectedClass} {$notfirst}"
                stem-class="{@stem-class}"
                context="{translate($a_context,' ','_')}">
              <xsl:value-of select="."/>
            </span>
            <xsl:call-template name="add-dialect">
              <xsl:with-param name="a_item" select="."/>
            </xsl:call-template>
            <xsl:call-template name="add-footnote">
              <xsl:with-param name="a_item" select="."/>
            </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </td>
  </xsl:template>
</xsl:stylesheet>
