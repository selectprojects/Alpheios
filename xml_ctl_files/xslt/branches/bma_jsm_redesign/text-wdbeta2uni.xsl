<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <!--
    Copyright 2008-2009 Cantus Foundation
    http://alpheios.net
    
    This file is part of Alpheios.
    
    Alpheios is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    Alpheios is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
  -->

  <!--
    Stylesheet to convert <wd> elements in betacode to unicode
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
            <xsl:with-param name="is-greek" select="local-name() = 'wd'"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>

      <!-- if comment -->
      <xsl:when test="self::comment()">
        <xsl:copy/>
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
    <!-- ignore TEI attributes, copy the rest -->
    <xsl:if
      test="($name != 'TEIform') and
                    ($name != 'opt') and
                    ($name != 'default')">
      <xsl:copy/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
