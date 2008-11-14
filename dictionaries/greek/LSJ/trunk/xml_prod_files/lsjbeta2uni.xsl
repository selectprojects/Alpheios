<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <!--
    Stylesheet to convert betacode in LSJ to unicode
  -->

  <xsl:include href="beta2unicode.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- handle nodes -->
  <xsl:template match="node()">
    <xsl:param name="is-greek" select="false()"/>

    <xsl:choose>
      <!-- if it has a name, it's an element -->
      <xsl:when test="local-name()">
        <!-- copy node -->
        <xsl:copy>
          <!-- call recursively, specifying whether contains betacode -->
          <xsl:apply-templates select="@*|node()">
            <xsl:with-param name="is-greek" select="./@lang = 'greek'"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>

      <!-- if no name, it's text -->
      <xsl:otherwise>
        <xsl:choose>
          <!-- if it's betacode, convert it -->
          <xsl:when test="$is-greek">
            <xsl:call-template name="beta-to-uni">
              <xsl:with-param name="input" select="."/>
            </xsl:call-template>
          </xsl:when>
          <!-- otherwise, leave it alone -->
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- handle attributes -->
  <xsl:template match="@*">
    <xsl:variable name="name" select="local-name(.)"/>
    <xsl:choose>
      <!-- if entry key -->
      <xsl:when test="$name = 'key'">
        <xsl:attribute name="key">
          <!-- convert to unicode -->
          <xsl:call-template name="beta-to-uni">
            <xsl:with-param name="input" select="."/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:when>
      <!-- ignore TEI attributes, copy the rest -->
      <xsl:when
        test="($name != 'TEIform') and
                    ($name != 'opt') and
                    ($name != 'default')">
        <xsl:copy/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
