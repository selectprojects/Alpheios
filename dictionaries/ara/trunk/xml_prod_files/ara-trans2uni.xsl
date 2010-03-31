<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--
  Copyright 2008-2010 Cantus Foundation
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
    Stylesheet to convert Buckwalter Arabic transliteration and
    betacode Greek translation in dictionary to unicode
  -->

  <xsl:include href="ara-uni-util.xsl"/>
  <xsl:include href="beta2unicode.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- handle nodes -->
  <xsl:template match="node()">
    <xsl:param name="a_lang" select="''"/>

    <xsl:choose>
      <!-- if it has a name, it's an element -->
      <xsl:when test="local-name()">
        <!-- copy node -->
        <xsl:copy>
          <!-- call recursively, specifying whether contains coded content -->
          <xsl:apply-templates select="@*|node()">
            <xsl:with-param name="a_lang">
              <xsl:if test="./@lang = 'ar'">ar</xsl:if>
              <xsl:if test="./@lang = 'greek'">grc</xsl:if>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>

      <!-- if no name, it's text -->
      <xsl:otherwise>
        <xsl:choose>
          <!-- if it's buckwalter, convert it -->
          <xsl:when test="$a_lang = 'ar'">
            <xsl:call-template name="ara-buckwalter-to-uni">
              <xsl:with-param name="a_in" select="."/>
              <xsl:with-param name="a_depersify" select="true()"/>
            </xsl:call-template>
          </xsl:when>
          <!-- if it's betacode, convert it -->
          <xsl:when test="$a_lang = 'grc'">
            <xsl:call-template name="beta-to-uni">
              <xsl:with-param name="a_in" select="."/>
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
    <xsl:variable name="pname" select="local-name(..)"/>
    <xsl:choose>
      <!-- if entry key -->
      <xsl:when test="$name = 'key'">
        <xsl:attribute name="key">
          <!-- convert to unicode -->
          <xsl:call-template name="ara-buckwalter-to-uni">
            <xsl:with-param name="a_in" select="."/>
            <xsl:with-param name="a_depersify" select="true()"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:when>
      <!-- if letter or root -->
      <xsl:when
        test="    ($name = 'n')
              and (($pname = 'div1') or ($pname = 'div2'))
              and ((../@type = 'alphabetic letter') or (../@type = 'root'))">
        <xsl:attribute name="n">
          <!-- convert to unicode -->
          <xsl:call-template name="ara-buckwalter-to-uni">
            <xsl:with-param name="a_in" select="."/>
            <xsl:with-param name="a_depersify" select="true()"/>
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
