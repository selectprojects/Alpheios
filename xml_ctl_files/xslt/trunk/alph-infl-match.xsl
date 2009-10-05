<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="beta-uni-util.xsl"/>
  <xsl:import href="uni2ascii.xsl"/>
  <xsl:import href="normalize-greek.xsl"/>

  <xsl:template name="check-infl-sets">
    <xsl:param name="a_selectedEndings"/>
    <xsl:param name="a_currentData"/>
    <xsl:param name="a_matchPofs"/>
    <xsl:param name="a_normalizeGreek"/>
    <xsl:param name="a_matchForm"/>
    <xsl:param name="a_inflConstraint"/>
    <xsl:variable name="matches">
      <xsl:for-each select="$a_selectedEndings//div[@class='alph-infl-set' and
        (../div[contains(@class,'alph-dict')]//span[(contains(@class,'alph-pofs')) and (@context = $a_matchPofs)])
        or
        (span[(contains(@class,'alph-pofs') and @context = $a_matchPofs)])
        ]
        ">
        <xsl:variable name="matchText">
          <xsl:choose>
            <xsl:when test="$a_matchForm != ''">
              <!-- match the originally selected form
                 it must be the form from context of the word, which
                 is the user's selected form, as the context on
                 the inflection set is the stem+suffix which may not
                 be exactly the same (See Bug 152)-->
              <xsl:value-of select="$a_matchForm"/>
            </xsl:when>
            <!-- empty suffixes are matched with _ -->
            <xsl:when test="span[contains(@class,'alph-term')]/span[contains(@class,'alph-suff') and not(text())]">_</xsl:when>
            <xsl:otherwise><!-- match the ending -->
              <xsl:value-of select="span[contains(@class,'alph-term')]/span[contains(@class,'alph-suff')]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="normalizedMatchText">
          <xsl:choose>
            <xsl:when test="$a_normalizeGreek and not($matchText = '_')">
              <xsl:call-template name="normalize-greek">
                <xsl:with-param name="a_in" select="$matchText"/>
                <xsl:with-param name="a_strip">/\^_=</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$matchText"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="possible">
          <xsl:for-each select="div[@class='alph-infl']">
            <xsl:variable name="failInflConstraint">
              <xsl:call-template name="check-infl-constraint">
                <xsl:with-param name="a_infl" select="."/>
                <xsl:with-param name="a_constraintData"
                  select="$a_inflConstraint"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="not($failInflConstraint = '1')">
            <xsl:call-template name="find-infl-match">
              <xsl:with-param name="a_currentData" select="$a_currentData"/>
              <xsl:with-param name="a_filteredData" select="(.)"/>
              <xsl:with-param name="a_matchPofs" select="$a_matchPofs"/>
            </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$possible &gt; 0">,<xsl:value-of select="$normalizedMatchText"/>,</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="$matches"/>
  </xsl:template>

  <xsl:template name="find-infl-match">
    <xsl:param name="a_currentData"/>
    <xsl:param name="a_filteredData"/>
    <xsl:param name="a_matchPofs"/>
    <xsl:param name="a_attPos" select="0"/>

    <xsl:variable name="numAtts" select="count($a_currentData/@*)"/>
    <xsl:choose>
      <!-- if we don't have any attributes to check on the current cell
        then just skip it
      -->
      <xsl:when test="$numAtts = 0">0</xsl:when>
      <xsl:when test="$a_currentData/@case">
        <!-- handle attributes with case non-recursively because we need
           to match case number and gender together
           only require matches on attributes which are actually
           in the inflection table
        -->
        <xsl:variable name="matchCase">
          <xsl:if test="$a_currentData/@case">
            <xsl:value-of select="
              concat(
              '|',
              translate($a_currentData/@case,' ','|'),
              '|')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="matchNum">
          <xsl:if test="$a_currentData/@num">
            <xsl:value-of select="
              concat(
              '|',
            translate($a_currentData/@num,' ','|'),
            '|')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="matchGend">
          <xsl:if test="$a_currentData/@gend">
            <xsl:value-of select="
              concat(
              '|',
              translate($a_currentData/@gend,' ','|'),
              '|')"/>
              <!-- make sure that we match the 'common' gender for
                 endings which are either masculine or feminine
              -->
            <xsl:if test="contains($a_currentData/@gend, 'masculine') or
              contains($a_currentData/@gend,'feminine')">|common|
            </xsl:if>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="matchDecl">
          <xsl:if test="$a_currentData/@decl">
            <xsl:value-of select="
              concat(
              '|',
              translate($a_currentData/@decl,' ','|'),
              '|')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="matchVoice">
          <xsl:if test="$a_currentData/@voice">
            <xsl:value-of select="
              concat(
              '|',
              translate($a_currentData/@voice,' ','|'),
              '|')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="matchTense">
          <xsl:if test="$a_currentData/@tense">
            <xsl:value-of select="
              concat(
              '|',
              translate($a_currentData/@tense,' ','|'),
              '|')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="not($a_currentData/@decl) or
              ($a_filteredData/../..//span[contains(@class,'alph-decl')
              and (contains($matchDecl,
                 concat('|',substring-before(@context,'_'),'|'))
                 or
                 contains($matchDecl,
                 concat('|',@context,'|'))
              )])
              or
              ($a_filteredData//span[contains(@class,'alph-decl')
              and (contains($matchDecl,
              concat('|',substring-before(@context,'_'),'|'))
              or
              contains($matchDecl,
              concat('|',@context,'|')))])">
            <xsl:value-of select="count($a_filteredData//span[contains(@class,'alph-case')
              and ($matchCase = '' or contains($matchCase,concat('|',substring-before(@context,'-'),'|')))
              and (@alph-pofs = $a_matchPofs)
              and ($matchGend = '' or
                contains($matchGend,concat('|',@alph-gend,'|'))
                or @alph-gend = 'all')
              and ($matchNum = '' or contains($matchNum,concat('|',@alph-num,'|')))
              and ($matchVoice = '' or (preceding-sibling::span[contains(@class,'alph-voice') and
              contains($matchVoice,concat('|',text(),'|'))]))
              and ($matchTense = '' or (preceding-sibling::span[contains(@class,'alph-tense')and
              contains($matchTense,concat('|',@context,'|'))]))
              ])"/>
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$a_attPos = $numAtts">
        <!-- if we have tested all the possible attributes return the match count-->
        <xsl:value-of select="count($a_filteredData)"/>
      </xsl:when>
      <xsl:when test="($a_attPos &lt; $numAtts) and $a_filteredData">
        <!-- only try match if current data element has the attribute -->
        <xsl:for-each select="$a_currentData/@*">
          <xsl:if test="position() = $a_attPos + 1">
            <xsl:variable name="attName" select="name()"/>
            <!-- should we skip this attribute? -->
            <xsl:variable name="skipAtt">
              <xsl:call-template name="check-att">
                <xsl:with-param name="a_attName" select="$attName"/>
                <xsl:with-param name="a_data" select="$a_currentData"/>
              </xsl:call-template>
            </xsl:variable>
            <!-- translate spaces to pipes in the attribute value so that we can
               isolate each value
            -->
            <xsl:variable name="attValue">
              <xsl:value-of select=
                "concat(
                '|',
                translate($a_currentData/@*[local-name(.)=$attName],' ','|'),
                '|')"/>
            </xsl:variable>
            <xsl:variable name="className">
              <xsl:value-of select="concat('alph-',$attName)"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$skipAtt = '1'">
                <!-- just advance the counter for the ones we're skipping -->
                <xsl:call-template name="find-infl-match">
                  <xsl:with-param name="a_currentData" select="$a_currentData"/>
                  <xsl:with-param name="a_filteredData"
                    select="$a_filteredData"/>
                  <xsl:with-param name="a_attPos" select="$a_attPos+1"/>
                </xsl:call-template>
              </xsl:when>
              <!-- conj is on the inflection set's sibling alph-dict entry -->
              <xsl:when test="$attName = 'conj'">
                <!-- test on conj assumes morphology only ever outputs
                  a single conj for a given form, but that inflection data
                  attribute may be multi-valued -->
                <xsl:variable name="latestData"
                  select="$a_filteredData[ancestor::div[@class='alph-entry']//
                      span[contains(@class,$className) and
                      contains(concat('|',$attValue,'|'),concat('|',@context,'|'))]]"/>
                <xsl:call-template name="find-infl-match">
                  <xsl:with-param name="a_currentData" select="$a_currentData"/>
                  <xsl:with-param name="a_filteredData"
                    select="$latestData"/>
                  <xsl:with-param name="a_attPos" select="$a_attPos+1"/>
                </xsl:call-template>
              </xsl:when>

              <!-- stemtype is on the infl-set -->
              <xsl:when test="$attName = 'stemtype'">
                <!-- test on stemtype assumes morpheus output only ever outputs
                   a single stemtype for a given form, but that inflection data
                   stemtype attribute may be multi-valued -->
                <xsl:variable name="latestData"
                  select="$a_filteredData[ancestor::div[@class='alph-infl-set']//span
                    [contains(@class,$className) and
                      contains(concat('|',$attValue,'|'),concat('|',@context,'|'))

                     ]]"/>
                <xsl:call-template name="find-infl-match">
                  <xsl:with-param name="a_currentData" select="$a_currentData"/>
                  <xsl:with-param name="a_filteredData"
                    select="$latestData"/>
                  <xsl:with-param name="a_attPos" select="$a_attPos+1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="latestData"
                  select="$a_filteredData[(
                  (contains($attValue,concat('|',span[contains(@class,$className)]/text(),'|')))
                  or
                  (contains($attValue,concat('|',span[contains(@class,$className)]/@context,'|')))
                  )]"/>
                <xsl:call-template name="find-infl-match">
                  <xsl:with-param name="a_currentData" select="$a_currentData"/>
                  <xsl:with-param name="a_filteredData"
                    select="$latestData"/>
                  <xsl:with-param name="a_attPos" select="$a_attPos+1"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- templates which can be overridden for language and pofs to control matching
     behavior
  -->
  <!-- template to filter matching to specific attributes -->
  <xsl:template name="check-att">
    <xsl:param name="a_attName"/>
    <xsl:param name="a_data"/>
  </xsl:template>

  <!-- template to filter matching to specific inflection sets -->
  <xsl:template name="check-infl-constraint">
    <xsl:param name="a_infl"/>
    <xsl:param name="a_constraintData"/>
  </xsl:template>
</xsl:stylesheet>

