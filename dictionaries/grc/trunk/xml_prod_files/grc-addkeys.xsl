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
    Stylesheet to convert betacode in lexicons to unicode
    Has been used for LSJ, Middle Liddell, Autenrieth
    Note: Due to XSLT data model, entity references, other than standard
    built-ins like &lt;, are expanded during input and not preserved.
  -->

  <xsl:include href="beta2unicode.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- handle nodes -->
  <xsl:template match="node()">
    <xsl:choose>
      <!-- if it has a name, it's an element -->
      <xsl:when test="local-name()">
        <!-- copy node -->
        <xsl:copy>
          <!-- if lemma, add stripped keys -->
          <xsl:if test="local-name() = 'lemma'">
            <!-- key1 = lemma with vowel marks, diaeresis, case removed -->
            <xsl:attribute name="key1">
              <xsl:call-template name="uni-strip">
                <xsl:with-param name="input" select="."/>
                <xsl:with-param name="strip-vowels" select="true()"/>
                <xsl:with-param name="strip-diaereses" select="true()"/>
                <xsl:with-param name="strip-caps" select="true()"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="key2">
              <!-- key2 = lemma with only vowel marks removed -->
              <xsl:variable name="key2">
                <xsl:call-template name="uni-strip">
                  <xsl:with-param name="input" select="."/>
                  <xsl:with-param name="strip-vowels" select="true()"/>
                  <xsl:with-param name="strip-diaereses" select="false()"/>
                  <xsl:with-param name="strip-caps" select="false()"/>
                </xsl:call-template>
              </xsl:variable>
              <!-- with leading @ to flag special case -->
              <xsl:value-of select="concat('@', $key2)"/>
            </xsl:attribute>
          </xsl:if>
          <!-- call recursively, specifying whether contains betacode -->
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:when>

      <!-- if no name, it's text -->
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- handle attributes -->
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
