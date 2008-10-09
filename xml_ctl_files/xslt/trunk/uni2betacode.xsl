<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:aldt="http://treebank.alpheios.net/namespaces/aldt">

  <xsl:variable name="uni2beta-table"
    select="document('beta-uni-tables.xml')/*/aldt:beta-uni-table"/>

  <!--
      Convert Unicode to Greek betacode
      Parameters:
        $input        Unicode input string to be converted
        $upper        Whether to output base characters in upper or lower case

      Output:
        $input transformed to equivalent betacode
  -->
  <xsl:template name="uni-to-beta">
    <xsl:param name="input"/>
    <xsl:param name="upper" select="false()"/>

    <!-- Upper/lower tables -->
    <xsl:variable name="beta-uppers">ABCDEFGHIKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:variable name="beta-lowers">abcdefghiklmnopqrstuvwxyz</xsl:variable>

    <!-- if there's anything to process -->
    <xsl:if test="string-length($input) > 0">
      <xsl:variable name="head" select="substring($input, 1, 1)"/>
      <xsl:variable name="beta">
        <!-- first try to lookup precomposed character -->
        <xsl:variable name="temp">
          <xsl:apply-templates select="$uni2beta-table">
            <xsl:with-param name="key" select="$head"/>
            <xsl:with-param name="precomposed" select="true()"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($temp) > 0">
            <xsl:value-of select="$temp"/>
          </xsl:when>
          <!-- if not precomposed, it might be a standalone combining char -->
          <xsl:otherwise>
            <xsl:apply-templates select="$uni2beta-table">
              <xsl:with-param name="key" select="$head"/>
              <xsl:with-param name="precomposed" select="false()"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <!-- if we found anything in lookup, use it -->
        <!-- Strings in lookup table are base character -->
        <!-- plus optional asterisk plus optional diacritics -->
        <xsl:when test="string-length($beta) > 0">
          <!-- get base character in appropriate case -->
          <xsl:variable name="base">
            <xsl:choose>
              <xsl:when test="$upper">
                <xsl:value-of
                  select="translate(substring($beta, 1, 1), $beta-lowers, $beta-uppers)"
                />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="substring($beta, 1, 1)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:choose>
            <!-- if capital letter -->
            <xsl:when test="substring($beta, 2, 1) = '*'">
              <!-- output '*'+base+diacritics -->
              <xsl:value-of select="'*'"/>
              <xsl:value-of select="$base"/>
              <xsl:value-of select="substring($beta, 3)"/>
            </xsl:when>

            <!-- if lower letter -->
            <xsl:otherwise>
              <!-- output base+diacritics -->
              <xsl:value-of select="$base"/>
              <xsl:value-of select="substring($beta, 2)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- otherwise, use the original character -->
        <xsl:otherwise>
          <xsl:value-of select="$head"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- process remainder of input -->
      <xsl:call-template name="uni-to-beta">
        <xsl:with-param name="input" select="substring($input, 2)"/>
        <xsl:with-param name="upper" select="$upper"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
    Convert unicode to betacode
    Parameters:
    $key          Unicode character to look up
    $precomposed  Whether to look up in precomposed or decomposed Unicode
  -->
  <xsl:key name="unic-beta-lookup" match="aldt:beta-uni-table/aldt:entry"
    use="aldt:unic"/>
  <xsl:key name="unid-beta-lookup" match="aldt:beta-uni-table/aldt:entry"
    use="aldt:unid"/>
  <xsl:template match="aldt:beta-uni-table">
    <xsl:param name="key"/>
    <xsl:param name="precomposed"/>
    
    <xsl:if test="$precomposed">
      <xsl:value-of select="key('unic-beta-lookup', $key)/aldt:beta/text()"/>
    </xsl:if>
    <xsl:if test="not($precomposed)">
      <xsl:value-of select="key('unid-beta-lookup', $key)/aldt:beta/text()"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
