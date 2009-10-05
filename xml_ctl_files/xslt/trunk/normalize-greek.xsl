<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!--
        Copyright 2009 Cantus Foundation
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
        Normalize Greek Unicode to precomposed/decomposed characters
        
        Parameters:
        $a_in           text to normalize
        $a_precomposed  whether to produce precomposed output (default=true)
        $a_strip        betacode characters to strip (e.g. "/\=" to remove accents)
        $a_partial      whether this is a partial word (default=false)
        (If true, do not use final sigma for last letter)
    -->
  <xsl:include href="uni2betacode.xsl"/>
  <xsl:include href="beta2unicode.xsl"/>

  <xsl:output method="text"/>


  <xsl:template name="normalize-greek">
    <xsl:param name="a_in"/>
    <xsl:param name="a_precomposed" select="true()"/>
    <xsl:param name="a_strip" select="''"/>
    <xsl:param name="a_partial" select="false()"/>

    <!-- convert to betacode -->
    <xsl:variable name="temp1">
      <xsl:call-template name="uni-to-beta">
        <xsl:with-param name="a_in" select="$a_in"/>
        <xsl:with-param name="a_upper" select="false()"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- remove any requested characters -->
    <xsl:variable name="temp2">
      <xsl:choose>
        <xsl:when test="string-length($a_strip) > 0">
          <xsl:call-template name="beta-strip">
            <xsl:with-param name="a_in" select="$temp1"/>
            <xsl:with-param name="a_stripString" select="$a_strip"/>
            <xsl:with-param name="a_stripVowels" select="false()"/>
            <xsl:with-param name="a_stripDiaereses" select="false()"/>
            <xsl:with-param name="a_stripCaps" select="false()"/>
            
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$temp1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- convert back to unicode -->
    <xsl:call-template name="beta-to-uni">
      <xsl:with-param name="a_in" select="$temp2"/>
      <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
      <xsl:with-param name="a_partial" select="$a_partial"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
