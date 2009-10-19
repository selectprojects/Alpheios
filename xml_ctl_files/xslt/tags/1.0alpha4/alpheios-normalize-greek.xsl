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
    $e_in           text to normalize
    $e_precomposed  whether to produce precomposed output (default=true)
    $e_strip        betacode characters to strip (e.g. "/\=" to remove accents)
    $e_partial      whether this is a partial word (default=false)
    (If true, do not use final sigma for last letter)
-->

  <xsl:output method="text"/>
  <xsl:include href="normalize-greek.xsl"/>
  <xsl:param name="e_in"/>
  <xsl:param name="e_precomposed" select="1"/>
  <xsl:param name="e_strip" select="''"/>
  <xsl:param name="e_partial" select="0"/>
  <xsl:template match="/">
    <xsl:call-template name="normalize-greek">
      <xsl:with-param name="a_in" select="$e_in"/>
      <xsl:with-param name="a_precomposed" select="$e_precomposed != 0"/>
      <xsl:with-param name="a_strip" select="$e_strip"/>
      <xsl:with-param name="a_partial" select="$e_partial != 0"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
