<?xml version="1.0" encoding="UTF-8"?>
<!-- produces table cells to hold the endings in inflection ending set, grouped by ending
   type (e.g. regular, irregular). Each type gets its own cell.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="alph-infl-extras.xsl"/>
  <xsl:import href="uni2ascii.xsl"/>
  <xsl:template name="ending-cell">
    <xsl:param name="a_inflEndings"/>
    <xsl:param name="a_selectedEndings"/>
    <xsl:param name="a_selected"/>
    <xsl:param name="a_translitEndingTableMatch" />
    <xsl:param name="a_normalizeGreek"/>
    <xsl:param name="a_dedupeBy"/>
    <xsl:param name="a_showOnlyMatches"/>
    <xsl:param name="a_groupBy"/>
    <xsl:param name="a_noGrouping" select="false()"/>
    <xsl:param name="a_matchForm"/>
    <xsl:param name="a_textForMatch"/>

    <xsl:variable name="groupAtt">
      <xsl:choose>
        <xsl:when test="$a_groupBy">
          <xsl:value-of select="$a_groupBy"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'type'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="endingTypes"
                  select="//order-item[@attname=$groupAtt]"/>
    <xsl:choose>
      <xsl:when test="$a_noGrouping">
        <td class="ending-group">
          <xsl:for-each select="$a_inflEndings/infl-ending">
            <xsl:call-template name="print-inflection">
              <xsl:with-param name="inflection" select="."/>
              <xsl:with-param name="a_selected" select="$a_selected"/>
              <xsl:with-param name="a_selectedEndings"
                              select="$a_selectedEndings"/>
              <xsl:with-param name="a_translitEndingTableMatch"
                              select="$a_translitEndingTableMatch"/>
              <xsl:with-param name="a_normalizeGreek"
                              select="$a_normalizeGreek"/>
              <xsl:with-param name="a_dedupeBy" select="$a_dedupeBy"/>
              <xsl:with-param name="a_showOnlyMatches"
                              select="$a_showOnlyMatches"/>
              <xsl:with-param name="a_groupBy" select="$a_groupBy"/>
              <xsl:with-param name="a_matchForm" select="$a_matchForm"/>
              <xsl:with-param name="a_textForMatch" select="$a_textForMatch"/>
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </xsl:when>
      <xsl:otherwise>
        <!-- group by type -->
        <xsl:for-each select="$endingTypes">
          <xsl:sort
            select="/infl-data/order-table/order-item[@attname=$groupAtt
            and text()=current()]/@order"/>
          <xsl:if test="generate-id(.) = generate-id($endingTypes[.=current()])">
            <xsl:variable name="lasttype" select="."/>
            <td class="ending-group {$lasttype}"> <!-- start new cell -->
              <xsl:variable name="cellgroup"
                select="$a_inflEndings/infl-ending/@*[local-name(.)=$groupAtt
                and contains(concat(' ',(.),' '), concat(' ',$lasttype,' '))]/.."/>
              <!-- print an empty cell if there are no endings of this type -->
              <xsl:if test="count($cellgroup) = 0"><span class="emptycell">&#160;</span></xsl:if>
              <xsl:for-each select="$cellgroup">
                <xsl:call-template name="print-inflection">
                  <xsl:with-param name="a_inflection" select="."/>
                  <xsl:with-param name="a_selected" select="$a_selected"/>
                  <xsl:with-param name="a_selectedEndings"
                                  select="$a_selectedEndings"/>
                  <xsl:with-param name="a_translitEndingTableMatch"
                                  select="$a_translitEndingTableMatch"/>
                  <xsl:with-param name="a_normalizeGreek"
                                  select="$a_normalizeGreek"/>
                  <xsl:with-param name="a_dedupeBy" select="$a_dedupeBy"/>
                  <xsl:with-param name="a_showOnlyMatches"
                                  select="$a_showOnlyMatches"/>
                  <xsl:with-param name="a_groupBy" select="$a_groupBy"/>
                  <xsl:with-param name="a_matchForm" select="$a_matchForm"/>
                  <xsl:with-param name="a_textForMatch"
                                  select="$a_textForMatch"/>
                </xsl:call-template>
              </xsl:for-each>
            </td>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="print-inflection">
    <xsl:param name="a_inflection"/>
    <xsl:param name="a_selected"/>
    <xsl:param name="a_selectedEndings"/>
    <xsl:param name="a_translitEndingTableMatch" />
    <xsl:param name="a_normalizeGreek"/>
    <xsl:param name="a_dedupeBy"/>
    <xsl:param name="a_showOnlyMatches"/>
    <xsl:param name="a_groupBy"/>
    <xsl:param name="a_matchForm"/>
    <xsl:param name="a_textForMatch"/>
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
          <xsl:choose>
            <xsl:when test="$a_normalizeGreek">
              <xsl:call-template name="normalize-greek">
                <xsl:with-param name="a_in"
                                select="normalize-space($strippedEnding)"/>
                <xsl:with-param name="a_strip">\/^_=</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($strippedEnding)"/>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="selectedClass">
      <xsl:choose>
        <!-- if this inflection-set is selected by its attributes AND
          a) the ending matches the one supplied in the template params
          OR
          b) the template params didn't identify the ending
          then add a 'selected' class to the data element -->
        <xsl:when test="contains($a_selected,concat(',',$endingMatch,','))
          or ($a_selected != '' and not($a_selectedEndings//span[@class='alph-term']))">selected</xsl:when>
        <!-- otherwise add the class 'matched' to indicate that the ending matches but
          the form attributes don't -->
        <xsl:otherwise>
          <xsl:if test="contains($a_textForMatch,concat('|',$endingMatch,'|'))">matched</xsl:if>
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
        <xsl:variable name="thisCase" select="../@case"/>
        <xsl:variable name="thisNum" select="../@num"/>
        <xsl:variable name="thisGend" select="../@gend"/>
        <xsl:variable name='duplicate'>
          <xsl:if test="$a_dedupeBy='case-num-gend'
            and ../preceding-sibling::infl-ending-set[@case=$thisCase and
            @gend = $thisGend and @num = $thisNum]/infl-ending/text() = .">duplicate</xsl:if>
        </xsl:variable>
        <span class="ending {@type} {$selectedClass} {$notfirst} {$duplicate}"
          stem-class="{@stem-class}">
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
  </xsl:template>

</xsl:stylesheet>
